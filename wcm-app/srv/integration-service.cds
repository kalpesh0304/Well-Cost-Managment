// Integration Service (S/4HANA, Data Quality)
using { wcm.integration as intg } from '../db/integration';

@path: '/api/integration'
@requires: 'Admin'
service IntegrationService {

  // ============================================
  // INTEGRATION LOGS
  // ============================================
  @readonly
  entity IntegrationLogs as projection on intg.IntegrationLogs {
    *,
    details : redirected to IntegrationLogDetails
  };

  @readonly
  entity IntegrationLogDetails as projection on intg.IntegrationLogDetails;

  // ============================================
  // DATA QUALITY RULES
  // ============================================
  @odata.draft.enabled
  entity DataQualityRules as projection on intg.DataQualityRules actions {
    action activate() returns DataQualityRules;
    action deactivate() returns DataQualityRules;
    action test(testData: String) returns { isValid: Boolean; message: String };
  };

  // ============================================
  // MAPPING CONFIGURATIONS
  // ============================================
  @odata.draft.enabled
  entity MappingConfigs as projection on intg.MappingConfigs {
    *,
    fieldMappings : redirected to FieldMappings
  } actions {
    action validate() returns { isValid: Boolean; errors: array of String };
    action test(sourceData: String) returns String;
  };

  entity FieldMappings as projection on intg.FieldMappings;

  // ============================================
  // SYNC STATUS
  // ============================================
  entity SyncStatus as projection on intg.SyncStatus actions {
    action retry() returns SyncStatus;
    action reset() returns SyncStatus;
  };

  // ============================================
  // COMMUNICATION SCENARIOS
  // ============================================
  @odata.draft.enabled
  entity CommunicationScenarios as projection on intg.CommunicationScenarios actions {
    action enable() returns CommunicationScenarios;
    action disable() returns CommunicationScenarios;
    action testConnection() returns { success: Boolean; message: String; latencyMs: Integer };
  };

  // ============================================
  // ETL JOBS
  // ============================================
  @odata.draft.enabled
  entity ETLJobs as projection on intg.ETLJobs {
    *,
    runs : redirected to ETLJobRuns
  } actions {
    action enable() returns ETLJobs;
    action disable() returns ETLJobs;
    action runNow() returns ETLJobRuns;
  };

  @readonly
  entity ETLJobRuns as projection on intg.ETLJobRuns;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getIntegrationHealth() returns {
    overallStatus: String;
    s4hanaStatus: String;
    lastSyncTime: Timestamp;
    pendingSyncs: Integer;
    failedSyncs: Integer;
  };

  function getRecentLogs(hours: Integer) returns array of IntegrationLogs;
  function getFailedSyncs() returns array of SyncStatus;
  function getETLJobStatus() returns array of {
    jobName: String;
    lastRunStatus: String;
    lastRunTime: Timestamp;
    nextRunTime: Timestamp;
  };

  // ============================================
  // S/4HANA SYNC ACTIONS
  // ============================================
  action syncVendors() returns { recordsProcessed: Integer; recordsFailed: Integer };
  action syncCostElements() returns { recordsProcessed: Integer; recordsFailed: Integer };
  action syncCostActuals(fromDate: Date, toDate: Date) returns { recordsProcessed: Integer; recordsFailed: Integer };
  action syncCommitments(fromDate: Date, toDate: Date) returns { recordsProcessed: Integer; recordsFailed: Integer };
  action syncExchangeRates(rateDate: Date) returns { recordsProcessed: Integer; recordsFailed: Integer };

  // ============================================
  // DATA QUALITY ACTIONS
  // ============================================
  action runDataQualityCheck(entityType: String) returns array of {
    entityId: UUID;
    ruleCode: String;
    severity: String;
    message: String;
  };

  action validateAllData() returns {
    totalEntities: Integer;
    totalErrors: Integer;
    totalWarnings: Integer;
    details: array of { entityType: String; errors: Integer; warnings: Integer };
  };
}
