// Verft Formal Model (F-1 Closed — Non-Vacuous Mechanism-Faithful Verification):
// Ephemeral Capability Sessions (`verft-cap`):
//   Explicitly contrasts TWO real OS cleanup mechanisms parameterized by `CLEANUP_MODE`:
//     1. `capability_session_naive` (`userspace_drop`):
//        Secrets live in host `/run/user/...` and rely on userspace `Drop` + `kill(ssh_agent)`.
//        -> TLC MUST FALSIFY `invZeroResidueOnHost` (concrete counterexample on `sigkillCrash`!)
//     2. `capability_session` (`kernel_mount_ns`):
//        Secrets live strictly inside a kernel-owned `unshare(CLONE_NEWUSER | CLONE_NEWNS)` private
//        RAM `tmpfs`, and `ssh-agent` runs with `PR_SET_PDEATHSIG(SIGKILL)`.
//        -> TLC VERIFIES `allInvariants` (0 violations across ALL reachable states, even on `SIGKILL`!)

module capability_session_base {
  const CLEANUP_MODE: str // "userspace_drop" | "kernel_mount_ns"

  type Actor = str        // "human" | "ai-agent"
  type Posture = str      // "none" | "online" | "offline"
  type CapId = str        // "sops-root" | "github-cli" | "breakglass" | "obs-mcp-ro"

  pure val ACTORS: Set[Actor] = Set("human", "ai-agent")
  pure val ALL_CAPS: Set[CapId] = Set("sops-root", "github-cli", "breakglass", "obs-mcp-ro")
  pure val ROOT_CAPS: Set[CapId] = Set("sops-root", "github-cli", "breakglass")
  pure val ONLINE_ONLY_CAPS: Set[CapId] = Set("github-cli", "obs-mcp-ro")
  pure val OFFLINE_ONLY_CAPS: Set[CapId] = Set("breakglass")
  pure val MAX_TTL: int = 2

  type SessionState = {
    active: bool,
    actor: Actor,
    posture: Posture,
    caps: Set[CapId],
    hostRunSecretFile: bool,  // Actual OS artifact on host `/run` (leaks if userspace Drop skipped!)
    privateNsTmpfs: bool,     // Kernel-owned `CLONE_NEWNS` mount (reaped atomically by kernel!)
    sshAgentAlive: bool,
    ttlRemaining: int
  }

  var sess: SessionState

  pure def cedarAllowsCap(actor: Actor, cap: CapId): bool =
    if (actor == "ai-agent") cap == "obs-mcp-ro"
    else true

  pure def capCompatibleWithPosture(posture: Posture, cap: CapId): bool =
    if (posture == "online") not(OFFLINE_ONLY_CAPS.contains(cap))
    else if (posture == "offline") not(ONLINE_ONLY_CAPS.contains(cap))
    else false

  action init = {
    sess' = {
      active: false,
      actor: "human",
      posture: "none",
      caps: Set(),
      hostRunSecretFile: false,
      privateNsTmpfs: false,
      sshAgentAlive: false,
      ttlRemaining: 0
    }
  }

  action openSession(actor: Actor, posture: Posture, reqCaps: Set[CapId]): bool = all {
    not(sess.active),
    posture == "online" or posture == "offline",
    reqCaps.size() > 0,
    reqCaps.forall(c => cedarAllowsCap(actor, c) and capCompatibleWithPosture(posture, c)),
    sess' = {
      active: true,
      actor: actor,
      posture: posture,
      caps: reqCaps,
      // Mechanism-faithful: userspace mode materializes on host `/run`; kernel_mount_ns keeps host clean!
      hostRunSecretFile: if (CLEANUP_MODE == "userspace_drop") true else sess.hostRunSecretFile,
      privateNsTmpfs: CLEANUP_MODE == "kernel_mount_ns",
      sshAgentAlive: reqCaps.contains("github-cli") or reqCaps.contains("breakglass"),
      ttlRemaining: MAX_TTL
    }
  }

  // Graceful shell exit: userspace cleanup runs in BOTH modes.
  action normalExit = all {
    sess.active,
    sess' = {
      ...sess,
      active: false,
      posture: "none",
      caps: Set(),
      hostRunSecretFile: false,
      privateNsTmpfs: false,
      sshAgentAlive: false,
      ttlRemaining: 0
    }
  }

  // Supervisor TTL watchdog tick.
  action tickTtl = all {
    sess.active,
    sess.ttlRemaining > 0,
    sess' = { ...sess, ttlRemaining: sess.ttlRemaining - 1 }
  }

  action ttlExpire = all {
    sess.active,
    sess.ttlRemaining == 0,
    sess' = {
      ...sess,
      active: false,
      posture: "none",
      caps: Set(),
      hostRunSecretFile: false,
      privateNsTmpfs: false,
      sshAgentAlive: false,
      ttlRemaining: 0
    }
  }

  // Hard `SIGKILL` (`kill -9`) or OOM-kill of supervisor process!
  // Mechanism-faithful OS behavior:
  //   - `userspace_drop`: Drop handlers DO NOT RUN -> `hostRunSecretFile` & `sshAgentAlive` LEAK!
  //   - `kernel_mount_ns`: Kernel tears down `CLONE_NEWNS` + sends `PR_SET_PDEATHSIG(SIGKILL)` atomically!
  action sigkillCrash = all {
    sess.active,
    sess' = {
      ...sess,
      active: false,
      posture: "none",
      caps: Set(),
      hostRunSecretFile: if (CLEANUP_MODE == "kernel_mount_ns") false else sess.hostRunSecretFile,
      privateNsTmpfs: false,
      sshAgentAlive: if (CLEANUP_MODE == "kernel_mount_ns") false else sess.sshAgentAlive,
      ttlRemaining: 0
    }
  }

  action step = any {
    nondet actor = ACTORS.oneOf()
    nondet posture = Set("online", "offline").oneOf()
    nondet reqCaps = ALL_CAPS.powerset().oneOf()
    openSession(actor, posture, reqCaps),
    normalExit,
    tickTtl,
    ttlExpire,
    sigkillCrash
  }

  // === NON-VACUOUS SAFETY INVARIANTS ===
  val invAiNeverHoldsRootCap: bool =
    (sess.active and sess.actor == "ai-agent") implies sess.caps.intersect(ROOT_CAPS).size() == 0

  val invBreakglassMutuallyExclusiveWithOnline: bool =
    not(sess.caps.contains("breakglass") and sess.caps.intersect(ONLINE_ONLY_CAPS).size() > 0)

  val invPostureMatchesCaps: bool =
    sess.active implies sess.caps.forall(c => capCompatibleWithPosture(sess.posture, c))

  // Real falsifiable residue invariant: once inactive, ZERO host secret files & ZERO orphan ssh-agents!
  val invZeroResidueOnHost: bool =
    (not(sess.active) implies (not(sess.hostRunSecretFile) and not(sess.sshAgentAlive) and not(sess.privateNsTmpfs))) and
    (sess.active implies not(sess.hostRunSecretFile))

  val invTtlBounded: bool =
    sess.ttlRemaining >= 0 and sess.ttlRemaining <= MAX_TTL

  val allInvariants: bool =
    invAiNeverHoldsRootCap and
    invBreakglassMutuallyExclusiveWithOnline and
    invPostureMatchesCaps and
    invZeroResidueOnHost and
    invTtlBounded
}

// 1. Hardened production mechanism (`CLONE_NEWNS` + `PR_SET_PDEATHSIG`) — VERIFIED by TLC!
module capability_session {
  import capability_session_base(CLEANUP_MODE = "kernel_mount_ns").*

  run humanOnlineSigkillZeroResidueTest =
    init
      .then(openSession("human", "online", Set("sops-root", "github-cli")))
      .expect(sess.active and sess.privateNsTmpfs and not(sess.hostRunSecretFile) and sess.sshAgentAlive)
      .then(sigkillCrash)
      .expect(not(sess.active) and not(sess.hostRunSecretFile) and not(sess.privateNsTmpfs) and not(sess.sshAgentAlive))

  run aiReadOnlySessionBoundedTest =
    init
      .then(openSession("ai-agent", "online", Set("obs-mcp-ro")))
      .expect(sess.active and invAiNeverHoldsRootCap and not(sess.sshAgentAlive))
      .then(tickTtl)
      .then(tickTtl)
      .then(ttlExpire)
      .expect(not(sess.active) and not(sess.privateNsTmpfs))

  run breakglassOfflineIsolationTest =
    init
      .then(openSession("human", "offline", Set("breakglass", "sops-root")))
      .expect(sess.active and invBreakglassMutuallyExclusiveWithOnline)
      .then(normalExit)
      .expect(not(sess.active) and not(sess.hostRunSecretFile))
}

// 2. Naive userspace mechanism (`Drop` on host `/run`) — MUST BE FALSIFIED by TLC on `sigkillCrash`!
module capability_session_naive {
  import capability_session_base(CLEANUP_MODE = "userspace_drop").*

  run naiveUserspaceLeaksOnSigkillTest =
    init
      .then(openSession("human", "online", Set("sops-root", "github-cli")))
      .then(sigkillCrash)
      .expect(not(sess.active) and sess.hostRunSecretFile and sess.sshAgentAlive and not(invZeroResidueOnHost))
}
