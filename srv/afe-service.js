const cds = require('@sap/cds');

module.exports = class AFEService extends cds.ApplicationService {

  async init() {
    const { AFEs, AFELineItems, Approvals, CostEstimates, WBSElements } = this.entities;

    // ============================================
    // AFE CRUD
    // ============================================
    this.before('CREATE', AFEs, async (req) => {
      // Auto-generate AFE number if not provided
      if (!req.data.afeNumber) {
        req.data.afeNumber = await generateAFENumber(req.data.well_ID);
      }
      // Set defaults
      if (!req.data.approvalStatus) req.data.approvalStatus = 'Draft';
      if (!req.data.status) req.data.status = 'Active';
      if (!req.data.versionNumber) req.data.versionNumber = 1;

      // Validate
      if (req.data.afeType === 'Supplement' && !req.data.parentAFE_ID) {
        req.error(400, 'Supplement AFE requires a parent AFE');
      }
      if (req.data.contingencyPct && (req.data.contingencyPct < 0 || req.data.contingencyPct > 50)) {
        req.error(400, 'Contingency percentage must be between 0 and 50');
      }
    });

    this.before('UPDATE', AFEs, async (req) => {
      const { ID, approvalStatus } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID });
      if (afe?.approvalStatus === 'Approved' && approvalStatus !== 'Closed') {
        req.error(400, 'Cannot modify an approved AFE');
      }
    });

    this.before('DELETE', AFEs, async (req) => {
      const { ID } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID });
      if (afe?.approvalStatus !== 'Draft') {
        req.error(400, 'Only draft AFEs can be deleted');
      }
    });

    this.after('READ', AFEs, (data) => {
      if (Array.isArray(data)) data.forEach(calculateAFETotals);
      else if (data) calculateAFETotals(data);
    });

    // ============================================
    // AFE LINE ITEMS CRUD
    // ============================================
    this.before('CREATE', AFELineItems, async (req) => {
      // Calculate estimated amount
      if (req.data.quantity && req.data.unitRate) {
        req.data.estimatedAmount = req.data.quantity * req.data.unitRate;
      }
    });

    this.before('UPDATE', AFELineItems, async (req) => {
      if (req.data.quantity && req.data.unitRate) {
        req.data.estimatedAmount = req.data.quantity * req.data.unitRate;
      }
    });

    // ============================================
    // COST ESTIMATES CRUD
    // ============================================
    this.before('CREATE', CostEstimates, async (req) => {
      if (req.data.quantity && req.data.unitRate) {
        req.data.estimatedAmount = req.data.quantity * req.data.unitRate;
      }
    });

    // ============================================
    // APPROVALS CRUD
    // ============================================
    this.before('CREATE', Approvals, async (req) => {
      if (!req.data.actionStatus) req.data.actionStatus = 'Pending';
      if (!req.data.assignedDate) req.data.assignedDate = new Date().toISOString();
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('submitForApproval', async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });
      if (!afe) req.error(404, 'AFE not found');
      if (afe.approvalStatus !== 'Draft') req.error(400, 'Only draft AFEs can be submitted');

      await UPDATE(AFEs).set({ approvalStatus: 'Pending' }).where({ ID });
      return SELECT.one.from(AFEs).where({ ID });
    });

    this.on('approve', async (req) => {
      const { ID } = req.params[0];
      const { comments } = req.data || {};
      const afe = await SELECT.one.from(AFEs).where({ ID });
      if (!afe) req.error(404, 'AFE not found');
      if (afe.approvalStatus !== 'Pending') req.error(400, 'Only pending AFEs can be approved');

      await UPDATE(AFEs).set({
        approvalStatus: 'Approved',
        approvedDate: new Date().toISOString(),
        approvedBy: req.user.id
      }).where({ ID });
      return SELECT.one.from(AFEs).where({ ID });
    });

    this.on('reject', async (req) => {
      const { ID } = req.params[0];
      const { reason } = req.data || {};
      const afe = await SELECT.one.from(AFEs).where({ ID });
      if (!afe) req.error(404, 'AFE not found');
      if (afe.approvalStatus !== 'Pending') req.error(400, 'Only pending AFEs can be rejected');

      await UPDATE(AFEs).set({ approvalStatus: 'Rejected' }).where({ ID });
      return SELECT.one.from(AFEs).where({ ID });
    });

    this.on('revise', async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });
      if (!afe) req.error(404, 'AFE not found');

      // Create new version
      const newAFE = {
        ...afe,
        ID: cds.utils.uuid(),
        afeType: 'Revision',
        parentAFE_ID: ID,
        versionNumber: afe.versionNumber + 1,
        approvalStatus: 'Draft',
        approvedDate: null,
        approvedBy: null
      };
      await INSERT.into(AFEs).entries(newAFE);
      return SELECT.one.from(AFEs).where({ ID: newAFE.ID });
    });

    this.on('close', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(AFEs).set({ status: 'Closed' }).where({ ID });
      return SELECT.one.from(AFEs).where({ ID });
    });

    this.on('cancel', async (req) => {
      const { ID } = req.params[0];
      const { reason } = req.data || {};
      await UPDATE(AFEs).set({ status: 'Cancelled' }).where({ ID });
      return SELECT.one.from(AFEs).where({ ID });
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getAFEsByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(AFEs).where({ well_ID: wellId });
    });

    this.on('getAFEsByStatus', async (req) => {
      const { status } = req.data;
      return SELECT.from(AFEs).where({ approvalStatus: status });
    });

    this.on('getPendingApprovals', async (req) => {
      const userId = req.user.id;
      return SELECT.from(Approvals).where({ approverUserId: userId, actionStatus: 'Pending' });
    });

    this.on('getAFESummary', async (req) => {
      const { afeId } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });
      const lineItems = await SELECT.from(AFELineItems).where({ afe_ID: afeId });
      const estimates = await SELECT.from(CostEstimates).where({ afe_ID: afeId });

      const totalEstimated = lineItems.reduce((sum, li) => sum + (li.estimatedAmount || 0), 0);

      return {
        ...afe,
        totalEstimated,
        lineItemCount: lineItems.length,
        estimateCount: estimates.length
      };
    });

    await super.init();
  }
};

// Helper functions
async function generateAFENumber(wellId) {
  const year = new Date().getFullYear();
  const seq = Math.floor(Math.random() * 9999).toString().padStart(4, '0');
  return `AFE-${year}-${seq}`;
}

function calculateAFETotals(afe) {
  if (afe && afe.estimatedCost && afe.contingencyPct) {
    afe.contingencyAmount = afe.estimatedCost * (afe.contingencyPct / 100);
    afe.totalBudget = afe.estimatedCost + afe.contingencyAmount;
  }
}
