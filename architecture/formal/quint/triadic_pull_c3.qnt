// Formal Asynchronous Protocol Specification of ADR-0005 (C3) + TUF Supply-Chain Defense (RES-0013)
// Models:
//   - Calibrated Signed References (Git main + async mirror + signed binary cache snapshot)
//   - TUF Monotonic Epoch Rollback-Attack Defense, Freshness Freeze-Attack Detection, Snapshot Mix-and-Match Defense
//   - Host-local Proper-Time Pull (g_n -> g_{n+1}) with Self-Assessment Gate (alpha) & Atomic Auto-Rollback
//   - Compromised Mirror adversary attempting Rollback (downgrade), Freeze, and Mix-and-Match attacks

module triadic_pull_c3 {
  type HostId = str
  type Epoch = int
  type ClosureHash = str
  type Time = int

  type Snapshot = {
    epoch: Epoch,
    timestamp: Time,
    closure: ClosureHash,
    validSig: bool,
    healthyRuntime: bool,
    cachePresent: bool
  }

  type HostState = {
    activeEpoch: Epoch,
    activeClosure: ClosureHash,
    activeHealthy: bool,
    lastHealthyEpoch: Epoch,
    lastHealthyClosure: ClosureHash,
    maxSeenEpoch: Epoch,
    lastCalibrationTime: Time,
    pendingSwitch: bool,
    pendingSnapshot: Snapshot,
    freezeAlert: bool,
    rollbackCount: int
  }

  pure val HOSTS: Set[HostId] = Set("astrolabe", "rpi")
  pure val MAX_STALENESS: Time = 2

  var now: Time
  var mainEpoch: Epoch
  var published: Set[Snapshot]
  var mirrorVisible: Set[Snapshot]
  var mirrorCompromised: bool
  var hosts: HostId -> HostState

  pure def genesisSnap: Snapshot = {
    epoch: 1,
    timestamp: 0,
    closure: "c1",
    validSig: true,
    healthyRuntime: true,
    cachePresent: true
  }

  pure def initHost: HostState = {
    activeEpoch: 1,
    activeClosure: "c1",
    activeHealthy: true,
    lastHealthyEpoch: 1,
    lastHealthyClosure: "c1",
    maxSeenEpoch: 1,
    lastCalibrationTime: 0,
    pendingSwitch: false,
    pendingSnapshot: genesisSnap,
    freezeAlert: false,
    rollbackCount: 0
  }

  action init = all {
    now' = 0,
    mainEpoch' = 1,
    published' = Set(genesisSnap),
    mirrorVisible' = Set(genesisSnap),
    mirrorCompromised' = false,
    hosts' = HOSTS.mapBy(_ => initHost)
  }

  // Time advances (proper-time ticks across the fleet; bounded for exhaustive TLC closure)
  action tick = all {
    now < 4,
    now' = now + 1,
    mainEpoch' = mainEpoch,
    published' = published,
    mirrorVisible' = mirrorVisible,
    mirrorCompromised' = mirrorCompromised,
    hosts' = hosts
  }

  // CI verifies PR and publishes a new signed calibrated Snapshot (healthy or latent runtime bug)
  action publishCalibrated(isHealthy: bool, hasCache: bool): bool = {
    val nextEp = mainEpoch + 1
    val snap = {
      epoch: nextEp,
      timestamp: now,
      closure: if (nextEp == 2) "c2" else if (nextEp == 3) "c3" else "c4",
      validSig: true,
      healthyRuntime: isHealthy,
      cachePresent: hasCache
    }
    all {
      mainEpoch < 3,
      mainEpoch' = nextEp,
      published' = published.union(Set(snap)),
      // Healthy mirror syncs asynchronously unless compromised/frozen
      mirrorVisible' = if (mirrorCompromised) mirrorVisible else mirrorVisible.union(Set(snap)),
      now' = now,
      mirrorCompromised' = mirrorCompromised,
      hosts' = hosts
    }
  }

  // Adversary compromises mirror: can freeze updates OR inject forged/mix-and-match unsigned snapshots
  action compromiseMirror = all {
    not(mirrorCompromised),
    mirrorCompromised' = true,
    now' = now,
    mainEpoch' = mainEpoch,
    published' = published,
    // Adversary injects a forged mix-and-match snapshot with high epoch + invalid signature
    mirrorVisible' = mirrorVisible.union(Set({
      epoch: mainEpoch + 1,
      timestamp: now,
      closure: "evil-forged",
      validSig: false,
      healthyRuntime: false,
      cachePresent: true
    })),
    hosts' = hosts
  }

  // Host autonomously pulls a candidate snapshot from mirror (voluntary local proper-time pull)
  // Enforces TUF + C3 Calibration Gate:
  //   1. validSig == true (cryptographic snapshot signature)
  //   2. cachePresent == true (no forced local compile on constrained/ARM targets)
  //   3. snap.epoch > h.maxSeenEpoch (TUF strict monotonic anti-rollback-attack!)
  //   4. now - snap.timestamp <= MAX_STALENESS (TUF freshness window!)
  action hostStartPull(hid: HostId): bool = {
    val h = hosts.get(hid)
    nondet snap = mirrorVisible.oneOf()
    all {
      not(h.pendingSwitch),
      snap.validSig,
      snap.cachePresent,
      snap.epoch > h.maxSeenEpoch,
      now - snap.timestamp <= MAX_STALENESS,
      hosts' = hosts.set(hid, {
        ...h,
        activeEpoch: snap.epoch,
        activeClosure: snap.closure,
        activeHealthy: snap.healthyRuntime,
        maxSeenEpoch: snap.epoch,
        lastCalibrationTime: snap.timestamp,
        pendingSwitch: true,
        pendingSnapshot: snap,
        freezeAlert: false
      }),
      now' = now,
      mainEpoch' = mainEpoch,
      published' = published,
      mirrorVisible' = mirrorVisible,
      mirrorCompromised' = mirrorCompromised
    }
  }

  // Host executes local Self-Assessment Gate (alpha) immediately after atomic switch:
  //   - If healthy: commit new generation as lastHealthy
  //   - If unhealthy: autonomous atomic rollback to lastHealthy (keeping maxSeenEpoch high so bad epoch is never retried!)
  action hostAssessAndCommitOrRollback(hid: HostId): bool = {
    val h = hosts.get(hid)
    all {
      h.pendingSwitch,
      hosts' = if (h.pendingSnapshot.healthyRuntime) {
        hosts.set(hid, {
          ...h,
          lastHealthyEpoch: h.pendingSnapshot.epoch,
          lastHealthyClosure: h.pendingSnapshot.closure,
          activeHealthy: true,
          pendingSwitch: false
        })
      } else {
        hosts.set(hid, {
          ...h,
          activeEpoch: h.lastHealthyEpoch,
          activeClosure: h.lastHealthyClosure,
          activeHealthy: true,
          pendingSwitch: false,
          rollbackCount: h.rollbackCount + 1
        })
      },
      now' = now,
      mainEpoch' = mainEpoch,
      published' = published,
      mirrorVisible' = mirrorVisible,
      mirrorCompromised' = mirrorCompromised
    }
  }

  // E3 Freshness Assessment: detects TUF Freeze Attack when no fresh calibrated snapshot seen within MAX_STALENESS
  action hostCheckFreshness(hid: HostId): bool = {
    val h = hosts.get(hid)
    all {
      now - h.lastCalibrationTime > MAX_STALENESS,
      not(h.freezeAlert),
      hosts' = hosts.set(hid, { ...h, freezeAlert: true }),
      now' = now,
      mainEpoch' = mainEpoch,
      published' = published,
      mirrorVisible' = mirrorVisible,
      mirrorCompromised' = mirrorCompromised
    }
  }

  action step = any {
    tick,
    publishCalibrated(true, true),
    publishCalibrated(false, true),
    publishCalibrated(true, false),
    compromiseMirror,
    nondet hid = HOSTS.oneOf()
    any {
      hostStartPull(hid),
      hostAssessAndCommitOrRollback(hid),
      hostCheckFreshness(hid)
    }
  }

  // === FORMAL SAFETY INVARIANTS ===

  // INV-1: No host ever activates a forged / unsigned / mix-and-match closure
  val invNeverActivatesForged: bool =
    HOSTS.forall(hid => hosts.get(hid).activeClosure != "evil-forged")

  // INV-2: Every committed (non-pending) host generation is strictly healthy (zero permanent broken state!)
  val invCommittedAlwaysHealthy: bool =
    HOSTS.forall(hid => {
      val h = hosts.get(hid)
      not(h.pendingSwitch) implies h.activeHealthy
    })

  // INV-3: TUF Anti-Downgrade Invariant — lastHealthyEpoch never drops below genesis and active committed epoch equals lastHealthyEpoch
  val invMonotonicHealthyLineage: bool =
    HOSTS.forall(hid => {
      val h = hosts.get(hid)
      (h.lastHealthyEpoch >= 1) and (h.maxSeenEpoch >= h.lastHealthyEpoch) and
      (not(h.pendingSwitch) implies h.activeEpoch == h.lastHealthyEpoch)
    })

  // INV-4: No host ever activates a closure missing from signed binary cache
  val invNeverActivatesUncached: bool =
    HOSTS.forall(hid => {
      val h = hosts.get(hid)
      h.pendingSwitch implies h.pendingSnapshot.cachePresent
    })

  val allInvariants: bool =
    invNeverActivatesForged and
    invCommittedAlwaysHealthy and
    invMonotonicHealthyLineage and
    invNeverActivatesUncached
}
