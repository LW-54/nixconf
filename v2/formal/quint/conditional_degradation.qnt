// Modular Quint Protocol Specification: ADR-0003 Soft Conditional Promises (+b | C)
// & ADR-0006 C4 Dynamic Physical Conditions (Opportunistic TUF Laptop Compute & Partition Resilience)
// Uses single-record state (`deg`) + deterministic `quint test` runs + exhaustive TLC verification.

module conditional_degradation {
  type DegradationState = {
    meshUp: bool,
    wanUp: bool,
    tufAcPlugged: bool,
    tufThermalNominal: bool,
    tufOfferingBuilder: bool,
    x240UsingRemoteBuilder: bool,
    x240BlockedOnBuild: bool,
    astrolabeCoreVitality: bool,
    backupDegraded: bool
  }

  var deg: DegradationState

  pure def builderCondition(mesh: bool, ac: bool, therm: bool): bool =
    mesh and ac and therm

  action init = {
    deg' = {
      meshUp: true,
      wanUp: true,
      tufAcPlugged: true,
      tufThermalNominal: true,
      tufOfferingBuilder: true,
      x240UsingRemoteBuilder: false,
      x240BlockedOnBuild: false,
      astrolabeCoreVitality: true,
      backupDegraded: false
    }
  }

  action toggleMesh = {
    val nextMesh = not(deg.meshUp)
    val nextOffer = builderCondition(nextMesh, deg.tufAcPlugged, deg.tufThermalNominal)
    deg' = {
      ...deg,
      meshUp: nextMesh,
      tufOfferingBuilder: nextOffer,
      x240UsingRemoteBuilder: if (nextOffer) deg.x240UsingRemoteBuilder else false,
      x240BlockedOnBuild: false,
      astrolabeCoreVitality: true
    }
  }

  action toggleWan = {
    val nextWan = not(deg.wanUp)
    deg' = {
      ...deg,
      wanUp: nextWan,
      backupDegraded: not(nextWan),
      astrolabeCoreVitality: true
    }
  }

  action toggleTufPower = {
    val nextAc = not(deg.tufAcPlugged)
    val nextOffer = builderCondition(deg.meshUp, nextAc, deg.tufThermalNominal)
    deg' = {
      ...deg,
      tufAcPlugged: nextAc,
      tufOfferingBuilder: nextOffer,
      x240UsingRemoteBuilder: if (nextOffer) deg.x240UsingRemoteBuilder else false,
      x240BlockedOnBuild: false
    }
  }

  action toggleTufThermal = {
    val nextTherm = not(deg.tufThermalNominal)
    val nextOffer = builderCondition(deg.meshUp, deg.tufAcPlugged, nextTherm)
    deg' = {
      ...deg,
      tufThermalNominal: nextTherm,
      tufOfferingBuilder: nextOffer,
      x240UsingRemoteBuilder: if (nextOffer) deg.x240UsingRemoteBuilder else false,
      x240BlockedOnBuild: false
    }
  }

  action x240StartOpportunisticBuild = all {
    deg.tufOfferingBuilder,
    deg' = { ...deg, x240UsingRemoteBuilder: true, x240BlockedOnBuild: false }
  }

  action step = any {
    toggleMesh,
    toggleWan,
    toggleTufPower,
    toggleTufThermal,
    x240StartOpportunisticBuild
  }

  // === SAFETY INVARIANTS ===
  val invCoreVitalityNeverFails: bool = deg.astrolabeCoreVitality

  val invOpportunisticConditionSound: bool =
    (deg.tufOfferingBuilder == builderCondition(deg.meshUp, deg.tufAcPlugged, deg.tufThermalNominal)) and
    (deg.x240UsingRemoteBuilder implies deg.tufOfferingBuilder) and
    not(deg.x240BlockedOnBuild)

  val invBackupDegradationExplicit: bool = deg.backupDegraded == not(deg.wanUp)

  val allInvariants: bool =
    invCoreVitalityNeverFails and invOpportunisticConditionSound and invBackupDegradationExplicit

  // === EXECUTABLE UNIT TESTS (`quint test`) ===
  run tufUnplugMidBuildGracefulFallbackTest =
    init
      .then(x240StartOpportunisticBuild)
      .then(toggleTufPower)
      .expect(not(deg.tufOfferingBuilder) and not(deg.x240UsingRemoteBuilder) and not(deg.x240BlockedOnBuild))

  run wanOutageSelfHealingTest =
    init
      .then(toggleWan)
      .expect(deg.backupDegraded and deg.astrolabeCoreVitality)
      .then(toggleWan)
      .expect(not(deg.backupDegraded) and deg.astrolabeCoreVitality)
}
