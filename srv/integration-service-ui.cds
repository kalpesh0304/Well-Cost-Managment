// UI Annotations for Integration Service
using IntegrationService from './integration-service';

// ============================================
// DATA QUALITY RULES
// ============================================
annotate IntegrationService.DataQualityRules with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Data Quality Rule',
    TypeNamePlural: 'Data Quality Rules',
    Title: { Value: ruleCode },
    Description: { Value: ruleName }
  },

  UI.SelectionFields: [
    entityType,
    severity,
    isActive
  ],

  UI.LineItem: [
    { Value: ruleCode, Label: 'Rule Code' },
    { Value: ruleName, Label: 'Rule Name' },
    { Value: entityType, Label: 'Entity Type' },
    { Value: severity, Label: 'Severity' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate IntegrationService.DataQualityRules with {
  ID @UI.Hidden;
  ruleCode @title: 'Rule Code';
  ruleName @title: 'Rule Name';
}

// ============================================
// MAPPING CONFIGURATIONS
// ============================================
annotate IntegrationService.MappingConfigs with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Mapping Configuration',
    TypeNamePlural: 'Mapping Configurations',
    Title: { Value: configName }
  },

  UI.SelectionFields: [
    sourceSystem,
    targetSystem,
    isActive
  ],

  UI.LineItem: [
    { Value: configName, Label: 'Config Name' },
    { Value: sourceSystem, Label: 'Source System' },
    { Value: targetSystem, Label: 'Target System' },
    { Value: entityType, Label: 'Entity Type' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'FieldMappingsFacet',
      Label: 'Field Mappings',
      Target: 'fieldMappings/@UI.LineItem'
    }
  ]
);

annotate IntegrationService.MappingConfigs with {
  ID @UI.Hidden;
  configName @title: 'Config Name';
}

// ============================================
// FIELD MAPPINGS
// ============================================
annotate IntegrationService.FieldMappings with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Field Mapping',
    TypeNamePlural: 'Field Mappings'
  },

  UI.LineItem: [
    { Value: sourceField, Label: 'Source Field' },
    { Value: targetField, Label: 'Target Field' },
    { Value: transformationType, Label: 'Transformation' },
    { Value: isRequired, Label: 'Required' }
  ]
);

annotate IntegrationService.FieldMappings with {
  ID @UI.Hidden;
  config @UI.Hidden;
}

// ============================================
// COMMUNICATION SCENARIOS
// ============================================
annotate IntegrationService.CommunicationScenarios with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Communication Scenario',
    TypeNamePlural: 'Communication Scenarios',
    Title: { Value: scenarioCode },
    Description: { Value: scenarioName }
  },

  UI.SelectionFields: [
    scenarioType,
    isEnabled
  ],

  UI.LineItem: [
    { Value: scenarioCode, Label: 'Scenario Code' },
    { Value: scenarioName, Label: 'Scenario Name' },
    { Value: scenarioType, Label: 'Type' },
    { Value: endpointUrl, Label: 'Endpoint URL' },
    { Value: isEnabled, Label: 'Enabled' }
  ]
);

annotate IntegrationService.CommunicationScenarios with {
  ID @UI.Hidden;
  scenarioCode @title: 'Scenario Code';
  scenarioName @title: 'Scenario Name';
}

// ============================================
// ETL JOBS
// ============================================
annotate IntegrationService.ETLJobs with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'ETL Job',
    TypeNamePlural: 'ETL Jobs',
    Title: { Value: jobCode },
    Description: { Value: jobName }
  },

  UI.SelectionFields: [
    jobType,
    isEnabled
  ],

  UI.LineItem: [
    { Value: jobCode, Label: 'Job Code' },
    { Value: jobName, Label: 'Job Name' },
    { Value: jobType, Label: 'Type' },
    { Value: schedule, Label: 'Schedule' },
    { Value: isEnabled, Label: 'Enabled' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'JobRunsFacet',
      Label: 'Job Runs',
      Target: 'runs/@UI.LineItem'
    }
  ]
);

annotate IntegrationService.ETLJobs with {
  ID @UI.Hidden;
  jobCode @title: 'Job Code';
  jobName @title: 'Job Name';
}

// ============================================
// ETL JOB RUNS (Read-Only)
// ============================================
annotate IntegrationService.ETLJobRuns with @(
  UI.HeaderInfo: {
    TypeName: 'Job Run',
    TypeNamePlural: 'Job Runs'
  },

  UI.LineItem: [
    { Value: startTime, Label: 'Start Time' },
    { Value: endTime, Label: 'End Time' },
    { Value: status, Label: 'Status' },
    { Value: recordsProcessed, Label: 'Records Processed' },
    { Value: recordsFailed, Label: 'Records Failed' }
  ]
);

annotate IntegrationService.ETLJobRuns with {
  ID @UI.Hidden;
  job @UI.Hidden;
}

// ============================================
// SYNC STATUS
// ============================================
annotate IntegrationService.SyncStatus with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Sync Status',
    TypeNamePlural: 'Sync Statuses'
  },

  UI.SelectionFields: [
    entityType,
    status
  ],

  UI.LineItem: [
    { Value: entityType, Label: 'Entity Type' },
    { Value: status, Label: 'Status' },
    { Value: lastSyncTime, Label: 'Last Sync Time' },
    { Value: recordsSynced, Label: 'Records Synced' },
    { Value: recordsFailed, Label: 'Records Failed' }
  ]
);

annotate IntegrationService.SyncStatus with {
  ID @UI.Hidden;
}

// ============================================
// INTEGRATION LOGS (Read-Only)
// ============================================
annotate IntegrationService.IntegrationLogs with @(
  UI.HeaderInfo: {
    TypeName: 'Integration Log',
    TypeNamePlural: 'Integration Logs'
  },

  UI.SelectionFields: [
    logType,
    status
  ],

  UI.LineItem: [
    { Value: logTime, Label: 'Log Time' },
    { Value: logType, Label: 'Type' },
    { Value: entityType, Label: 'Entity Type' },
    { Value: status, Label: 'Status' },
    { Value: message, Label: 'Message' }
  ]
);

annotate IntegrationService.IntegrationLogs with {
  ID @UI.Hidden;
}
