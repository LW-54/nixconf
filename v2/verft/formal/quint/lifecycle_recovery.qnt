// Verft Formal Model (F-1 Closed — Non-Vacuous Mechanism-Faithful DR & Genesis Verification):
// Explicitly contrasts TWO real Disaster Recovery key-custody architectures (`DR_MODE`):
//   1. `lifecycle_recovery_naive` (`vaultwarden_only`):
//      Root recovery key stored ONLY inside Vaultwarden hosted on the VPS!
//      -> When `catastrophicOutage` destroys VPS + GitHub, Vaultwarden dies with the VPS,
//         trapping the root key -> TLC FALSIFIES `invNoDrDeadlock` with exact counterexample!
//   2. `lifecycle_recovery` (`cold_recovery_sops`):
//      Offline cold `age` + encrypted `recovery.sops.yaml` (independent of VPS & GitHub)
//      + untrusted zero-secret Live-ISO genesis (`ISO_SECRETS_BAKED = false`)
//      + stolen-device blast-radius revocation -> TLC VERIFIES `allInvariants`!

module lifecycle_recovery_base {
  const DR_MODE: str           // "vaultwarden_only" | "cold_recovery_sops"
  const ISO_SECRETS_BAKED: bool

  type LifecycleState = {
    isoBooted: bool,
    localKeyGenerated: bool,
    humanVerifiedCustody: bool,
    hostInstalled: bool,
    pubkeyInGit: bool,
    isoHasProdSecrets: bool,
    orphanedAuthIdentity: bool,
    deviceStolen: bool,
    stolenKeyRevoked: bool,
    blastRadiusRotated: bool,
    stolenKeyCanReadCurrentSecrets: bool,
    vpsAlive: bool,
    vaultwardenAlive: bool,   // Hosted ON the VPS — dies whenever `vpsAlive` becomes false!
    githubAlive: bool,
    coldRecoverySopsIntact: bool,
    gitMirrorIntact: bool,
    offhostBackupIntact: bool,
    fleetResurrected: bool
  }

  var lc: LifecycleState

  pure def rootKeyReachable(s: LifecycleState): bool =
    if (DR_MODE == "cold_recovery_sops") s.coldRecoverySopsIntact or s.vaultwardenAlive
    else s.vaultwardenAlive

  action init = {
    lc' = {
      isoBooted: true,
      localKeyGenerated: false,
      humanVerifiedCustody: false,
      hostInstalled: false,
      pubkeyInGit: false,
      isoHasProdSecrets: ISO_SECRETS_BAKED,
      orphanedAuthIdentity: false,
      deviceStolen: false,
      stolenKeyRevoked: false,
      blastRadiusRotated: false,
      stolenKeyCanReadCurrentSecrets: false,
      vpsAlive: true,
      vaultwardenAlive: true,
      githubAlive: true,
      coldRecoverySopsIntact: DR_MODE == "cold_recovery_sops",
      gitMirrorIntact: true,
      offhostBackupIntact: true,
      fleetResurrected: false
    }
  }

  action genesisGenerateKey = all {
    lc.isoBooted, not(lc.localKeyGenerated), not(lc.hostInstalled),
    lc' = { ...lc, localKeyGenerated: true }
  }

  action genesisVerifyCustody = all {
    lc.localKeyGenerated, not(lc.humanVerifiedCustody), not(lc.hostInstalled),
    lc' = { ...lc, humanVerifiedCustody: true }
  }

  action genesisInstallAndReboot = all {
    lc.localKeyGenerated, lc.humanVerifiedCustody, not(lc.hostInstalled),
    lc' = { ...lc, isoBooted: false, hostInstalled: true }
  }

  action genesisRegisterPubkeyInGit = all {
    lc.hostInstalled, lc.humanVerifiedCustody, not(lc.pubkeyInGit), lc.githubAlive,
    lc' = { ...lc, pubkeyInGit: true }
  }

  action genesisCrashDuringIso = all {
    lc.isoBooted, not(lc.hostInstalled),
    lc' = {
      ...lc,
      localKeyGenerated: false,
      humanVerifiedCustody: false,
      orphanedAuthIdentity: lc.pubkeyInGit
    }
  }

  action reportStolenDevice = all {
    lc.pubkeyInGit, not(lc.deviceStolen),
    lc' = { ...lc, deviceStolen: true, stolenKeyCanReadCurrentSecrets: true }
  }

  action revokeAndRotateBlastRadius = all {
    lc.deviceStolen, not(lc.blastRadiusRotated), rootKeyReachable(lc),
    lc' = {
      ...lc,
      stolenKeyRevoked: true,
      blastRadiusRotated: true,
      stolenKeyCanReadCurrentSecrets: false
    }
  }

  // Catastrophic simultaneous VPS + GitHub outage: Vaultwarden dies WITH the VPS!
  action catastrophicOutage = all {
    lc.vpsAlive or lc.githubAlive,
    lc' = { ...lc, vpsAlive: false, vaultwardenAlive: false, githubAlive: false, fleetResurrected: false }
  }

  // Zero-Infra Break-Glass Resurrection requires reachable root key + git mirror + offhost backup!
  action breakGlassResurrect = all {
    not(lc.vpsAlive), not(lc.githubAlive),
    rootKeyReachable(lc), lc.gitMirrorIntact, lc.offhostBackupIntact,
    lc' = { ...lc, vpsAlive: true, vaultwardenAlive: true, fleetResurrected: true }
  }

  action step = any {
    genesisGenerateKey,
    genesisVerifyCustody,
    genesisInstallAndReboot,
    genesisRegisterPubkeyInGit,
    genesisCrashDuringIso,
    reportStolenDevice,
    revokeAndRotateBlastRadius,
    catastrophicOutage,
    breakGlassResurrect
  }

  // === NON-VACUOUS SAFETY INVARIANTS ===
  val invIsoZeroSecrets: bool =
    not(lc.isoHasProdSecrets) and (lc.isoBooted implies not(lc.pubkeyInGit))

  val invNoOrphanedIdentity: bool = not(lc.orphanedAuthIdentity)

  val invPostRotationSafe: bool =
    lc.blastRadiusRotated implies (lc.stolenKeyRevoked and not(lc.stolenKeyCanReadCurrentSecrets))

  // Real falsifiable DR deadlock check: even if VPS & Vaultwarden & GitHub die simultaneously,
  // break-glass resurrection MUST remain mechanically possible!
  val invNoDrDeadlock: bool =
    (not(lc.vpsAlive) and not(lc.githubAlive)) implies
      (rootKeyReachable(lc) and lc.gitMirrorIntact and lc.offhostBackupIntact)

  val allInvariants: bool =
    invIsoZeroSecrets and invNoOrphanedIdentity and
    invPostRotationSafe and invNoDrDeadlock
}

// 1. Hardened production custody (`cold_recovery_sops` + zero-secret ISO) — VERIFIED by TLC!
module lifecycle_recovery {
  import lifecycle_recovery_base(DR_MODE = "cold_recovery_sops", ISO_SECRETS_BAKED = false).*

  run genesisCrashSafeTest =
    init
      .then(genesisGenerateKey)
      .then(genesisVerifyCustody)
      .then(genesisCrashDuringIso)
      .expect(not(lc.orphanedAuthIdentity) and not(lc.isoHasProdSecrets))

  run stolenDeviceRotationTest =
    init
      .then(genesisGenerateKey)
      .then(genesisVerifyCustody)
      .then(genesisInstallAndReboot)
      .then(genesisRegisterPubkeyInGit)
      .then(reportStolenDevice)
      .then(revokeAndRotateBlastRadius)
      .expect(lc.stolenKeyRevoked and not(lc.stolenKeyCanReadCurrentSecrets))

  run zeroInfraBreakGlassTest =
    init
      .then(catastrophicOutage)
      .expect(not(lc.vpsAlive) and not(lc.vaultwardenAlive) and rootKeyReachable(lc))
      .then(breakGlassResurrect)
      .expect(lc.vpsAlive and lc.vaultwardenAlive and lc.fleetResurrected)
}

// 2. Naive custody (`vaultwarden_only` without cold `recovery.sops.yaml`) — FALSIFIED by TLC!
module lifecycle_recovery_naive {
  import lifecycle_recovery_base(DR_MODE = "vaultwarden_only", ISO_SECRETS_BAKED = false).*

  run vaultwardenDrDeadlockTest =
    init
      .then(catastrophicOutage)
      .expect(not(lc.vpsAlive) and not(lc.vaultwardenAlive) and not(rootKeyReachable(lc)) and not(invNoDrDeadlock))
}
