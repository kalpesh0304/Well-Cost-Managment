/**
 * AFE (Authorization for Expenditure) Service Handler
 * Implements CRUD operations and custom actions for AFE management
 */
const cds = require('@sap/cds');

module.exports = class AFEService extends cds.ApplicationService {

  async init() {
    const { AFEs, AFELineItems, WBSElements, CostEstimates, Approvals, AFEDocuments } = this.entities;

    // ===========================================
    // AFEs - CRUD Operations
    // ===========================================

    // Before CREATE - Validate and set defaults
    this.before('CREATE', AFEs, async (req) => {
      const { afeNumber, afeTitle, well_ID, afeType, estimatedCost } = req.data;

      if (!afeTitle) {
        return req.error(400, 'AFE title is required');
      }
      if (!well_ID) {
        return req.error(400, 'Well is required');
      }
      if (!estimatedCost || estimatedCost <= 0) {
        return req.error(400, 'Valid estimated cost is required');
      }

      // Auto-generate AFE number if not provided
      if (!afeNumber) {
        const countResult = await SELECT.one.from(AFEs).columns('count(*) as count');
        const count = (countResult?.count || 0) + 1;
        req.data.afeNumber = `AFE-${new Date().getFullYear()}-${String(count).padStart(5, '0')}`;
      } else {
        // Check for duplicate
        const existing = await SELECT.one.from(AFEs).where({ afeNumber });
        if (existing) {
          return req.error(409, `AFE with number '${afeNumber}' already exists`);
        }
      }

      // Set defaults
      req.data.status = 'Draft';
      req.data.afeType = afeType || 'Original';
      req.data.approvedCost = 0;
      req.data.actualCost = 0;
      req.data.committedCost = 0;
      req.data.varianceAmount = 0;
      req.data.variancePct = 0;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // Before UPDATE - Validate status transitions and audit
    this.before('UPDATE', AFEs, async (req) => {
      const { ID } = req.data;

      if (ID) {
        const current = await SELECT.one.from(AFEs).where({ ID });
        if (current) {
          // Prevent updates to approved/closed AFEs (except by admins)
          const lockedStatuses = ['Approved', 'Closed', 'Cancelled'];
          if (lockedStatuses.includes(current.status) && !req.user.is('Admin')) {
            return req.error(403, `Cannot modify AFE in '${current.status}' status`);
          }
        }
      }

      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Before DELETE - Prevent deletion of non-draft AFEs
    this.before('DELETE', AFEs, async (req) => {
      const afeId = req.data.ID;
      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });

      if (afe && afe.status !== 'Draft') {
        return req.error(400, 'Only Draft AFEs can be deleted. Cancel the AFE instead.');
      }
    });

    // After READ - Calculate variance
    this.after('READ', AFEs, async (data, req) => {
      if (!data) return;
      const afes = Array.isArray(data) ? data : [data];

      for (const afe of afes) {
        if (afe.estimatedCost && afe.actualCost !== undefined) {
          afe.varianceAmount = afe.actualCost - afe.estimatedCost;
          afe.variancePct = afe.estimatedCost > 0
            ? ((afe.actualCost - afe.estimatedCost) / afe.estimatedCost) * 100
            : 0;
        }
      }
    });

    // ===========================================
    // AFE LIFECYCLE ACTIONS
    // ===========================================

    // Action: submitForApproval
    this.on('submitForApproval', AFEs, async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Draft' && afe.status !== 'Revision') {
        return req.error(400, `Cannot submit AFE in '${afe.status}' status`);
      }

      // Validate AFE has line items
      const lineItemCount = await SELECT.one.from(AFELineItems).columns('count(*) as count').where({ afe_ID: ID });
      if (!lineItemCount || lineItemCount.count === 0) {
        return req.error(400, 'AFE must have at least one line item before submission');
      }

      await UPDATE(AFEs).set({
        status: 'Pending Approval',
        submittedAt: new Date(),
        submittedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      // Create approval record
      await INSERT.into(Approvals).entries({
        afe_ID: ID,
        approverUserId: null, // To be assigned based on approval matrix
        approverLevel: 1,
        status: 'Pending',
        requestedAt: new Date()
      });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: approve
    this.on('approve', AFEs, async (req) => {
      const { ID } = req.params[0];
      const { comments, conditions } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Pending Approval') {
        return req.error(400, `Cannot approve AFE in '${afe.status}' status`);
      }

      await UPDATE(AFEs).set({
        status: 'Approved',
        approvedCost: afe.estimatedCost,
        approvedAt: new Date(),
        approvedBy: req.user.id,
        approvalConditions: conditions || null,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      // Update approval record
      await UPDATE(Approvals).set({
        status: 'Approved',
        comments: comments,
        decidedAt: new Date()
      }).where({ afe_ID: ID, status: 'Pending' });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: reject
    this.on('reject', AFEs, async (req) => {
      const { ID } = req.params[0];
      const { comments } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Pending Approval') {
        return req.error(400, `Cannot reject AFE in '${afe.status}' status`);
      }

      await UPDATE(AFEs).set({
        status: 'Rejected',
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      await UPDATE(Approvals).set({
        status: 'Rejected',
        comments: comments,
        decidedAt: new Date()
      }).where({ afe_ID: ID, status: 'Pending' });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: returnForRevision
    this.on('returnForRevision', AFEs, async (req) => {
      const { ID } = req.params[0];
      const { comments } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Pending Approval') {
        return req.error(400, `Cannot return AFE in '${afe.status}' status`);
      }

      await UPDATE(AFEs).set({
        status: 'Revision',
        revisionComments: comments,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: activate
    this.on('activate', AFEs, async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Approved') {
        return req.error(400, 'Only Approved AFEs can be activated');
      }

      await UPDATE(AFEs).set({
        status: 'Active',
        activatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: close
    this.on('close', AFEs, async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Active') {
        return req.error(400, 'Only Active AFEs can be closed');
      }

      await UPDATE(AFEs).set({
        status: 'Closed',
        closedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: cancel
    this.on('cancel', AFEs, async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status === 'Closed' || afe.status === 'Cancelled') {
        return req.error(400, `AFE is already ${afe.status}`);
      }

      await UPDATE(AFEs).set({
        status: 'Cancelled',
        cancelledAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: createSupplement
    this.on('createSupplement', AFEs, async (req) => {
      const { ID } = req.params[0];
      const { estimatedCost, justification } = req.data;
      const parentAFE = await SELECT.one.from(AFEs).where({ ID });

      if (!parentAFE) {
        return req.error(404, 'Parent AFE not found');
      }
      if (parentAFE.status !== 'Active' && parentAFE.status !== 'Approved') {
        return req.error(400, 'Can only create supplement for Active or Approved AFEs');
      }

      // Count existing supplements
      const suppCount = await SELECT.one.from(AFEs).columns('count(*) as count').where({ parentAFE_ID: ID });
      const suppNumber = (suppCount?.count || 0) + 1;

      const supplement = {
        afeNumber: `${parentAFE.afeNumber}-S${suppNumber}`,
        afeTitle: `${parentAFE.afeTitle} - Supplement ${suppNumber}`,
        afeType: 'Supplement',
        well_ID: parentAFE.well_ID,
        parentAFE_ID: ID,
        estimatedCost: estimatedCost,
        justification: justification,
        currency_code: parentAFE.currency_code,
        status: 'Draft',
        approvedCost: 0,
        actualCost: 0,
        committedCost: 0,
        createdAt: new Date(),
        createdBy: req.user.id
      };

      const result = await INSERT.into(AFEs).entries(supplement);
      return SELECT.one.from(AFEs).where({ afeNumber: supplement.afeNumber });
    });

    // Action: createS4Project
    this.on('createS4Project', AFEs, async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }

      // Simulate S/4HANA project creation
      const s4ProjectId = `PRJ-${afe.afeNumber}`;

      await UPDATE(AFEs).set({
        s4hanaProjectId: s4ProjectId,
        s4hanaSyncStatus: 'Synced',
        s4hanaLastSyncAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: reserveBudget
    this.on('reserveBudget', AFEs, async (req) => {
      const { ID } = req.params[0];
      const afe = await SELECT.one.from(AFEs).where({ ID });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }
      if (afe.status !== 'Approved' && afe.status !== 'Active') {
        return req.error(400, 'Budget can only be reserved for Approved or Active AFEs');
      }

      await UPDATE(AFEs).set({
        budgetReserved: true,
        budgetReservedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: copyFromTemplate
    this.on('copyFromTemplate', AFEs, async (req) => {
      const { ID } = req.params[0];
      const { templateId } = req.data;

      // Get template elements
      const db = await cds.connect.to('db');
      const { WBSTemplateElements } = db.entities('wcm.master');
      const templateElements = await SELECT.from(WBSTemplateElements).where({ template_ID: templateId });

      if (templateElements.length === 0) {
        return req.error(400, 'Template has no elements');
      }

      // Create WBS elements from template
      for (const elem of templateElements) {
        await INSERT.into(WBSElements).entries({
          afe_ID: ID,
          elementCode: elem.elementCode,
          elementName: elem.elementName,
          level: elem.level,
          sortOrder: elem.sortOrder,
          budgetedCost: 0,
          actualCost: 0,
          committedCost: 0
        });
      }

      return SELECT.one.from(AFEs).where({ ID });
    });

    // Action: generateReport
    this.on('generateReport', AFEs, async (req) => {
      const { ID } = req.params[0];
      const { format } = req.data;

      // Return placeholder - actual report generation would go here
      return Buffer.from(`AFE Report for ${ID} in ${format || 'PDF'} format`);
    });

    // ===========================================
    // AFE LINE ITEMS - CRUD Operations
    // ===========================================

    this.before('CREATE', AFELineItems, async (req) => {
      const { afe_ID, costElement_ID, description, quantity, unitCost } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }
      if (!description) {
        return req.error(400, 'Description is required');
      }

      // Calculate total cost
      if (quantity && unitCost) {
        req.data.totalCost = quantity * unitCost;
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', AFELineItems, async (req) => {
      // Recalculate total cost
      if (req.data.quantity !== undefined && req.data.unitCost !== undefined) {
        req.data.totalCost = req.data.quantity * req.data.unitCost;
      }
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // After CREATE/UPDATE line items - Update AFE totals
    this.after(['CREATE', 'UPDATE', 'DELETE'], AFELineItems, async (data, req) => {
      const afeId = data?.afe_ID || req.data?.afe_ID;
      if (afeId) {
        await this._updateAFETotals(afeId);
      }
    });

    // ===========================================
    // WBS ELEMENTS - CRUD Operations
    // ===========================================

    this.before('CREATE', WBSElements, async (req) => {
      const { afe_ID, elementCode, elementName } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }
      if (!elementCode) {
        return req.error(400, 'Element code is required');
      }
      if (!elementName) {
        return req.error(400, 'Element name is required');
      }

      // Check for duplicate within AFE
      const existing = await SELECT.one.from(WBSElements).where({ afe_ID, elementCode });
      if (existing) {
        return req.error(409, `WBS element '${elementCode}' already exists for this AFE`);
      }

      req.data.budgetedCost = req.data.budgetedCost || 0;
      req.data.actualCost = 0;
      req.data.committedCost = 0;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', WBSElements, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // COST ESTIMATES - CRUD Operations
    // ===========================================

    this.before('CREATE', CostEstimates, async (req) => {
      const { afe_ID, estimateType, amount } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }
      if (!amount || amount <= 0) {
        return req.error(400, 'Valid amount is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CostEstimates, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('copyToBenchmark', CostEstimates, async (req) => {
      const { ID } = req.params[0];
      const estimate = await SELECT.one.from(CostEstimates).where({ ID });

      if (!estimate) {
        return req.error(404, 'Cost estimate not found');
      }

      // Create benchmark copy
      const benchmark = {
        ...estimate,
        ID: undefined,
        estimateType: 'Benchmark',
        sourceEstimate_ID: ID,
        createdAt: new Date(),
        createdBy: req.user.id
      };

      await INSERT.into(CostEstimates).entries(benchmark);
      return SELECT.one.from(CostEstimates).where({ ID });
    });

    // ===========================================
    // APPROVALS - CRUD Operations
    // ===========================================

    this.before('CREATE', Approvals, async (req) => {
      req.data.status = 'Pending';
      req.data.requestedAt = new Date();
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.on('delegate', Approvals, async (req) => {
      const { ID } = req.params[0];
      const { toUserId, toUserName } = req.data;

      await UPDATE(Approvals).set({
        delegatedTo: toUserId,
        delegatedToName: toUserName,
        delegatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Approvals).where({ ID });
    });

    this.on('escalate', Approvals, async (req) => {
      const { ID } = req.params[0];
      const approval = await SELECT.one.from(Approvals).where({ ID });

      if (!approval) {
        return req.error(404, 'Approval not found');
      }

      await UPDATE(Approvals).set({
        isEscalated: true,
        escalatedAt: new Date(),
        approverLevel: (approval.approverLevel || 1) + 1,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Approvals).where({ ID });
    });

    // ===========================================
    // AFE DOCUMENTS - CRUD Operations
    // ===========================================

    this.before('CREATE', AFEDocuments, async (req) => {
      const { afe_ID, fileName, documentType } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }
      if (!fileName) {
        return req.error(400, 'File name is required');
      }

      req.data.uploadedAt = new Date();
      req.data.uploadedBy = req.user.id;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // ===========================================
    // FUNCTIONS
    // ===========================================

    this.on('getAFEsByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(AFEs).where({ well_ID: wellId });
    });

    this.on('getAFEsByStatus', async (req) => {
      const { status } = req.data;
      return SELECT.from(AFEs).where({ status });
    });

    this.on('getPendingApprovals', async (req) => {
      const { userId } = req.data;
      return SELECT.from(Approvals).where({ approverUserId: userId, status: 'Pending' });
    });

    this.on('getMyPendingApprovals', async (req) => {
      return SELECT.from(Approvals).where({ approverUserId: req.user.id, status: 'Pending' });
    });

    this.on('getAFESummary', async (req) => {
      const { afeId } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });

      if (!afe) {
        return req.error(404, 'AFE not found');
      }

      return {
        estimatedTotal: afe.estimatedCost || 0,
        actualTotal: afe.actualCost || 0,
        committedTotal: afe.committedCost || 0,
        varianceAmount: (afe.actualCost || 0) - (afe.estimatedCost || 0),
        variancePct: afe.estimatedCost > 0
          ? (((afe.actualCost || 0) - afe.estimatedCost) / afe.estimatedCost) * 100
          : 0
      };
    });

    this.on('validateAFE', async (req) => {
      const { afeId } = req.data;
      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });
      const errors = [];

      if (!afe) {
        return [{ ruleCode: 'AFE_NOT_FOUND', severity: 'Error', message: 'AFE not found' }];
      }

      // Validate required fields
      if (!afe.afeTitle) {
        errors.push({ ruleCode: 'TITLE_REQUIRED', severity: 'Error', message: 'AFE title is required' });
      }
      if (!afe.estimatedCost || afe.estimatedCost <= 0) {
        errors.push({ ruleCode: 'COST_REQUIRED', severity: 'Error', message: 'Valid estimated cost is required' });
      }

      // Validate line items exist
      const lineItemCount = await SELECT.one.from(AFELineItems).columns('count(*) as count').where({ afe_ID: afeId });
      if (!lineItemCount || lineItemCount.count === 0) {
        errors.push({ ruleCode: 'LINE_ITEMS_REQUIRED', severity: 'Warning', message: 'AFE has no line items' });
      }

      // Check variance threshold
      if (afe.variancePct && Math.abs(afe.variancePct) > 10) {
        errors.push({
          ruleCode: 'VARIANCE_THRESHOLD',
          severity: 'Warning',
          message: `Variance of ${afe.variancePct.toFixed(2)}% exceeds 10% threshold`
        });
      }

      return errors;
    });

    // ===========================================
    // HELPER METHODS
    // ===========================================

    this._updateAFETotals = async (afeId) => {
      const lineItems = await SELECT.from(AFELineItems).where({ afe_ID: afeId });
      const totalEstimated = lineItems.reduce((sum, item) => sum + (item.totalCost || 0), 0);

      await UPDATE(AFEs).set({
        estimatedCost: totalEstimated,
        modifiedAt: new Date()
      }).where({ ID: afeId });
    };

    await super.init();
  }
};
