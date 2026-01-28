// UI Annotations for Admin Service
using AdminService from './admin-service';

// ============================================
// USERS
// ============================================
annotate AdminService.Users with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'User',
    TypeNamePlural: 'Users',
    Title: { Value: userName },
    Description: { Value: email }
  },

  UI.SelectionFields: [
    userType,
    status,
    isActive
  ],

  UI.LineItem: [
    { Value: userName, Label: 'User Name' },
    { Value: email, Label: 'Email' },
    { Value: firstName, Label: 'First Name' },
    { Value: lastName, Label: 'Last Name' },
    { Value: userType, Label: 'Type' },
    { Value: status, Label: 'Status' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'RolesFacet',
      Label: 'User Roles',
      Target: 'roles/@UI.LineItem'
    }
  ]
);

annotate AdminService.Users with {
  ID @UI.Hidden;
  userName @title: 'User Name';
  email @title: 'Email';
}

// ============================================
// ROLES
// ============================================
annotate AdminService.Roles with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Role',
    TypeNamePlural: 'Roles',
    Title: { Value: roleCode },
    Description: { Value: roleName }
  },

  UI.SelectionFields: [
    roleType,
    isActive
  ],

  UI.LineItem: [
    { Value: roleCode, Label: 'Role Code' },
    { Value: roleName, Label: 'Role Name' },
    { Value: roleType, Label: 'Type' },
    { Value: description, Label: 'Description' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ScopesFacet',
      Label: 'Role Scopes',
      Target: 'scopes/@UI.LineItem'
    }
  ]
);

annotate AdminService.Roles with {
  ID @UI.Hidden;
  roleCode @title: 'Role Code';
  roleName @title: 'Role Name';
}

// ============================================
// ROLE SCOPES
// ============================================
annotate AdminService.RoleScopes with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Role Scope',
    TypeNamePlural: 'Role Scopes'
  },

  UI.LineItem: [
    { Value: scopeType, Label: 'Scope Type' },
    { Value: scopeValue, Label: 'Scope Value' },
    { Value: permission, Label: 'Permission' }
  ]
);

annotate AdminService.RoleScopes with {
  ID @UI.Hidden;
  role @UI.Hidden;
}

// ============================================
// USER ROLES
// ============================================
annotate AdminService.UserRoles with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'User Role',
    TypeNamePlural: 'User Roles'
  },

  UI.LineItem: [
    { Value: assignedAt, Label: 'Assigned At' },
    { Value: assignedBy, Label: 'Assigned By' },
    { Value: validFrom, Label: 'Valid From' },
    { Value: validTo, Label: 'Valid To' }
  ]
);

annotate AdminService.UserRoles with {
  ID @UI.Hidden;
  user @UI.Hidden;
}

// ============================================
// APPROVAL MATRIX
// ============================================
annotate AdminService.ApprovalMatrix with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Approval Matrix',
    TypeNamePlural: 'Approval Matrices',
    Title: { Value: matrixCode },
    Description: { Value: matrixName }
  },

  UI.SelectionFields: [
    documentType,
    isActive
  ],

  UI.LineItem: [
    { Value: matrixCode, Label: 'Matrix Code' },
    { Value: matrixName, Label: 'Matrix Name' },
    { Value: documentType, Label: 'Document Type' },
    { Value: approvalLevels, Label: 'Levels' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ConditionsFacet',
      Label: 'Approval Conditions',
      Target: 'conditions/@UI.LineItem'
    }
  ]
);

annotate AdminService.ApprovalMatrix with {
  ID @UI.Hidden;
  matrixCode @title: 'Matrix Code';
  matrixName @title: 'Matrix Name';
}

// ============================================
// APPROVAL MATRIX CONDITIONS
// ============================================
annotate AdminService.ApprovalMatrixConditions with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Approval Condition',
    TypeNamePlural: 'Approval Conditions'
  },

  UI.LineItem: [
    { Value: conditionType, Label: 'Condition Type' },
    { Value: operator, Label: 'Operator' },
    { Value: conditionValue, Label: 'Value' },
    { Value: approverRole, Label: 'Approver Role' }
  ]
);

annotate AdminService.ApprovalMatrixConditions with {
  ID @UI.Hidden;
  matrix @UI.Hidden;
}

// ============================================
// SYSTEM CONFIGURATIONS
// ============================================
annotate AdminService.SystemConfigurations with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'System Configuration',
    TypeNamePlural: 'System Configurations',
    Title: { Value: configKey }
  },

  UI.SelectionFields: [
    configCategory,
    isActive
  ],

  UI.LineItem: [
    { Value: configKey, Label: 'Config Key' },
    { Value: configValue, Label: 'Config Value' },
    { Value: configCategory, Label: 'Category' },
    { Value: description, Label: 'Description' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AdminService.SystemConfigurations with {
  ID @UI.Hidden;
  configKey @title: 'Config Key';
  configValue @title: 'Config Value';
}

// ============================================
// NOTIFICATION TEMPLATES
// ============================================
annotate AdminService.NotificationTemplates with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Notification Template',
    TypeNamePlural: 'Notification Templates',
    Title: { Value: templateCode },
    Description: { Value: templateName }
  },

  UI.SelectionFields: [
    templateType,
    isActive
  ],

  UI.LineItem: [
    { Value: templateCode, Label: 'Template Code' },
    { Value: templateName, Label: 'Template Name' },
    { Value: templateType, Label: 'Type' },
    { Value: subject, Label: 'Subject' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'PlaceholdersFacet',
      Label: 'Placeholders',
      Target: 'placeholders/@UI.LineItem'
    }
  ]
);

annotate AdminService.NotificationTemplates with {
  ID @UI.Hidden;
  templateCode @title: 'Template Code';
  templateName @title: 'Template Name';
}

// ============================================
// TEMPLATE PLACEHOLDERS
// ============================================
annotate AdminService.TemplatePlaceholders with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Placeholder',
    TypeNamePlural: 'Placeholders'
  },

  UI.LineItem: [
    { Value: placeholderKey, Label: 'Placeholder Key' },
    { Value: description, Label: 'Description' },
    { Value: dataType, Label: 'Data Type' },
    { Value: isRequired, Label: 'Required' }
  ]
);

annotate AdminService.TemplatePlaceholders with {
  ID @UI.Hidden;
  template @UI.Hidden;
}

// ============================================
// NUMBERING SERIES
// ============================================
annotate AdminService.NumberingSeries with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Numbering Series',
    TypeNamePlural: 'Numbering Series',
    Title: { Value: seriesCode },
    Description: { Value: seriesName }
  },

  UI.SelectionFields: [
    documentType,
    isActive
  ],

  UI.LineItem: [
    { Value: seriesCode, Label: 'Series Code' },
    { Value: seriesName, Label: 'Series Name' },
    { Value: documentType, Label: 'Document Type' },
    { Value: prefix, Label: 'Prefix' },
    { Value: currentNumber, Label: 'Current Number' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AdminService.NumberingSeries with {
  ID @UI.Hidden;
  seriesCode @title: 'Series Code';
  seriesName @title: 'Series Name';
}

// ============================================
// VALIDATION RULES
// ============================================
annotate AdminService.ValidationRules with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Validation Rule',
    TypeNamePlural: 'Validation Rules',
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

annotate AdminService.ValidationRules with {
  ID @UI.Hidden;
  ruleCode @title: 'Rule Code';
  ruleName @title: 'Rule Name';
}

// ============================================
// COST THRESHOLDS
// ============================================
annotate AdminService.CostThresholds with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cost Threshold',
    TypeNamePlural: 'Cost Thresholds',
    Title: { Value: thresholdName }
  },

  UI.SelectionFields: [
    thresholdType,
    isActive
  ],

  UI.LineItem: [
    { Value: thresholdName, Label: 'Threshold Name' },
    { Value: thresholdType, Label: 'Type' },
    { Value: warningThreshold, Label: 'Warning Threshold' },
    { Value: criticalThreshold, Label: 'Critical Threshold' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AdminService.CostThresholds with {
  ID @UI.Hidden;
  thresholdName @title: 'Threshold Name';
}

// ============================================
// WORKFLOW DEFINITIONS
// ============================================
annotate AdminService.WorkflowDefinitions with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Workflow Definition',
    TypeNamePlural: 'Workflow Definitions',
    Title: { Value: workflowCode },
    Description: { Value: workflowName }
  },

  UI.SelectionFields: [
    documentType,
    isActive
  ],

  UI.LineItem: [
    { Value: workflowCode, Label: 'Workflow Code' },
    { Value: workflowName, Label: 'Workflow Name' },
    { Value: documentType, Label: 'Document Type' },
    { Value: version, Label: 'Version' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'StepsFacet',
      Label: 'Workflow Steps',
      Target: 'steps/@UI.LineItem'
    }
  ]
);

annotate AdminService.WorkflowDefinitions with {
  ID @UI.Hidden;
  workflowCode @title: 'Workflow Code';
  workflowName @title: 'Workflow Name';
}

// ============================================
// WORKFLOW STEPS
// ============================================
annotate AdminService.WorkflowSteps with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Workflow Step',
    TypeNamePlural: 'Workflow Steps'
  },

  UI.LineItem: [
    { Value: stepNumber, Label: 'Step #' },
    { Value: stepName, Label: 'Step Name' },
    { Value: stepType, Label: 'Type' },
    { Value: approverRole, Label: 'Approver Role' },
    { Value: isRequired, Label: 'Required' }
  ]
);

annotate AdminService.WorkflowSteps with {
  ID @UI.Hidden;
  workflow @UI.Hidden;
}

// ============================================
// REPORT DEFINITIONS
// ============================================
annotate AdminService.ReportDefinitions with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Report Definition',
    TypeNamePlural: 'Report Definitions',
    Title: { Value: reportCode },
    Description: { Value: reportName }
  },

  UI.SelectionFields: [
    reportType,
    isActive
  ],

  UI.LineItem: [
    { Value: reportCode, Label: 'Report Code' },
    { Value: reportName, Label: 'Report Name' },
    { Value: reportType, Label: 'Type' },
    { Value: description, Label: 'Description' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AdminService.ReportDefinitions with {
  ID @UI.Hidden;
  reportCode @title: 'Report Code';
  reportName @title: 'Report Name';
}

// ============================================
// AUDIT LOGS (Read-Only)
// ============================================
annotate AdminService.AuditLogs with @(
  UI.HeaderInfo: {
    TypeName: 'Audit Log',
    TypeNamePlural: 'Audit Logs'
  },

  UI.SelectionFields: [
    entityType,
    actionType,
    userId
  ],

  UI.LineItem: [
    { Value: logTime, Label: 'Log Time' },
    { Value: userId, Label: 'User ID' },
    { Value: entityType, Label: 'Entity Type' },
    { Value: actionType, Label: 'Action' },
    { Value: entityId, Label: 'Entity ID' }
  ]
);

annotate AdminService.AuditLogs with {
  ID @UI.Hidden;
}

// ============================================
// SESSIONS (Read-Only)
// ============================================
annotate AdminService.Sessions with @(
  UI.HeaderInfo: {
    TypeName: 'Session',
    TypeNamePlural: 'Sessions'
  },

  UI.SelectionFields: [
    isActive
  ],

  UI.LineItem: [
    { Value: sessionId, Label: 'Session ID' },
    { Value: loginTime, Label: 'Login Time' },
    { Value: lastActivity, Label: 'Last Activity' },
    { Value: ipAddress, Label: 'IP Address' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AdminService.Sessions with {
  ID @UI.Hidden;
}

// ============================================
// LOGIN HISTORY (Read-Only)
// ============================================
annotate AdminService.LoginHistory with @(
  UI.HeaderInfo: {
    TypeName: 'Login History',
    TypeNamePlural: 'Login History'
  },

  UI.LineItem: [
    { Value: loginTime, Label: 'Login Time' },
    { Value: logoutTime, Label: 'Logout Time' },
    { Value: ipAddress, Label: 'IP Address' },
    { Value: loginStatus, Label: 'Status' }
  ]
);

annotate AdminService.LoginHistory with {
  ID @UI.Hidden;
}
