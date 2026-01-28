// Operations Service (Daily Reports, Alerts, Forecasts)
using { wcm.operations as ops } from '../db/operations';
using { wcm.master as master } from '../db/master-data';
using { wcm.afe as afe } from '../db/afe';

@path: '/api/operations'
@requires: 'authenticated-user'
service OperationsService {

  // ============================================
  // DAILY DRILLING REPORTS
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity DailyReports as projection on ops.DailyReports {
    *,
    well : redirected to Wells,
    afe : redirected to AFEs,
    currency : redirected to Currencies,
    activities : redirected to DailyActivities,
    costs : redirected to DailyCosts
  } actions {
    @requires: 'CostWrite'
    action submit() returns DailyReports;

    @requires: 'CostWrite'
    action approve() returns DailyReports;

    @requires: 'CostWrite'
    action reject(reason: String) returns DailyReports;

    @requires: 'CostWrite'
    action copyFromPrevious() returns DailyReports;

    @requires: 'CostRead'
    action exportToPDF() returns LargeBinary;
  };

  @requires: ['CostRead', 'Admin']
  entity DailyActivities as projection on ops.DailyActivities {
    *,
    report : redirected to DailyReports
  };

  @requires: ['CostRead', 'Admin']
  entity DailyCosts as projection on ops.DailyCosts {
    *,
    report : redirected to DailyReports,
    costElement : redirected to CostElements,
    vendor : redirected to Vendors,
    uom : redirected to UnitsOfMeasure,
    currency : redirected to Currencies
  };

  // ============================================
  // ALERTS
  // ============================================
  @requires: ['CostRead', 'Admin']
  entity Alerts as projection on ops.Alerts {
    *,
    well : redirected to Wells,
    afe : redirected to AFEs,
    recipients : redirected to AlertRecipients
  } actions {
    @requires: 'CostRead'
    action acknowledge() returns Alerts;

    @requires: 'CostWrite'
    action resolve(resolution: String) returns Alerts;

    @requires: 'CostWrite'
    action snooze(untilDate: Timestamp) returns Alerts;
  };

  @readonly
  entity AlertRecipients as projection on ops.AlertRecipients;

  // ============================================
  // COST FORECASTS
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity CostForecasts as projection on ops.CostForecasts {
    *,
    afe : redirected to AFEs,
    well : redirected to Wells
  } actions {
    @requires: 'CostWrite'
    action generateAIForecast() returns CostForecasts;

    @requires: 'CostWrite'
    action recalculate() returns CostForecasts;
  };

  // ============================================
  // KPI SNAPSHOTS
  // ============================================
  @readonly
  entity KPISnapshots as projection on ops.KPISnapshots {
    *,
    well : redirected to Wells,
    field : redirected to Fields,
    currency : redirected to Currencies
  };

  // ============================================
  // REFERENCE ENTITIES
  // ============================================
  @readonly
  entity Wells as projection on master.Wells;

  @readonly
  entity Fields as projection on master.Fields;

  @readonly
  entity AFEs as projection on afe.AFEs;

  @readonly
  entity CostElements as projection on master.CostElements;

  @readonly
  entity Vendors as projection on master.Vendors;

  @readonly
  entity Currencies as projection on master.Currencies;

  @readonly
  entity UnitsOfMeasure as projection on master.UnitsOfMeasure;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getDailyReportsByWell(wellId: UUID, fromDate: Date, toDate: Date) returns array of DailyReports;
  function getLatestDailyReport(wellId: UUID) returns DailyReports;
  function getActiveAlerts() returns array of Alerts;
  function getMyAlerts() returns array of Alerts;
  function getAlertsByWell(wellId: UUID) returns array of Alerts;

  function getWellProgress(wellId: UUID) returns {
    currentDepth: Decimal;
    targetDepth: Decimal;
    progressPct: Decimal;
    daysElapsed: Integer;
    plannedDays: Integer;
    scheduleVariance: Integer;
    costToDate: Decimal;
    estimatedCost: Decimal;
    costVariancePct: Decimal;
  };

  function getDrillingSummary(wellId: UUID) returns {
    totalDays: Integer;
    productiveHours: Decimal;
    nptHours: Decimal;
    nptPct: Decimal;
    avgCostPerDay: Decimal;
    avgFootagePerDay: Decimal;
  };

  function getNPTAnalysis(wellId: UUID) returns array of {
    category: String;
    hours: Decimal;
    pct: Decimal;
    cost: Decimal;
  };

  // ============================================
  // ACTIONS
  // ============================================
  @requires: 'CostWrite'
  action createAlert(
    alertType: String,
    severity: String,
    title: String,
    message: String,
    wellId: UUID,
    afeId: UUID,
    recipientUserIds: array of String
  ) returns Alerts;

  @requires: 'Admin'
  action generateKPISnapshot(snapshotDate: Date, snapshotType: String) returns array of KPISnapshots;

  @requires: 'ReportRead'
  action generateDrillingReport(wellId: UUID, fromDate: Date, toDate: Date, format: String) returns LargeBinary;
}
