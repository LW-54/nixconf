// Shared Pure Domain Types & Helpers for Verft Distributed Protocol Models
// Informal Systems Quint Modular Architecture: pure types isolated from state machines.

module types {
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
    failedEpochs: Set[Epoch],
    lastCalibrationTime: Time,
    pendingSwitch: bool,
    pendingSnapshot: Snapshot,
    switchLocked: bool,       // Local serialization lock (background pull vs human switch)
    freezeAlert: bool,
    rollbackAlert: bool,
    rollbackCount: int,
    crashRecoveryCount: int
  }

  pure val GENESIS_SNAP: Snapshot = {
    epoch: 1,
    timestamp: 0,
    closure: "c1",
    validSig: true,
    healthyRuntime: true,
    cachePresent: true
  }

  pure def closureForEpoch(ep: Epoch): ClosureHash =
    if (ep == 1) "c1" else if (ep == 2) "c2" else "c3"

  pure def initHostState: HostState = {
    activeEpoch: 1,
    activeClosure: "c1",
    activeHealthy: true,
    lastHealthyEpoch: 1,
    lastHealthyClosure: "c1",
    maxSeenEpoch: 1,
    failedEpochs: Set(),
    lastCalibrationTime: 0,
    pendingSwitch: false,
    pendingSnapshot: GENESIS_SNAP,
    switchLocked: false,
    freezeAlert: false,
    rollbackAlert: false,
    rollbackCount: 0,
    crashRecoveryCount: 0
  }

  pure def isCalibratedCandidate(h: HostState, snap: Snapshot, now: Time, maxStaleness: Time): bool =
    snap.validSig and
    snap.cachePresent and
    snap.epoch > h.maxSeenEpoch and
    not(h.failedEpochs.contains(snap.epoch)) and
    (now - snap.timestamp <= maxStaleness)
}
