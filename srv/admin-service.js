/**
 * Admin Service Handler
 * Implements CRUD operations for Security, Configuration, and Audit management
 */
const cds = require('@sap/cds');

module.exports = class AdminService extends cds.ApplicationService {

  async init() {
    const { AuditLogs, Users, Roles, RoleScopes, UserRoles, UserPreferences,
            Sessions, LoginHistory, ApprovalMatrix, ApprovalMatrixConditions,
            SystemConfigurations, NotificationTemplates, TemplatePlaceholders,
            NumberingSeries, ValidationRules, CostThresholds, WorkflowDefinitions,
            WorkflowSteps, ReportDefinitions } = this.entities;

    // ===========================================
    // USERS - CRUD Operations
    // ===========================================

    this.before('CREATE', Users, async (req) => {
      const { userId, userName, email } = req.data;

      if (!userId) {
        return req.error(400, 'User ID is required');
      }
      if (!userName) {
        return req.error(400, 'User name is required');
      }
      if (!email) {
        return req.error(400, 'Email is required');
      }

      // Check for duplicate
      const existing = await SELECT.one.from(Users).where({ userId });
      if (existing) {
        return req.error(409, `User with ID '${userId}' already exists`);
      }

      req.data.status = 'Active';
      req.data.isActive = true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', Users, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.before('DELETE', Users, async (req) => {
      const userId = req.data.ID;

      // Check for active sessions
      const activeSessions = await SELECT.one.from(Sessions).columns('count(*) as count')
        .where({ user_ID: userId, isActive: true });

      if (activeSessions && activeSessions.count > 0) {
        return req.error(400, 'Cannot delete user with active sessions. Deactivate instead.');
      }
    });

    // After all entity operations - Create audit log
    this.after(['CREATE', 'UPDATE', 'DELETE'], '*', async (data, req) => {
      if (req.target.name === 'AdminService.AuditLogs') return; // Don't audit the audit log

      const entityName = req.target.name.split('.').pop();
      const action = req.event.toUpperCase();

      await INSERT.into(AuditLogs).entries({
        entityType: entityName,
        entityId: data?.ID || req.data?.ID,
        action: action,
        userId: req.user.id,
        userName: req.user.id,
        timestamp: new Date(),
        oldValues: action === 'UPDATE' ? JSON.stringify(req.data) : null,
        newValues: action !== 'DELETE' ? JSON.stringify(data) : null,
        ipAddress: req.headers?.['x-forwarded-for'] || 'unknown'
      });
    });

    // Action: activate (user)
    this.on('activate', Users, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Users).set({
        status: 'Active',
        isActive: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Users).where({ ID });
    });

    // Action: deactivate (user)
    this.on('deactivate', Users, async (req) => {
      const { ID } = req.params[0];

      // Terminate all sessions
      await UPDATE(Sessions).set({ isActive: false, terminatedAt: new Date() })
        .where({ user_ID: ID, isActive: true });

      await UPDATE(Users).set({
        status: 'Inactive',
        isActive: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Users).where({ ID });
    });

    // Action: suspend (user)
    this.on('suspend', Users, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Sessions).set({ isActive: false, terminatedAt: new Date() })
        .where({ user_ID: ID, isActive: true });

      await UPDATE(Users).set({
        status: 'Suspended',
        isActive: false,
        suspendedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Users).where({ ID });
    });

    // Action: resetPassword
    this.on('resetPassword', Users, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Users).set({
        passwordResetRequired: true,
        passwordResetAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Users).where({ ID });
    });

    // ===========================================
    // ROLES - CRUD Operations
    // ===========================================

    this.before('CREATE', Roles, async (req) => {
      const { roleCode, roleName, roleType } = req.data;

      if (!roleCode) {
        return req.error(400, 'Role code is required');
      }
      if (!roleName) {
        return req.error(400, 'Role name is required');
      }

      const existing = await SELECT.one.from(Roles).where({ roleCode });
      if (existing) {
        return req.error(409, `Role with code '${roleCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', Roles, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.before('DELETE', Roles, async (req) => {
      const roleId = req.data.ID;

      // Check for user assignments
      const assignments = await SELECT.one.from(UserRoles).columns('count(*) as count')
        .where({ role_ID: roleId });

      if (assignments && assignments.count > 0) {
        return req.error(400, `Cannot delete role with ${assignments.count} user assignment(s)`);
      }
    });

    // ===========================================
    // ROLE SCOPES - CRUD Operations
    // ===========================================

    this.before('CREATE', RoleScopes, async (req) => {
      const { role_ID, scope } = req.data;

      if (!role_ID) {
        return req.error(400, 'Role reference is required');
      }
      if (!scope) {
        return req.error(400, 'Scope is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // ===========================================
    // USER ROLES - CRUD Operations
    // ===========================================

    this.before('CREATE', UserRoles, async (req) => {
      const { user_ID, role_ID } = req.data;

      if (!user_ID) {
        return req.error(400, 'User reference is required');
      }
      if (!role_ID) {
        return req.error(400, 'Role reference is required');
      }

      // Check for duplicate assignment
      const existing = await SELECT.one.from(UserRoles).where({ user_ID, role_ID });
      if (existing) {
        return req.error(409, 'User already has this role assigned');
      }

      req.data.assignedAt = new Date();
      req.data.assignedBy = req.user.id;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // ===========================================
    // USER PREFERENCES - CRUD Operations
    // ===========================================

    this.before('CREATE', UserPreferences, async (req) => {
      const { user_ID, preferenceKey } = req.data;

      if (!user_ID) {
        return req.error(400, 'User reference is required');
      }
      if (!preferenceKey) {
        return req.error(400, 'Preference key is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', UserPreferences, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // SESSIONS - Actions
    // ===========================================

    this.on('terminate', Sessions, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Sessions).set({
        isActive: false,
        terminatedAt: new Date(),
        terminatedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Sessions).where({ ID });
    });

    // ===========================================
    // APPROVAL MATRIX - CRUD Operations
    // ===========================================

    this.before('CREATE', ApprovalMatrix, async (req) => {
      const { matrixCode, matrixName, minAmount, maxAmount } = req.data;

      if (!matrixCode) {
        return req.error(400, 'Matrix code is required');
      }
      if (!matrixName) {
        return req.error(400, 'Matrix name is required');
      }

      const existing = await SELECT.one.from(ApprovalMatrix).where({ matrixCode });
      if (existing) {
        return req.error(409, `Approval matrix with code '${matrixCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', ApprovalMatrix, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // SYSTEM CONFIGURATIONS - CRUD Operations
    // ===========================================

    this.before('CREATE', SystemConfigurations, async (req) => {
      const { configKey, configValue, configType } = req.data;

      if (!configKey) {
        return req.error(400, 'Configuration key is required');
      }

      const existing = await SELECT.one.from(SystemConfigurations).where({ configKey });
      if (existing) {
        return req.error(409, `Configuration with key '${configKey}' already exists`);
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', SystemConfigurations, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // NOTIFICATION TEMPLATES - CRUD Operations
    // ===========================================

    this.before('CREATE', NotificationTemplates, async (req) => {
      const { templateCode, templateName, templateType } = req.data;

      if (!templateCode) {
        return req.error(400, 'Template code is required');
      }
      if (!templateName) {
        return req.error(400, 'Template name is required');
      }

      const existing = await SELECT.one.from(NotificationTemplates).where({ templateCode });
      if (existing) {
        return req.error(409, `Template with code '${templateCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', NotificationTemplates, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('preview', NotificationTemplates, async (req) => {
      const { ID } = req.params[0];
      const { testData } = req.data;

      const template = await SELECT.one.from(NotificationTemplates).where({ ID });
      if (!template) {
        return req.error(404, 'Template not found');
      }

      let subject = template.subject || '';
      let body = template.body || '';

      try {
        const data = JSON.parse(testData || '{}');

        // Replace placeholders
        for (const [key, value] of Object.entries(data)) {
          const placeholder = `{{${key}}}`;
          subject = subject.replace(new RegExp(placeholder, 'g'), value);
          body = body.replace(new RegExp(placeholder, 'g'), value);
        }
      } catch (e) {
        // Ignore parse errors
      }

      return { subject, body };
    });

    this.on('sendTest', NotificationTemplates, async (req) => {
      const { ID } = req.params[0];
      const { recipientEmail } = req.data;

      const template = await SELECT.one.from(NotificationTemplates).where({ ID });
      if (!template) {
        return req.error(404, 'Template not found');
      }

      // Simulate sending test email
      return {
        success: true,
        message: `Test notification sent to ${recipientEmail}`
      };
    });

    // ===========================================
    // NUMBERING SERIES - CRUD Operations
    // ===========================================

    this.before('CREATE', NumberingSeries, async (req) => {
      const { seriesCode, seriesName, entityType, prefix } = req.data;

      if (!seriesCode) {
        return req.error(400, 'Series code is required');
      }
      if (!entityType) {
        return req.error(400, 'Entity type is required');
      }

      const existing = await SELECT.one.from(NumberingSeries).where({ seriesCode });
      if (existing) {
        return req.error(409, `Series with code '${seriesCode}' already exists`);
      }

      req.data.currentNumber = req.data.startNumber || 1;
      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', NumberingSeries, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('reset', NumberingSeries, async (req) => {
      const { ID } = req.params[0];
      const series = await SELECT.one.from(NumberingSeries).where({ ID });

      if (!series) {
        return req.error(404, 'Numbering series not found');
      }

      await UPDATE(NumberingSeries).set({
        currentNumber: series.startNumber || 1,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(NumberingSeries).where({ ID });
    });

    this.on('getNextNumber', NumberingSeries, async (req) => {
      const { ID } = req.params[0];
      const series = await SELECT.one.from(NumberingSeries).where({ ID });

      if (!series) {
        return req.error(404, 'Numbering series not found');
      }

      const nextNumber = (series.currentNumber || 0) + 1;
      const paddedNumber = String(nextNumber).padStart(series.numberLength || 5, '0');
      const result = `${series.prefix || ''}${paddedNumber}${series.suffix || ''}`;

      // Increment the counter
      await UPDATE(NumberingSeries).set({
        currentNumber: nextNumber,
        modifiedAt: new Date()
      }).where({ ID });

      return result;
    });

    // ===========================================
    // VALIDATION RULES - CRUD Operations
    // ===========================================

    this.before('CREATE', ValidationRules, async (req) => {
      const { ruleCode, ruleName, entityType, ruleType } = req.data;

      if (!ruleCode) {
        return req.error(400, 'Rule code is required');
      }
      if (!ruleName) {
        return req.error(400, 'Rule name is required');
      }

      const existing = await SELECT.one.from(ValidationRules).where({ ruleCode });
      if (existing) {
        return req.error(409, `Rule with code '${ruleCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', ValidationRules, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('activate', ValidationRules, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(ValidationRules).set({
        isActive: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(ValidationRules).where({ ID });
    });

    this.on('deactivate', ValidationRules, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(ValidationRules).set({
        isActive: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(ValidationRules).where({ ID });
    });

    this.on('test', ValidationRules, async (req) => {
      const { ID } = req.params[0];
      const { testData } = req.data;

      const rule = await SELECT.one.from(ValidationRules).where({ ID });
      if (!rule) {
        return req.error(404, 'Rule not found');
      }

      // Similar to data quality rules test
      let isValid = true;
      let message = 'Validation passed';

      try {
        const data = JSON.parse(testData);

        switch (rule.ruleType) {
          case 'Required':
            isValid = data[rule.fieldName] !== undefined && data[rule.fieldName] !== null && data[rule.fieldName] !== '';
            message = isValid ? 'Required field is present' : `Field '${rule.fieldName}' is required`;
            break;
          case 'Range':
            const value = parseFloat(data[rule.fieldName]);
            const min = parseFloat(rule.minValue);
            const max = parseFloat(rule.maxValue);
            isValid = !isNaN(value) && value >= min && value <= max;
            message = isValid ? 'Value is within range' : `Value must be between ${min} and ${max}`;
            break;
          default:
            message = 'Rule type not supported for testing';
        }
      } catch (e) {
        isValid = false;
        message = `Error: ${e.message}`;
      }

      return { isValid, message };
    });

    // ===========================================
    // COST THRESHOLDS - CRUD Operations
    // ===========================================

    this.before('CREATE', CostThresholds, async (req) => {
      const { thresholdCode, thresholdName, thresholdType } = req.data;

      if (!thresholdCode) {
        return req.error(400, 'Threshold code is required');
      }
      if (!thresholdName) {
        return req.error(400, 'Threshold name is required');
      }

      const existing = await SELECT.one.from(CostThresholds).where({ thresholdCode });
      if (existing) {
        return req.error(409, `Threshold with code '${thresholdCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CostThresholds, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // WORKFLOW DEFINITIONS - CRUD Operations
    // ===========================================

    this.before('CREATE', WorkflowDefinitions, async (req) => {
      const { workflowCode, workflowName, entityType } = req.data;

      if (!workflowCode) {
        return req.error(400, 'Workflow code is required');
      }
      if (!workflowName) {
        return req.error(400, 'Workflow name is required');
      }

      const existing = await SELECT.one.from(WorkflowDefinitions).where({ workflowCode });
      if (existing) {
        return req.error(409, `Workflow with code '${workflowCode}' already exists`);
      }

      req.data.isActive = false;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', WorkflowDefinitions, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('activate', WorkflowDefinitions, async (req) => {
      const { ID } = req.params[0];

      // Validate workflow has steps
      const steps = await SELECT.from(WorkflowSteps).where({ workflow_ID: ID });
      if (steps.length === 0) {
        return req.error(400, 'Cannot activate workflow without steps');
      }

      await UPDATE(WorkflowDefinitions).set({
        isActive: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(WorkflowDefinitions).where({ ID });
    });

    this.on('deactivate', WorkflowDefinitions, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(WorkflowDefinitions).set({
        isActive: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(WorkflowDefinitions).where({ ID });
    });

    this.on('validate', WorkflowDefinitions, async (req) => {
      const { ID } = req.params[0];
      const workflow = await SELECT.one.from(WorkflowDefinitions).where({ ID });

      if (!workflow) {
        return req.error(404, 'Workflow not found');
      }

      const errors = [];
      const steps = await SELECT.from(WorkflowSteps).where({ workflow_ID: ID }).orderBy({ stepOrder: 'asc' });

      if (steps.length === 0) {
        errors.push('Workflow has no steps defined');
      }

      // Check for start step
      const hasStart = steps.some(s => s.stepType === 'Start');
      if (!hasStart) {
        errors.push('Workflow must have a Start step');
      }

      // Check for end step
      const hasEnd = steps.some(s => s.stepType === 'End');
      if (!hasEnd) {
        errors.push('Workflow must have an End step');
      }

      // Check step order continuity
      for (let i = 0; i < steps.length; i++) {
        if (steps[i].stepOrder !== i + 1) {
          errors.push(`Step order is not continuous at position ${i + 1}`);
          break;
        }
      }

      return {
        isValid: errors.length === 0,
        errors: errors
      };
    });

    // ===========================================
    // WORKFLOW STEPS - CRUD Operations
    // ===========================================

    this.before('CREATE', WorkflowSteps, async (req) => {
      const { workflow_ID, stepName, stepType, stepOrder } = req.data;

      if (!workflow_ID) {
        return req.error(400, 'Workflow reference is required');
      }
      if (!stepName) {
        return req.error(400, 'Step name is required');
      }
      if (!stepType) {
        return req.error(400, 'Step type is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', WorkflowSteps, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // REPORT DEFINITIONS - CRUD Operations
    // ===========================================

    this.before('CREATE', ReportDefinitions, async (req) => {
      const { reportCode, reportName, reportType } = req.data;

      if (!reportCode) {
        return req.error(400, 'Report code is required');
      }
      if (!reportName) {
        return req.error(400, 'Report name is required');
      }

      const existing = await SELECT.one.from(ReportDefinitions).where({ reportCode });
      if (existing) {
        return req.error(409, `Report with code '${reportCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', ReportDefinitions, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // SERVICE-LEVEL FUNCTIONS
    // ===========================================

    this.on('getAuditLogsByEntity', async (req) => {
      const { entityType, entityId } = req.data;
      return SELECT.from(AuditLogs)
        .where({ entityType, entityId })
        .orderBy({ timestamp: 'desc' });
    });

    this.on('getAuditLogsByUser', async (req) => {
      const { userId, fromDate, toDate } = req.data;
      return SELECT.from(AuditLogs)
        .where({
          userId,
          timestamp: { '>=': fromDate, '<=': toDate }
        })
        .orderBy({ timestamp: 'desc' });
    });

    this.on('getActiveSessions', async (req) => {
      return SELECT.from(Sessions).where({ isActive: true });
    });

    this.on('getUsersByRole', async (req) => {
      const { roleCode } = req.data;

      const role = await SELECT.one.from(Roles).where({ roleCode });
      if (!role) {
        return [];
      }

      const userRoles = await SELECT.from(UserRoles).where({ role_ID: role.ID });
      const userIds = userRoles.map(ur => ur.user_ID);

      if (userIds.length === 0) {
        return [];
      }

      return SELECT.from(Users).where({ ID: { in: userIds } });
    });

    this.on('getApprovalMatrixForAFE', async (req) => {
      const { afeAmount, wellType, fieldId } = req.data;

      let query = SELECT.from(ApprovalMatrix).where({
        isActive: true,
        minAmount: { '<=': afeAmount },
        maxAmount: { '>=': afeAmount }
      });

      if (wellType) {
        query = query.and({ wellType });
      }

      if (fieldId) {
        query = query.and({ 'field_ID': fieldId });
      }

      return query.orderBy({ approvalLevel: 'asc' });
    });

    this.on('getSystemConfig', async (req) => {
      const { configKey } = req.data;
      return SELECT.one.from(SystemConfigurations).where({ configKey });
    });

    // ===========================================
    // SERVICE-LEVEL ACTIONS
    // ===========================================

    this.on('terminateAllSessions', async (req) => {
      const { userId } = req.data;

      const result = await UPDATE(Sessions).set({
        isActive: false,
        terminatedAt: new Date(),
        terminatedBy: req.user.id
      }).where({ user_ID: userId, isActive: true });

      return result || 0;
    });

    this.on('exportAuditLogs', async (req) => {
      const { fromDate, toDate, format } = req.data;

      const logs = await SELECT.from(AuditLogs)
        .where({ timestamp: { '>=': fromDate, '<=': toDate } })
        .orderBy({ timestamp: 'desc' });

      // Return as buffer (actual implementation would format as CSV/Excel/PDF)
      return Buffer.from(JSON.stringify(logs, null, 2));
    });

    this.on('importUsers', async (req) => {
      const { userData } = req.data;

      let imported = 0;
      let failed = 0;
      const errors = [];

      try {
        const users = JSON.parse(userData);

        for (const user of users) {
          try {
            // Check if user exists
            const existing = await SELECT.one.from(Users).where({ userId: user.userId });
            if (existing) {
              errors.push(`User ${user.userId} already exists`);
              failed++;
              continue;
            }

            await INSERT.into(Users).entries({
              userId: user.userId,
              userName: user.userName,
              email: user.email,
              department: user.department,
              status: 'Active',
              isActive: true,
              createdAt: new Date(),
              createdBy: req.user.id
            });

            imported++;
          } catch (e) {
            errors.push(`Error importing ${user.userId}: ${e.message}`);
            failed++;
          }
        }
      } catch (e) {
        errors.push(`Error parsing user data: ${e.message}`);
      }

      return { imported, failed, errors };
    });

    this.on('bulkAssignRole', async (req) => {
      const { userIds, roleCode, scopeType, scopeValue } = req.data;

      const role = await SELECT.one.from(Roles).where({ roleCode });
      if (!role) {
        return req.error(404, `Role with code '${roleCode}' not found`);
      }

      let assigned = 0;

      for (const userId of userIds) {
        const user = await SELECT.one.from(Users).where({ userId });
        if (!user) continue;

        // Check if already assigned
        const existing = await SELECT.one.from(UserRoles).where({ user_ID: user.ID, role_ID: role.ID });
        if (existing) continue;

        await INSERT.into(UserRoles).entries({
          user_ID: user.ID,
          role_ID: role.ID,
          scopeType: scopeType || 'Global',
          scopeValue: scopeValue,
          assignedAt: new Date(),
          assignedBy: req.user.id,
          createdAt: new Date(),
          createdBy: req.user.id
        });

        assigned++;
      }

      return assigned;
    });

    await super.init();
  }
};
