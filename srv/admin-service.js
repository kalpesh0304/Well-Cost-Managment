const cds = require('@sap/cds');

module.exports = class AdminService extends cds.ApplicationService {

  async init() {
    const { Users, Roles, UserRoles, AuditLogs, Sessions, ApprovalMatrix, SystemConfigurations, NotificationTemplates } = this.entities;

    // ============================================
    // USERS CRUD
    // ============================================
    this.before('CREATE', Users, async (req) => {
      const { userId } = req.data;
      const exists = await SELECT.one.from(Users).where({ userId });
      if (exists) req.error(409, `User ${userId} already exists`);
      if (!req.data.status) req.data.status = 'Active';
    });

    // ============================================
    // ROLES CRUD
    // ============================================
    this.before('CREATE', Roles, async (req) => {
      const { roleCode } = req.data;
      const exists = await SELECT.one.from(Roles).where({ roleCode });
      if (exists) req.error(409, `Role ${roleCode} already exists`);
    });

    // ============================================
    // USER ROLES CRUD
    // ============================================
    this.before('CREATE', UserRoles, async (req) => {
      if (!req.data.effectiveFromDate) {
        req.data.effectiveFromDate = new Date().toISOString().split('T')[0];
      }
      req.data.assignedBy = req.user.id;
      req.data.assignedAt = new Date().toISOString();
    });

    // ============================================
    // APPROVAL MATRIX CRUD
    // ============================================
    this.before('CREATE', ApprovalMatrix, async (req) => {
      // Validate amount range
      if (req.data.amountFrom >= req.data.amountTo) {
        req.error(400, 'Amount range invalid: amountFrom must be less than amountTo');
      }
    });

    // ============================================
    // SYSTEM CONFIGURATIONS CRUD
    // ============================================
    this.before('UPDATE', SystemConfigurations, async (req) => {
      req.data.modifiedBy = req.user.id;
      req.data.modifiedAt = new Date().toISOString();
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('activate', Users, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Users).set({ status: 'Active' }).where({ ID });
      return SELECT.one.from(Users).where({ ID });
    });

    this.on('deactivate', Users, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Users).set({ status: 'Inactive' }).where({ ID });
      return SELECT.one.from(Users).where({ ID });
    });

    this.on('suspend', Users, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Users).set({ status: 'Suspended' }).where({ ID });
      return SELECT.one.from(Users).where({ ID });
    });

    this.on('terminateAllSessions', async (req) => {
      const { userId } = req.data;
      const result = await DELETE.from(Sessions).where({ user_ID: userId });
      return result;
    });

    this.on('bulkAssignRole', async (req) => {
      const { userIds, roleCode, scopeType, scopeValue } = req.data;
      const role = await SELECT.one.from(Roles).where({ roleCode });
      if (!role) req.error(404, `Role ${roleCode} not found`);

      let count = 0;
      for (const userId of userIds) {
        const user = await SELECT.one.from(Users).where({ userId });
        if (user) {
          await INSERT.into(UserRoles).entries({
            ID: cds.utils.uuid(),
            user_ID: user.ID,
            role_ID: role.ID,
            scopeType,
            scopeValue,
            effectiveFromDate: new Date().toISOString().split('T')[0],
            assignedBy: req.user.id,
            assignedAt: new Date().toISOString()
          });
          count++;
        }
      }
      return count;
    });

    this.on('exportAuditLogs', async (req) => {
      const { fromDate, toDate, format } = req.data;
      const logs = await SELECT.from(AuditLogs).where({
        timestamp: { between: fromDate, and: toDate }
      });
      // Return as JSON (simplified)
      return Buffer.from(JSON.stringify(logs, null, 2));
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getAuditLogsByEntity', async (req) => {
      const { entityType, entityId } = req.data;
      return SELECT.from(AuditLogs).where({ entityType, entityId }).orderBy('timestamp desc');
    });

    this.on('getAuditLogsByUser', async (req) => {
      const { userId, fromDate, toDate } = req.data;
      return SELECT.from(AuditLogs).where({
        userId,
        timestamp: { between: fromDate, and: toDate }
      }).orderBy('timestamp desc');
    });

    this.on('getActiveSessions', async () => {
      return SELECT.from(Sessions).where({ isActive: true });
    });

    this.on('getUsersByRole', async (req) => {
      const { roleCode } = req.data;
      const role = await SELECT.one.from(Roles).where({ roleCode });
      if (!role) return [];

      const userRoles = await SELECT.from(UserRoles).where({ role_ID: role.ID });
      const userIds = userRoles.map(ur => ur.user_ID);
      return SELECT.from(Users).where({ ID: { in: userIds } });
    });

    this.on('getApprovalMatrixForAFE', async (req) => {
      const { afeAmount, wellType, fieldId } = req.data;
      return SELECT.from(ApprovalMatrix).where({
        amountFrom: { '<=': afeAmount },
        amountTo: { '>=': afeAmount },
        isActive: true
      }).orderBy('approvalLevel');
    });

    this.on('getSystemConfig', async (req) => {
      const { configKey } = req.data;
      return SELECT.one.from(SystemConfigurations).where({ configKey });
    });

    await super.init();
  }
};
