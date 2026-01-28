// Operations Entities (Daily Reports, Monitoring)
namespace wcm.operations;

using { wcm.common as common } from './common';
using { wcm.master as master } from './master-data';
using { wcm.afe as afe } from './afe';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// DAILY DRILLING REPORTS
// ============================================
entity DailyReports : cuid, managed {
  key ID                : UUID;
  well                  : Association to master.Wells not null;
  afe                   : Association to afe.AFEs not null;
  reportDate            : Date not null;
  dayNumber             : Integer not null;       // Days since spud

  // Depth Tracking
  depthMD               : common.Depth;           // Current measured depth (m)
  depthTVD              : common.Depth;           // Current true vertical depth (m)
  footageDrilled        : common.Depth;           // Today's footage (m)

  // Time Tracking
  productiveHours       : Decimal(5, 2);
  nptHours              : Decimal(5, 2);          // Non-productive time
  nptCategory           : String(50);             // Weather, Equipment, Personnel

  // Cost Tracking
  dailyCost             : common.Amount;
  cumulativeCost        : common.Amount;
  currency              : Association to master.Currencies;

  // Status
  operationPhase        : String(20);             // Drilling, Completion, Testing
  currentActivity       : String(200);
  remarks               : String(1000);

  // Submission
  submittedBy           : String(100);
  submittedAt           : Timestamp;
  approvedBy            : String(100);
  approvedAt            : Timestamp;
  status                : String(20) default 'Draft'; // Draft, Submitted, Approved

  // Details
  activities            : Composition of many DailyActivities on activities.report = $self;
  costs                 : Composition of many DailyCosts on costs.report = $self;
}

entity DailyActivities : cuid {
  report                : Association to DailyReports not null;
  startTime             : Time;
  endTime               : Time;
  durationHours         : Decimal(5, 2);
  activityCode          : String(20);
  activityName          : String(100);
  description           : String(500);
  isNPT                 : Boolean default false;
  nptCategory           : String(50);
}

entity DailyCosts : cuid {
  report                : Association to DailyReports not null;
  costElement           : Association to master.CostElements;
  vendor                : Association to master.Vendors;
  description           : String(200);
  quantity              : common.Quantity;
  uom                   : Association to master.UnitsOfMeasure;
  unitRate              : common.Rate;
  amount                : common.Amount not null;
  currency              : Association to master.Currencies;
}

// ============================================
// ALERTS AND NOTIFICATIONS
// ============================================
entity Alerts : cuid, managed {
  key ID                : UUID;
  alertType             : String(50) not null;    // CostOverrun, ApprovalDue, CommitmentExceeded
  severity              : common.Severity not null;
  title                 : String(200) not null;
  message               : String(1000);

  // References
  well                  : Association to master.Wells;
  afe                   : Association to afe.AFEs;

  // Status
  triggeredAt           : Timestamp not null;
  acknowledgedBy        : String(100);
  acknowledgedAt        : Timestamp;
  resolvedBy            : String(100);
  resolvedAt            : Timestamp;
  status                : String(20) not null default 'Active'; // Active, Acknowledged, Resolved

  // Recipients
  recipients            : Composition of many AlertRecipients on recipients.alert = $self;
}

entity AlertRecipients : cuid {
  alert                 : Association to Alerts not null;
  userId                : String(100) not null;
  userName              : String(100);
  email                 : String(100);
  notifiedAt            : Timestamp;
  readAt                : Timestamp;
}

// ============================================
// FORECASTS
// ============================================
entity CostForecasts : cuid, managed {
  key ID                : UUID;
  afe                   : Association to afe.AFEs not null;
  well                  : Association to master.Wells;
  forecastDate          : Date not null;
  forecastType          : String(20);             // AI, Manual, Trend

  // Forecast Values
  estimatedTotal        : common.Amount;
  actualToDate          : common.Amount;
  forecastToComplete    : common.Amount;
  forecastAtCompletion  : common.Amount;         // Calculated: actualToDate + forecastToComplete
  varianceAtCompletion  : common.Amount;         // Calculated: forecastAtCompletion - estimatedTotal

  // Confidence
  confidenceLevel       : String(20);            // Low, Medium, High
  confidencePct         : common.Percentage;

  // Details
  assumptions           : String(1000);
  generatedBy           : String(100);           // User or 'SYSTEM'
}

// ============================================
// KPI SNAPSHOTS
// ============================================
entity KPISnapshots : cuid {
  key ID                : UUID;
  snapshotDate          : Date not null;
  snapshotType          : String(20);            // Daily, Weekly, Monthly

  // Well KPIs
  well                  : Association to master.Wells;
  field                 : Association to master.Fields;

  // Cost KPIs
  totalEstimated        : common.Amount;
  totalActual           : common.Amount;
  totalCommitted        : common.Amount;
  variancePct           : common.Percentage;

  // Schedule KPIs
  plannedDays           : Integer;
  actualDays            : Integer;
  scheduleVariance      : Integer;

  // Safety KPIs
  incidentCount         : Integer default 0;
  nptHours              : Decimal(10, 2);

  currency              : Association to master.Currencies;
}
