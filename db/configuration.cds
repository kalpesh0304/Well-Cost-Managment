// Configuration Entities
namespace wcm.configuration;

using { wcm.common as common } from './common';
using { wcm.master as master } from './master-data';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// APPROVAL MATRIX
// ============================================
entity ApprovalMatrix : common.MasterData {
  key ID                : UUID;
  matrixName            : String(100) not null;
  entityType            : String(50) not null;   // AFE, Variance, etc.
  field                 : Association to master.Fields;
  wellType              : common.WellType;
  amountFrom            : common.Amount;
  amountTo              : common.Amount;
  approvalLevel         : Integer not null;
  approverRole          : String(50) not null;
  escalationDays        : Integer;

  // Conditions
  conditions            : Composition of many ApprovalMatrixConditions on conditions.matrix = $self;
}

entity ApprovalMatrixConditions : cuid {
  matrix                : Association to ApprovalMatrix not null;
  conditionField        : String(50) not null;
  conditionOperator     : String(20) not null;   // EQ, NE, GT, LT, GE, LE, IN
  conditionValue        : String(200) not null;
  logicalOperator       : String(10);            // AND, OR
}

// ============================================
// SYSTEM CONFIGURATIONS
// ============================================
entity SystemConfigurations : cuid, managed {
  key ID                : UUID;
  configKey             : String(100) not null @mandatory;
  configValue           : String(1000);
  configType            : String(20);            // String, Number, Boolean, JSON
  description           : String(500);
  category              : String(50);            // General, Integration, Security, etc.
  isEncrypted           : Boolean default false;
}

// ============================================
// NOTIFICATION TEMPLATES
// ============================================
entity NotificationTemplates : common.MasterData {
  key ID                : UUID;
  templateCode          : String(50) not null @mandatory;
  templateName          : String(100) not null;
  templateType          : String(20);            // Email, SMS, Push
  eventType             : String(50);            // AFECreated, ApprovalRequired, etc.
  subject               : String(200);
  body                  : LargeString;
  isHtml                : Boolean default true;

  // Placeholders
  placeholders          : Composition of many TemplatePlaceholders on placeholders.template = $self;
}

entity TemplatePlaceholders : cuid {
  template              : Association to NotificationTemplates not null;
  placeholderKey        : String(50) not null;
  placeholderName       : String(100);
  dataSource            : String(100);           // Entity.field path
  defaultValue          : String(200);
}

// ============================================
// NUMBERING SERIES
// ============================================
entity NumberingSeries : common.MasterData {
  key ID                : UUID;
  seriesCode            : String(20) not null @mandatory;
  seriesName            : String(100) not null;
  entityType            : String(50) not null;   // AFE, JIB, etc.
  prefix                : String(20);
  suffix                : String(20);
  currentNumber         : Integer not null default 0;
  numberLength          : Integer default 6;
  resetPeriod           : String(20);            // None, Year, Month
  lastResetDate         : Date;

  // Scope
  field                 : Association to master.Fields;
}

// ============================================
// VALIDATION RULES
// ============================================
entity ValidationRules : common.MasterData {
  key ID                : UUID;
  ruleName              : String(100) not null;
  ruleCode              : String(50) not null @mandatory;
  entityType            : String(50) not null;
  fieldName             : String(50);
  ruleType              : String(20) not null;   // Required, Range, Regex, Custom, CrossField
  ruleExpression        : String(500);
  errorMessage          : String(200) not null;
  severity              : common.Severity not null default 'Error';
  isBlocker             : Boolean default true;
}

// ============================================
// COST THRESHOLDS
// ============================================
entity CostThresholds : common.MasterData {
  key ID                : UUID;
  thresholdName         : String(100) not null;
  thresholdType         : String(20) not null;   // VariancePct, ContingencyPct, CommitmentPct
  field                 : Association to master.Fields;
  wellType              : common.WellType;
  warningThreshold      : common.Percentage;
  criticalThreshold     : common.Percentage;
  notifyRoles           : String(500);           // Comma-separated role codes
}

// ============================================
// WORKFLOW DEFINITIONS
// ============================================
entity WorkflowDefinitions : common.MasterData {
  key ID                : UUID;
  workflowCode          : String(50) not null @mandatory;
  workflowName          : String(100) not null;
  entityType            : String(50) not null;   // AFE, DailyReport, Variance
  description           : String(500);

  // Steps
  steps                 : Composition of many WorkflowSteps on steps.workflow = $self;
}

entity WorkflowSteps : cuid {
  workflow              : Association to WorkflowDefinitions not null;
  stepNumber            : Integer not null;
  stepName              : String(100) not null;
  stepType              : String(20);            // Approval, Review, Notification
  assigneeType          : String(20);            // Role, User, Dynamic
  assigneeValue         : String(100);
  timeoutDays           : Integer;
  escalateTo            : String(100);

  // Transitions
  onApprove             : Integer;               // Next step number
  onReject              : Integer;
  onReturn              : Integer;
}

// ============================================
// REPORT DEFINITIONS
// ============================================
entity ReportDefinitions : common.MasterData {
  key ID                : UUID;
  reportCode            : String(50) not null @mandatory;
  reportName            : String(100) not null;
  reportCategory        : String(50);            // Cost, Variance, Economics, JIB
  description           : String(500);
  baseEntity            : String(50);
  defaultParameters     : LargeString;           // JSON
  outputFormats         : String(100);           // PDF, Excel, CSV
}
