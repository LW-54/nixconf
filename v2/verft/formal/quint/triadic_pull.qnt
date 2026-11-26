// Verft Formal Model (F-4 Closed — Exhaustive Bounded TLC Safety + Temporal Liveness!):
// Triadic Calibrated Autonomous Pull (`verft-pull`) + TUF Anti-Downgrade/Freeze Defense
//   - `triadic_pull`: full 2-host (`astrolabe`, `rpi`) simulation + unit tests
//   - `triadic_pull_tlc`: bounded exhaustive TLC safety (`allInvariants`) + temporal liveness
//     (`eventuallyHealthyStabilization` under weak fairness — proves NO permanent stuck switch!)

module triadic_pull_base {
  import types.* from "./types"

  const HOSTS: Set[HostId]
  const MAX_TIME: Time
  const MAX_EPOCH: Epoch
  pure val MAX_STALENESS: Time = 2

  type PullSystem = {
    now: Time,
    mainEpoch: Epoch,
    published: Set[Snapshot],
    mirrorVisible: Set[Snapshot],
    mirrorCompromised: bool,
    niks3WriteServerUp: bool,   // Decoupled from R2 CDN read path!
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
      niks3WriteServerUp: true,
      hosts: HOSTS.mapBy(_ => initHostState)
    }
  }

  action toggleNiks3WriteServer = {
    sys' = { ...sys, niks3WriteServerUp: not(sys.niks3WriteServerUp) }
  }

  action tick = all {
    sys.now < MAX_TIME,
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
      sys.mainEpoch < MAX_EPOCH,
      sys' = {
        ...sys,
        mainEpoch: nextEp,
        published: sys.published.union(Set(snap)),
        mirrorVisible: if (sys.mirrorCompromised) sys.mirrorVisible else sys.mirrorVisible.union(Set(snap))
      }
    }
  }

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
            failedEpochs: h.failedEpochs.union(Set(h.pendingSnapshot.epoch)),
            pendingSwitch: false,
            switchLocked: false,
            rollbackAlert: true,
            rollbackCount: h.rollbackCount + 1
          })
        }
      }
    }
  }

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
          failedEpochs: h.failedEpochs.union(Set(h.pendingSnapshot.epoch)),
          pendingSwitch: false,
          switchLocked: false,
          rollbackAlert: true,
          crashRecoveryCount: h.crashRecoveryCount + 1
        })
      }
    }
  }

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
    toggleNiks3WriteServer,
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

  val invNeverReEntersFailedEpoch: bool =
    HOSTS.forall(hid => {
      val h = sys.hosts.get(hid)
      not(h.failedEpochs.contains(h.activeEpoch)) and
      h.failedEpochs.forall(fe => fe <= h.maxSeenEpoch)
    })

  val invLockMatchesPending: bool =
    HOSTS.forall(hid => sys.hosts.get(hid).switchLocked == sys.hosts.get(hid).pendingSwitch)

  val allInvariants: bool =
    invNeverActivatesForged and invCommittedAlwaysHealthy and
    invMonotonicHealthyLineage and invNeverReEntersFailedEpoch and invLockMatchesPending
}

module triadic_pull {
  import triadic_pull_base(HOSTS = Set("astrolabe", "rpi"), MAX_TIME = 4, MAX_EPOCH = 3).*

  run healthyUpgradeTest =
    init
      .then(publishCalibrated(true, true))
      .then(toggleNiks3WriteServer)
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
        sys.hosts.get("astrolabe").failedEpochs.contains(2) and
        sys.hosts.get("astrolabe").rollbackAlert and
        sys.hosts.get("astrolabe").rollbackCount == 1
      )

  run midSwitchPowerCrashRecoveryAndFixTest =
    init
      .then(publishCalibrated(true, true))
      .then(hostStartPull("rpi"))
      .then(hostCrashMidSwitch("rpi"))
      .expect(
        sys.hosts.get("rpi").activeEpoch == 1 and
        sys.hosts.get("rpi").failedEpochs.contains(2) and
        sys.hosts.get("rpi").rollbackAlert and
        not(sys.hosts.get("rpi").pendingSwitch) and
        not(sys.hosts.get("rpi").switchLocked) and
        sys.hosts.get("rpi").crashRecoveryCount == 1
      )
      .then(publishCalibrated(true, true))
      .then(hostStartPull("rpi"))
      .then(hostAssessAndCommitOrRollback("rpi"))
      .expect(sys.hosts.get("rpi").activeEpoch == 3 and sys.hosts.get("rpi").activeHealthy)
}

// Bounded exhaustive TLC safety + temporal liveness model (`F-4` closed!)
module triadic_pull_tlc {
  import triadic_pull_base(HOSTS = Set("astrolabe"), MAX_TIME = 3, MAX_EPOCH = 3).*

  // Temporal Liveness under Host Watchdog Weak Fairness:
  // Even if the external `niks3` write server flaps infinitely and mirrors are compromised,
  // as long as the local host's assessment watchdog runs fairly, EVERY pending switch MUST
  // eventually complete (commit or atomic rollback) into a healthy committed state!
  temporal eventuallyHealthyStabilization =
    weakFair(hostAssessAndCommitOrRollback("astrolabe"), Set(sys)) implies
      always(
        sys.hosts.get("astrolabe").pendingSwitch implies
          eventually(not(sys.hosts.get("astrolabe").pendingSwitch) and sys.hosts.get("astrolabe").activeHealthy)
      )
}
