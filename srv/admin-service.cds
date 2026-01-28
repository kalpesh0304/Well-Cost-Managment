// Admin Service (Security, Configuration, Audit)
using { wcm.security as sec } from '../db/security';
using { wcm.configuration as cfg } from '../db/configuration';
using { wcm.master as master } from '../db/master-data';

@path: '/api/admin'
@requires: 'Admin'
service AdminService {

  // ============================================
  // AUDIT LOGS
  // ============================================
  @readonly
  entity AuditLogs as projection on sec.AuditLogs;

  // ============================================
  // USERS
  // ============================================
  @odata.draft.enabled
  entity Users as projection on sec.Users {
    *,
    manager : redirected to Users,
    roles : redirected to UserRoles,
    preferences : redirected to UserPreferences
  } actions {
    action activate() returns Users;
    action deactivate() returns Users;
    action suspend() returns Users;
    action resetPassword() returns Users;
  };

  // ============================================
  // ROLES
  // ============================================
  @odata.draft.enabled
  entity Roles as projection on sec.Roles {
    *,
    scopes : redirected to RoleScopes
  };

  entity RoleScopes as projection on sec.RoleScopes;

  // ============================================
  // USER ROLES
  // ============================================
  @odata.draft.enabled
  entity UserRoles as projection on sec.UserRoles {
    *,
    user : redirected to Users,
    role : redirected to Roles
  };

  // ============================================
  // USER PREFERENCES
  // ============================================
  entity UserPreferences as projection on sec.UserPreferences;

  // ============================================
  // SESSIONS
  // ============================================
  @readonly
  entity Sessions as projection on sec.Sessions {
    *,
    user : redirected to Users
  } actions {
    action terminate() returns Sessions;
  };

  // ============================================
  // LOGIN HISTORY
  // ============================================
  @readonly
  entity LoginHistory as projection on sec.LoginHistory;

  // ============================================
  // APPROVAL MATRIX
  // ============================================
  @odata.draft.enabled
  entity ApprovalMatrix as projection on cfg.ApprovalMatrix {
    *,
    field : redirected to Fields,
    conditions : redirected to ApprovalMatrixConditions
  };

  entity ApprovalMatrixConditions as projection on cfg.ApprovalMatrixConditions;

  // ============================================
  // SYSTEM CONFIGURATIONS
  // ============================================
  @odata.draft.enabled
  entity SystemConfigurations as projection on cfg.SystemConfigurations;

  // ============================================
  // NOTIFICATION TEMPLATES
  // ============================================
  @odata.draft.enabled
  entity NotificationTemplates as projection on cfg.NotificationTemplates {
    *,
    placeholders : redirected to TemplatePlaceholders
  } actions {
    action preview(testData: String) returns { subject: String; body: String };
    action sendTest(recipientEmail: String) returns { success: Boolean; message: String };
  };

  entity TemplatePlaceholders as projection on cfg.TemplatePlaceholders;

  // ============================================
  // NUMBERING SERIES
  // ============================================
  @odata.draft.enabled
  entity NumberingSeries as projection on cfg.NumberingSeries {
    *,
    field : redirected to Fields
  } actions {
    action reset() returns NumberingSeries;
    action getNextNumber() returns String;
  };

  // ============================================
  // VALIDATION RULES
  // ============================================
  @odata.draft.enabled
  entity ValidationRules as projection on cfg.ValidationRules actions {
    action activate() returns ValidationRules;
    action deactivate() returns ValidationRules;
    action test(testData: String) returns { isValid: Boolean; message: String };
  };

  // ============================================
  // COST THRESHOLDS
  // ============================================
  @odata.draft.enabled
  entity CostThresholds as projection on cfg.CostThresholds {
    *,
    field : redirected to Fields
  };

  // ============================================
  // WORKFLOW DEFINITIONS
  // ============================================
  @odata.draft.enabled
  entity WorkflowDefinitions as projection on cfg.WorkflowDefinitions {
    *,
    steps : redirected to WorkflowSteps
  } actions {
    action activate() returns WorkflowDefinitions;
    action deactivate() returns WorkflowDefinitions;
    action validate() returns { isValid: Boolean; errors: array of String };
  };

  entity WorkflowSteps as projection on cfg.WorkflowSteps;

  // ============================================
  // REPORT DEFINITIONS
  // ============================================
  @odata.draft.enabled
  entity ReportDefinitions as projection on cfg.ReportDefinitions;

  // ============================================
  // REFERENCE ENTITIES
  // ============================================
  @readonly
  entity Fields as projection on master.Fields;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getAuditLogsByEntity(entityType: String, entityId: UUID) returns array of AuditLogs;
  function getAuditLogsByUser(userId: String, fromDate: Date, toDate: Date) returns array of AuditLogs;
  function getActiveSessions() returns array of Sessions;
  function getUsersByRole(roleCode: String) returns array of Users;
  function getApprovalMatrixForAFE(afeAmount: Decimal, wellType: String, fieldId: UUID) returns array of ApprovalMatrix;
  function getSystemConfig(configKey: String) returns SystemConfigurations;

  // ============================================
  // ACTIONS
  // ============================================
  action terminateAllSessions(userId: String) returns Integer;
  action exportAuditLogs(fromDate: Date, toDate: Date, format: String) returns LargeBinary;
  action importUsers(userData: String) returns { imported: Integer; failed: Integer; errors: array of String };
  action bulkAssignRole(userIds: array of String, roleCode: String, scopeType: String, scopeValue: String) returns Integer;
}
