// Modular Quint Protocol Specification: ADR-0005 (C3) Triadic Calibrated Pull + TUF Defense
// Closes Gap #6:
//   - Single-record state (`sys`) eliminating repetitive frame boilerplate
//   - Mid-switch power loss / crash recovery (`hostCrashMidSwitch` via boot-counter rollback)
//   - Human interactive override (`humanInteractiveSwitch`) serialized cleanly against background pull
//   - Deterministic `quint test` runs + exhaustive TLC verification

module triadic_pull {
  import types.* from "./types"

  pure val HOSTS: Set[HostId] = Set("astrolabe", "rpi")
  pure val MAX_STALENESS: Time = 2

  type PullSystem = {
    now: Time,
    mainEpoch: Epoch,
    published: Set[Snapshot],
    mirrorVisible: Set[Snapshot],
    mirrorCompromised: bool,
    hosts: HostId -> HostState
  }

  var sys: PullSystem

  action init = {
    sys' = {
      now: 0,
      mainEpoch: 1,
      published: Set(GENESIS_SNAP),
      mirrorVisible: Set(GENESIS_SNAP),
      mirrorCompromised: false,
      hosts: HOSTS.mapBy(_ => initHostState)
    }
  }

  action tick = all {
    sys.now < 4,
    sys' = { ...sys, now: sys.now + 1 }
  }

  action publishCalibrated(isHealthy: bool, hasCache: bool): bool = {
    val nextEp = sys.mainEpoch + 1
    val snap = {
      epoch: nextEp,
      timestamp: sys.now,
      closure: closureForEpoch(nextEp),
      validSig: true,
      healthyRuntime: isHealthy,
      cachePresent: hasCache
    }
    all {
      sys.mainEpoch < 3,
      sys' = {
        ...sys,
        mainEpoch: nextEp,
        published: sys.published.union(Set(snap)),
        mirrorVisible: if (sys.mirrorCompromised) sys.mirrorVisible else sys.mirrorVisible.union(Set(snap))
      }
    }
  }

  // Compromised mirror freezes updates AND injects forged mix-and-match unsigned snapshot
  action compromiseMirror = all {
    not(sys.mirrorCompromised),
    sys' = {
      ...sys,
      mirrorCompromised: true,
      mirrorVisible: sys.mirrorVisible.union(Set({
        epoch: sys.mainEpoch + 1,
        timestamp: sys.now,
        closure: "evil-forged",
        validSig: false,
        healthyRuntime: false,
        cachePresent: true
      }))
    }
  }

  // Autonomous background pull enforcing TUF monotonic epoch + signature + cache + freshness + lock
  action hostStartPull(hid: HostId): bool = {
    val h = sys.hosts.get(hid)
    nondet snap = sys.mirrorVisible.oneOf()
    all {
      not(h.pendingSwitch),
      not(h.switchLocked),
      isCalibratedCandidate(h, snap, sys.now, MAX_STALENESS),
      sys' = {
        ...sys,
        hosts: sys.hosts.set(hid, {
          ...h,
          activeEpoch: snap.epoch,
          activeClosure: snap.closure,
          activeHealthy: snap.healthyRuntime,
          maxSeenEpoch: snap.epoch,
          lastCalibrationTime: snap.timestamp,
          pendingSwitch: true,
          pendingSnapshot: snap,
          switchLocked: true,
          freezeAlert: false
        })
      }
    }
  }

  // Explicit L3+ human-authorized interactive switch (`just switch`) — acquires same local lock!
  action humanInteractiveSwitch(hid: HostId): bool = {
    val h = sys.hosts.get(hid)
    nondet snap = sys.published.oneOf()
    all {
      not(h.pendingSwitch),
      not(h.switchLocked),
      snap.validSig,
      snap.epoch > h.maxSeenEpoch,
      sys' = {
        ...sys,
        hosts: sys.hosts.set(hid, {
          ...h,
          activeEpoch: snap.epoch,
          activeClosure: snap.closure,
          activeHealthy: snap.healthyRuntime,
          maxSeenEpoch: snap.epoch,
          lastCalibrationTime: snap.timestamp,
          pendingSwitch: true,
          pendingSnapshot: snap,
          switchLocked: true,
          freezeAlert: false
        })
      }
    }
  }

  // Local self-assessment gate (alpha): commit healthy gen OR atomic rollback to lastHealthy
  action hostAssessAndCommitOrRollback(hid: HostId): bool = {
    val h = sys.hosts.get(hid)
    all {
      h.pendingSwitch,
      sys' = {
        ...sys,
        hosts: if (h.pendingSnapshot.healthyRuntime) {
          sys.hosts.set(hid, {
            ...h,
            lastHealthyEpoch: h.pendingSnapshot.epoch,
            lastHealthyClosure: h.pendingSnapshot.closure,
            activeHealthy: true,
            pendingSwitch: false,
            switchLocked: false
          })
        } else {
          sys.hosts.set(hid, {
            ...h,
            activeEpoch: h.lastHealthyEpoch,
            activeClosure: h.lastHealthyClosure,
            activeHealthy: true,
            pendingSwitch: false,
            switchLocked: false,
            rollbackCount: h.rollbackCount + 1
          })
        }
      }
    }
  }

  // GAP #6 CLOSED: Sudden power loss / kernel panic MID-SWITCH before healthcheck completes!
  // Boot-counter failsafe automatically boots back into `lastHealthy` and clears the lock cleanly!
  action hostCrashMidSwitch(hid: HostId): bool = {
    val h = sys.hosts.get(hid)
    all {
      h.pendingSwitch,
      sys' = {
        ...sys,
        hosts: sys.hosts.set(hid, {
          ...h,
          activeEpoch: h.lastHealthyEpoch,
          activeClosure: h.lastHealthyClosure,
          activeHealthy: true,
          pendingSwitch: false,
          switchLocked: false,
          crashRecoveryCount: h.crashRecoveryCount + 1
        })
      }
    }
  }

  // E3 Freshness Assessment: detects TUF Freeze Attack when staleness exceeds MAX_STALENESS
  action hostCheckFreshness(hid: HostId): bool = {
    val h = sys.hosts.get(hid)
    all {
      sys.now - h.lastCalibrationTime > MAX_STALENESS,
      not(h.freezeAlert),
      sys' = { ...sys, hosts: sys.hosts.set(hid, { ...h, freezeAlert: true }) }
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
      humanInteractiveSwitch(hid),
      hostAssessAndCommitOrRollback(hid),
      hostCrashMidSwitch(hid),
      hostCheckFreshness(hid)
    }
  }

  // === SAFETY INVARIANTS ===
  val invNeverActivatesForged: bool =
    HOSTS.forall(hid => sys.hosts.get(hid).activeClosure != "evil-forged")

  val invCommittedAlwaysHealthy: bool =
    HOSTS.forall(hid => not(sys.hosts.get(hid).pendingSwitch) implies sys.hosts.get(hid).activeHealthy)

  val invMonotonicHealthyLineage: bool =
    HOSTS.forall(hid => {
      val h = sys.hosts.get(hid)
      (h.lastHealthyEpoch >= 1) and (h.maxSeenEpoch >= h.lastHealthyEpoch) and
      (not(h.pendingSwitch) implies h.activeEpoch == h.lastHealthyEpoch)
    })

  val invLockMatchesPending: bool =
    HOSTS.forall(hid => sys.hosts.get(hid).switchLocked == sys.hosts.get(hid).pendingSwitch)

  val allInvariants: bool =
    invNeverActivatesForged and invCommittedAlwaysHealthy and
    invMonotonicHealthyLineage and invLockMatchesPending

  // === EXECUTABLE UNIT TESTS (`quint test`) ===
  run healthyUpgradeTest =
    init
      .then(publishCalibrated(true, true))
      .then(hostStartPull("astrolabe"))
      .then(hostAssessAndCommitOrRollback("astrolabe"))
      .expect(sys.hosts.get("astrolabe").activeEpoch == 2 and sys.hosts.get("astrolabe").activeHealthy)

  run autoRollbackOnBadGenTest =
    init
      .then(publishCalibrated(false, true))
      .then(hostStartPull("astrolabe"))
      .then(hostAssessAndCommitOrRollback("astrolabe"))
      .expect(
        sys.hosts.get("astrolabe").activeEpoch == 1 and
        sys.hosts.get("astrolabe").maxSeenEpoch == 2 and
        sys.hosts.get("astrolabe").rollbackCount == 1
      )

  run midSwitchPowerCrashRecoveryTest =
    init
      .then(publishCalibrated(true, true))
      .then(hostStartPull("rpi"))
      .then(hostCrashMidSwitch("rpi"))
      .expect(
        sys.hosts.get("rpi").activeEpoch == 1 and
        not(sys.hosts.get("rpi").pendingSwitch) and
        not(sys.hosts.get("rpi").switchLocked) and
        sys.hosts.get("rpi").crashRecoveryCount == 1
      )
}
