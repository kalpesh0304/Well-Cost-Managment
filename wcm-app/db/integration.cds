// Integration Entities (S/4HANA, Data Quality)
namespace wcm.integration;

using { wcm.common as common } from './common';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// INTEGRATION LOGS
// ============================================
entity IntegrationLogs : cuid {
  key ID                  : UUID;
  integrationName         : String(100) not null;
  sourceSystem            : String(50) not null;
  targetSystem            : String(50) not null;
  direction               : String(20);           // Inbound, Outbound, Bidirectional
  recordCount             : Integer;
  processingStartTime     : Timestamp not null;
  processingEndTime       : Timestamp;
  status                  : common.IntegrationStatus not null;
  errorMessage            : String(1000);
  recordsProcessed        : Integer;
  recordsFailed           : Integer;
  correlationId           : UUID;

  // Details
  details                 : Composition of many IntegrationLogDetails on details.log = $self;
}

entity IntegrationLogDetails : cuid {
  log                     : Association to IntegrationLogs not null;
  recordId                : String(100);
  entityType              : String(50);
  operation               : String(20);           // Create, Update, Delete
  status                  : String(20);           // Success, Failed
  errorCode               : String(20);
  errorMessage            : String(500);
  sourceData              : LargeString;          // JSON
  targetData              : LargeString;          // JSON
}

// ============================================
// DATA QUALITY RULES
// ============================================
entity DataQualityRules : common.MasterData {
  key ID                  : UUID;
  ruleName                : String(100) not null;
  entityName              : String(50) not null;
  fieldName               : String(50);
  ruleType                : String(20);           // Required, Range, Regex, Custom
  ruleExpression          : String(500);
  errorMessage            : String(200);
  severity                : common.Severity;
}

// ============================================
// MAPPING CONFIGURATIONS
// ============================================
entity MappingConfigs : common.MasterData {
  key ID                  : UUID;
  mappingName             : String(100) not null;
  sourceSystem            : String(50) not null;
  targetSystem            : String(50) not null;
  sourceEntity            : String(50) not null;
  targetEntity            : String(50) not null;

  // Field mappings
  fieldMappings           : Composition of many FieldMappings on fieldMappings.config = $self;
}

entity FieldMappings : cuid {
  config                  : Association to MappingConfigs not null;
  sourceField             : String(50) not null;
  targetField             : String(50) not null;
  transformationType      : String(20);           // Direct, Lookup, Expression
  transformationExpr      : String(500);
  defaultValue            : String(200);
  isRequired              : Boolean default false;
}

// ============================================
// SYNC STATUS
// ============================================
entity SyncStatus : cuid, managed {
  key ID                  : UUID;
  entityType              : String(50) not null;
  entityId                : UUID not null;
  sourceSystem            : String(50) not null;
  targetSystem            : String(50) not null;
  lastSyncAt              : Timestamp;
  syncStatus              : String(20);           // Synced, Pending, Failed
  syncDirection           : String(20);           // Inbound, Outbound
  errorMessage            : String(500);
  retryCount              : Integer default 0;
  nextRetryAt             : Timestamp;
}

// ============================================
// S/4HANA COMMUNICATION SCENARIOS
// ============================================
entity CommunicationScenarios : common.MasterData {
  key ID                  : UUID;
  scenarioId              : String(20) not null;  // SAP_COM_0008, etc.
  scenarioName            : String(100) not null;
  description             : String(500);
  direction               : String(20);           // Inbound, Outbound
  apiEndpoint             : String(500);
  authType                : String(20);           // OAuth2, BasicAuth, Certificate
  isEnabled               : Boolean default true;

  // Configuration
  batchSize               : Integer default 100;
  timeoutMs               : Integer default 30000;
  retryAttempts           : Integer default 3;
}

// ============================================
// ETL JOBS
// ============================================
entity ETLJobs : common.MasterData {
  key ID                  : UUID;
  jobName                 : String(100) not null;
  jobType                 : String(20);           // Extract, Transform, Load
  sourceSystem            : String(50);
  targetSystem            : String(50);
  schedule                : String(50);           // Cron expression
  isEnabled               : Boolean default true;
  lastRunAt               : Timestamp;
  lastRunStatus           : String(20);
  nextRunAt               : Timestamp;
}

entity ETLJobRuns : cuid {
  key ID                  : UUID;
  job                     : Association to ETLJobs not null;
  startTime               : Timestamp not null;
  endTime                 : Timestamp;
  status                  : String(20);           // Running, Completed, Failed
  recordsExtracted        : Integer;
  recordsTransformed      : Integer;
  recordsLoaded           : Integer;
  recordsFailed           : Integer;
  errorMessage            : String(1000);
}
