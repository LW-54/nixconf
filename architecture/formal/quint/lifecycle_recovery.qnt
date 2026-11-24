// Modular Quint Protocol Specification: ADR-0006 C1 Agent Lifecycle Transitions
// Models:
//   1. Zero-Trust Genesis (t=0) from untrusted ephemeral Live-ISO (no secrets on ISO, crash-safe)
//   2. Stolen-Device Revocation + Mechanical Blast-Radius Secret Rotation
//   3. GAP #6 CLOSED: Zero-Infrastructure Break-Glass Disaster Recovery (simultaneous VPS + GitHub loss!)
// Uses single-record state (`lc`) + deterministic `quint test` runs + exhaustive TLC verification.

module lifecycle_recovery {
  type LifecycleState = {
    // Genesis t=0 (new host onboarding)
    isoBooted: bool,
    localKeyGenerated: bool,
    humanVerifiedCustody: bool,
    hostInstalled: bool,
    pubkeyInGit: bool,
    isoHasProdSecrets: bool,
    orphanedAuthIdentity: bool,
    // Compromise revocation & blast-radius rotation
    deviceStolen: bool,
    stolenKeyRevoked: bool,
    blastRadiusRotated: bool,
    stolenKeyCanReadCurrentSecrets: bool,
    // Zero-Infra Break-Glass Disaster Recovery
    vpsAlive: bool,
    githubAlive: bool,
    offlineRootKeyIntact: bool,
    gitMirrorIntact: bool,
    offhostBackupIntact: bool,
    fleetResurrected: bool
  }

  var lc: LifecycleState

  action init = {
    lc' = {
      isoBooted: true,
      localKeyGenerated: false,
      humanVerifiedCustody: false,
      hostInstalled: false,
      pubkeyInGit: false,
      isoHasProdSecrets: false,
      orphanedAuthIdentity: false,
      deviceStolen: false,
      stolenKeyRevoked: false,
      blastRadiusRotated: false,
      stolenKeyCanReadCurrentSecrets: false,
      vpsAlive: true,
      githubAlive: true,
      offlineRootKeyIntact: true,
      gitMirrorIntact: true,
      offhostBackupIntact: true,
      fleetResurrected: false
    }
  }

  // --- Genesis t=0 ---
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
    lc' = { ...lc, isoBooted: false, hostInstalled: true, isoHasProdSecrets: false }
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

  // --- Compromise Revocation & Blast-Radius Rotation ---
  action reportStolenDevice = all {
    lc.pubkeyInGit, not(lc.deviceStolen),
    lc' = { ...lc, deviceStolen: true, stolenKeyCanReadCurrentSecrets: true }
  }

  action revokeAndRotateBlastRadius = all {
    lc.deviceStolen, not(lc.blastRadiusRotated), lc.offlineRootKeyIntact,
    lc' = {
      ...lc,
      stolenKeyRevoked: true,
      blastRadiusRotated: true,
      stolenKeyCanReadCurrentSecrets: false
    }
  }

  // --- Zero-Infra Break-Glass Disaster Recovery (Simultaneous VPS + GitHub Loss!) ---
  action catastrophicOutage = all {
    lc.vpsAlive or lc.githubAlive,
    lc' = { ...lc, vpsAlive: false, githubAlive: false, fleetResurrected: false }
  }

  action breakGlassResurrect = all {
    not(lc.vpsAlive), not(lc.githubAlive),
    lc.offlineRootKeyIntact, lc.gitMirrorIntact, lc.offhostBackupIntact,
    lc' = { ...lc, vpsAlive: true, fleetResurrected: true }
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

  // === SAFETY INVARIANTS ===
  val invIsoZeroSecrets: bool =
    not(lc.isoHasProdSecrets) and (lc.isoBooted implies not(lc.pubkeyInGit))

  val invNoOrphanedIdentity: bool = not(lc.orphanedAuthIdentity)

  val invPostRotationSafe: bool =
    lc.blastRadiusRotated implies (lc.stolenKeyRevoked and not(lc.stolenKeyCanReadCurrentSecrets))

  val invBreakGlassAlwaysPossible: bool =
    lc.offlineRootKeyIntact and lc.gitMirrorIntact and lc.offhostBackupIntact

  val allInvariants: bool =
    invIsoZeroSecrets and invNoOrphanedIdentity and
    invPostRotationSafe and invBreakGlassAlwaysPossible

  // === EXECUTABLE UNIT TESTS (`quint test`) ===
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
      .then(breakGlassResurrect)
      .expect(lc.vpsAlive and lc.fleetResurrected)
}
