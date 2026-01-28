/**
 * Financial Service Handler
 * Implements CRUD operations for Cost Actuals, Commitments, JIB, and Partner Interests
 */
const cds = require('@sap/cds');

module.exports = class FinancialService extends cds.ApplicationService {

  async init() {
    const { CostActuals, Commitments, PartnerInterests, JIBStatements, JIBLineItems,
            Variances, VarianceCategories, CostAllocations } = this.entities;

    // ===========================================
    // COST ACTUALS - CRUD Operations
    // ===========================================

    this.before('CREATE', CostActuals, async (req) => {
      const { afe_ID, wbsElement_ID, costElement_ID, amount, postingDate } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }
      if (!amount || amount <= 0) {
        return req.error(400, 'Valid amount is required');
      }
      if (!postingDate) {
        return req.error(400, 'Posting date is required');
      }

      // Auto-generate document number
      const countResult = await SELECT.one.from(CostActuals).columns('count(*) as count');
      const count = (countResult?.count || 0) + 1;
      req.data.documentNumber = req.data.documentNumber || `CA-${new Date().getFullYear()}-${String(count).padStart(6, '0')}`;

      req.data.isReversed = false;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CostActuals, async (req) => {
      const { ID } = req.data;

      if (ID) {
        const current = await SELECT.one.from(CostActuals).where({ ID });
        if (current?.isReversed) {
          return req.error(400, 'Cannot modify reversed cost actual');
        }
      }

      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.before('DELETE', CostActuals, async (req) => {
      const costActualId = req.data.ID;
      const costActual = await SELECT.one.from(CostActuals).where({ ID: costActualId });

      if (costActual?.s4hanaSyncStatus === 'Synced') {
        return req.error(400, 'Cannot delete cost actual synced to S/4HANA. Create a reversal instead.');
      }
    });

    // After CREATE - Update AFE actuals
    this.after('CREATE', CostActuals, async (data, req) => {
      if (data?.afe_ID) {
        await this._updateAFEActuals(data.afe_ID);
      }
    });

    // Action: reversePosting
    this.on('reversePosting', CostActuals, async (req) => {
      const { ID } = req.params[0];
      const { reason } = req.data;
      const costActual = await SELECT.one.from(CostActuals).where({ ID });

      if (!costActual) {
        return req.error(404, 'Cost actual not found');
      }
      if (costActual.isReversed) {
        return req.error(400, 'Cost actual is already reversed');
      }

      // Create reversal entry
      const reversal = {
        ...costActual,
        ID: undefined,
        amount: -costActual.amount,
        documentNumber: `${costActual.documentNumber}-REV`,
        reversalOf_ID: ID,
        reversalReason: reason,
        postingDate: new Date(),
        createdAt: new Date(),
        createdBy: req.user.id
      };

      await INSERT.into(CostActuals).entries(reversal);

      // Mark original as reversed
      await UPDATE(CostActuals).set({
        isReversed: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      // Update AFE actuals
      await this._updateAFEActuals(costActual.afe_ID);

      return SELECT.one.from(CostActuals).where({ ID });
    });

    // Action: reallocate
    this.on('reallocate', CostActuals, async (req) => {
      const { ID } = req.params[0];
      const { newAfeId, newWbsElementId } = req.data;
      const costActual = await SELECT.one.from(CostActuals).where({ ID });

      if (!costActual) {
        return req.error(404, 'Cost actual not found');
      }

      const oldAfeId = costActual.afe_ID;

      await UPDATE(CostActuals).set({
        afe_ID: newAfeId,
        wbsElement_ID: newWbsElementId,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      // Update both old and new AFE actuals
      await this._updateAFEActuals(oldAfeId);
      await this._updateAFEActuals(newAfeId);

      return SELECT.one.from(CostActuals).where({ ID });
    });

    // ===========================================
    // COMMITMENTS - CRUD Operations
    // ===========================================

    this.before('CREATE', Commitments, async (req) => {
      const { afe_ID, poNumber, amount } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }
      if (!poNumber) {
        return req.error(400, 'PO number is required');
      }
      if (!amount || amount <= 0) {
        return req.error(400, 'Valid amount is required');
      }

      req.data.status = 'Open';
      req.data.consumedAmount = 0;
      req.data.remainingAmount = amount;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', Commitments, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // After CREATE - Update AFE commitments
    this.after('CREATE', Commitments, async (data, req) => {
      if (data?.afe_ID) {
        await this._updateAFECommitments(data.afe_ID);
      }
    });

    // Action: refreshFromS4HANA
    this.on('refreshFromS4HANA', Commitments, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Commitments).set({
        s4hanaSyncStatus: 'Synced',
        s4hanaLastSyncAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Commitments).where({ ID });
    });

    // Action: closeCommitment
    this.on('closeCommitment', Commitments, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Commitments).set({
        status: 'Closed',
        closedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Commitments).where({ ID });
    });

    // ===========================================
    // PARTNER INTERESTS - CRUD Operations
    // ===========================================

    this.before('CREATE', PartnerInterests, async (req) => {
      const { well_ID, partner_ID, workingInterest } = req.data;

      if (!well_ID) {
        return req.error(400, 'Well reference is required');
      }
      if (!partner_ID) {
        return req.error(400, 'Partner reference is required');
      }
      if (!workingInterest || workingInterest <= 0 || workingInterest > 100) {
        return req.error(400, 'Working interest must be between 0 and 100');
      }

      // Check total working interest doesn't exceed 100%
      const existingWI = await SELECT.one.from(PartnerInterests)
        .columns('sum(workingInterest) as total')
        .where({ well_ID });

      if (existingWI && (existingWI.total || 0) + workingInterest > 100) {
        return req.error(400, `Total working interest would exceed 100% (current: ${existingWI.total}%)`);
      }

      req.data.netRevenueInterest = req.data.netRevenueInterest || workingInterest;
      req.data.consentStatus = 'Pending';
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', PartnerInterests, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Action: grantConsent
    this.on('grantConsent', PartnerInterests, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(PartnerInterests).set({
        consentStatus: 'Consented',
        consentDate: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(PartnerInterests).where({ ID });
    });

    // Action: markNonConsent
    this.on('markNonConsent', PartnerInterests, async (req) => {
      const { ID } = req.params[0];
      const { reason } = req.data;

      await UPDATE(PartnerInterests).set({
        consentStatus: 'Non-Consent',
        nonConsentReason: reason,
        consentDate: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(PartnerInterests).where({ ID });
    });

    // ===========================================
    // JIB STATEMENTS - CRUD Operations
    // ===========================================

    this.before('CREATE', JIBStatements, async (req) => {
      const { well_ID, partner_ID, periodFrom, periodTo } = req.data;

      if (!well_ID) {
        return req.error(400, 'Well reference is required');
      }
      if (!partner_ID) {
        return req.error(400, 'Partner reference is required');
      }
      if (!periodFrom || !periodTo) {
        return req.error(400, 'Period dates are required');
      }

      // Auto-generate statement number
      const countResult = await SELECT.one.from(JIBStatements).columns('count(*) as count');
      const count = (countResult?.count || 0) + 1;
      req.data.statementNumber = req.data.statementNumber || `JIB-${new Date().getFullYear()}-${String(count).padStart(5, '0')}`;

      req.data.status = 'Draft';
      req.data.totalAmount = 0;
      req.data.partnerShare = 0;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', JIBStatements, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Action: calculate
    this.on('calculate', JIBStatements, async (req) => {
      const { ID } = req.params[0];
      const statement = await SELECT.one.from(JIBStatements).where({ ID });

      if (!statement) {
        return req.error(404, 'JIB Statement not found');
      }

      // Sum line items
      const lineItems = await SELECT.from(JIBLineItems).where({ statement_ID: ID });
      const totalAmount = lineItems.reduce((sum, item) => sum + (item.amount || 0), 0);

      // Get partner interest
      const partnerInterest = await SELECT.one.from(PartnerInterests)
        .where({ well_ID: statement.well_ID, partner_ID: statement.partner_ID });

      const workingInterest = partnerInterest?.workingInterest || 0;
      const partnerShare = totalAmount * (workingInterest / 100);

      await UPDATE(JIBStatements).set({
        totalAmount: totalAmount,
        partnerShare: partnerShare,
        calculatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(JIBStatements).where({ ID });
    });

    // Action: sendToPartner
    this.on('sendToPartner', JIBStatements, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(JIBStatements).set({
        status: 'Sent',
        sentAt: new Date(),
        sentBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(JIBStatements).where({ ID });
    });

    // Action: markPaid
    this.on('markPaid', JIBStatements, async (req) => {
      const { ID } = req.params[0];
      const { paidDate, paymentReference } = req.data;

      await UPDATE(JIBStatements).set({
        status: 'Paid',
        paidDate: paidDate,
        paymentReference: paymentReference,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(JIBStatements).where({ ID });
    });

    // Action: markDisputed
    this.on('markDisputed', JIBStatements, async (req) => {
      const { ID } = req.params[0];
      const { reason } = req.data;

      await UPDATE(JIBStatements).set({
        status: 'Disputed',
        disputeReason: reason,
        disputedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(JIBStatements).where({ ID });
    });

    // Action: postToS4HANA
    this.on('postToS4HANA', JIBStatements, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(JIBStatements).set({
        s4hanaSyncStatus: 'Synced',
        s4hanaDocumentNumber: `S4-JIB-${ID.substring(0, 8)}`,
        s4hanaLastSyncAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(JIBStatements).where({ ID });
    });

    // Action: generatePDF
    this.on('generatePDF', JIBStatements, async (req) => {
      const { ID } = req.params[0];
      return Buffer.from(`JIB Statement PDF for ${ID}`);
    });

    // ===========================================
    // JIB LINE ITEMS - CRUD Operations
    // ===========================================

    this.before('CREATE', JIBLineItems, async (req) => {
      const { statement_ID, description, amount } = req.data;

      if (!statement_ID) {
        return req.error(400, 'Statement reference is required');
      }
      if (!description) {
        return req.error(400, 'Description is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', JIBLineItems, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // VARIANCES - CRUD Operations
    // ===========================================

    this.before('CREATE', Variances, async (req) => {
      const { afe_ID, estimatedAmount, actualAmount } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }

      // Calculate variance
      req.data.varianceAmount = (actualAmount || 0) - (estimatedAmount || 0);
      req.data.variancePct = estimatedAmount > 0
        ? (((actualAmount || 0) - estimatedAmount) / estimatedAmount) * 100
        : 0;

      req.data.status = 'Pending Review';
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', Variances, async (req) => {
      // Recalculate variance if amounts changed
      if (req.data.estimatedAmount !== undefined || req.data.actualAmount !== undefined) {
        const current = await SELECT.one.from(Variances).where({ ID: req.data.ID });
        const estimated = req.data.estimatedAmount ?? current?.estimatedAmount ?? 0;
        const actual = req.data.actualAmount ?? current?.actualAmount ?? 0;

        req.data.varianceAmount = actual - estimated;
        req.data.variancePct = estimated > 0 ? ((actual - estimated) / estimated) * 100 : 0;
      }

      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Action: approve (variance)
    this.on('approve', Variances, async (req) => {
      const { ID } = req.params[0];
      const { comments } = req.data;

      await UPDATE(Variances).set({
        status: 'Approved',
        approvalComments: comments,
        approvedAt: new Date(),
        approvedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Variances).where({ ID });
    });

    // Action: requestExplanation
    this.on('requestExplanation', Variances, async (req) => {
      const { ID } = req.params[0];
      const { userId } = req.data;

      await UPDATE(Variances).set({
        status: 'Explanation Requested',
        explanationRequestedFrom: userId,
        explanationRequestedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Variances).where({ ID });
    });

    // ===========================================
    // SERVICE-LEVEL ACTIONS
    // ===========================================

    // Action: generateJIBStatements
    this.on('generateJIBStatements', async (req) => {
      const { wellId, periodFrom, periodTo } = req.data;

      // Get all partners for the well
      const partnerInterests = await SELECT.from(PartnerInterests).where({ well_ID: wellId });
      const createdStatements = [];

      for (const pi of partnerInterests) {
        const countResult = await SELECT.one.from(JIBStatements).columns('count(*) as count');
        const count = (countResult?.count || 0) + 1;

        const statement = {
          statementNumber: `JIB-${new Date().getFullYear()}-${String(count).padStart(5, '0')}`,
          well_ID: wellId,
          partner_ID: pi.partner_ID,
          periodFrom: periodFrom,
          periodTo: periodTo,
          status: 'Draft',
          totalAmount: 0,
          partnerShare: 0,
          createdAt: new Date(),
          createdBy: req.user.id
        };

        await INSERT.into(JIBStatements).entries(statement);
        createdStatements.push(statement);
      }

      return createdStatements;
    });

    // Action: runVarianceAnalysis
    this.on('runVarianceAnalysis', async (req) => {
      const { afeId } = req.data;

      // Get AFE with line items
      const db = await cds.connect.to('db');
      const { AFEs, AFELineItems } = db.entities('wcm.afe');

      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });
      if (!afe) {
        return req.error(404, 'AFE not found');
      }

      // Get cost actuals grouped by cost element
      const actuals = await SELECT.from(CostActuals)
        .columns('costElement_ID', 'sum(amount) as totalActual')
        .where({ afe_ID: afeId })
        .groupBy('costElement_ID');

      // Get estimates grouped by cost element
      const estimates = await SELECT.from(AFELineItems)
        .columns('costElement_ID', 'sum(totalCost) as totalEstimate')
        .where({ afe_ID: afeId })
        .groupBy('costElement_ID');

      const variances = [];

      for (const estimate of estimates) {
        const actual = actuals.find(a => a.costElement_ID === estimate.costElement_ID);
        const actualAmount = actual?.totalActual || 0;
        const estimateAmount = estimate.totalEstimate || 0;

        const variance = {
          afe_ID: afeId,
          well_ID: afe.well_ID,
          costElement_ID: estimate.costElement_ID,
          estimatedAmount: estimateAmount,
          actualAmount: actualAmount,
          varianceAmount: actualAmount - estimateAmount,
          variancePct: estimateAmount > 0 ? ((actualAmount - estimateAmount) / estimateAmount) * 100 : 0,
          status: 'Pending Review',
          createdAt: new Date(),
          createdBy: req.user.id
        };

        await INSERT.into(Variances).entries(variance);
        variances.push(variance);
      }

      return variances;
    });

    // Action: allocateCosts
    this.on('allocateCosts', async (req) => {
      const { afeId, postingDate } = req.data;

      // Get unallocated cost actuals
      const costActuals = await SELECT.from(CostActuals)
        .where({ afe_ID: afeId, isAllocated: null })
        .or({ afe_ID: afeId, isAllocated: false });

      const db = await cds.connect.to('db');
      const { AFEs } = db.entities('wcm.afe');
      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });

      // Get partner interests
      const partnerInterests = await SELECT.from(PartnerInterests).where({ well_ID: afe.well_ID });
      const allocations = [];

      for (const costActual of costActuals) {
        for (const pi of partnerInterests) {
          const allocation = {
            afe_ID: afeId,
            costActual_ID: costActual.ID,
            partner_ID: pi.partner_ID,
            grossAmount: costActual.amount,
            workingInterest: pi.workingInterest,
            netAmount: costActual.amount * (pi.workingInterest / 100),
            allocationDate: postingDate,
            createdAt: new Date(),
            createdBy: req.user.id
          };

          await INSERT.into(CostAllocations).entries(allocation);
          allocations.push(allocation);
        }

        // Mark cost actual as allocated
        await UPDATE(CostActuals).set({ isAllocated: true }).where({ ID: costActual.ID });
      }

      return allocations;
    });

    // ===========================================
    // FUNCTIONS
    // ===========================================

    this.on('getCostActualsByAFE', async (req) => {
      const { afeId } = req.data;
      return SELECT.from(CostActuals).where({ afe_ID: afeId });
    });

    this.on('getCommitmentsByAFE', async (req) => {
      const { afeId } = req.data;
      return SELECT.from(Commitments).where({ afe_ID: afeId });
    });

    this.on('getPartnerInterestsByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(PartnerInterests).where({ well_ID: wellId });
    });

    this.on('validatePartnerInterests', async (req) => {
      const { wellId } = req.data;
      const result = await SELECT.one.from(PartnerInterests)
        .columns('sum(workingInterest) as total')
        .where({ well_ID: wellId });

      const total = result?.total || 0;
      return {
        isValid: total === 100,
        totalWI: total,
        message: total === 100 ? 'Working interests sum to 100%' : `Working interests sum to ${total}%, should be 100%`
      };
    });

    this.on('getJIBStatementsByPartner', async (req) => {
      const { partnerId, year } = req.data;
      const startDate = `${year}-01-01`;
      const endDate = `${year}-12-31`;

      return SELECT.from(JIBStatements).where({
        partner_ID: partnerId,
        periodFrom: { '>=': startDate },
        periodTo: { '<=': endDate }
      });
    });

    this.on('getVarianceAnalysis', async (req) => {
      const { afeId } = req.data;
      const variances = await SELECT.from(Variances).where({ afe_ID: afeId });

      const db = await cds.connect.to('db');
      const { CostElements } = db.entities('wcm.master');

      const result = [];
      for (const v of variances) {
        const costElement = await SELECT.one.from(CostElements).where({ ID: v.costElement_ID });
        result.push({
          costElementId: v.costElement_ID,
          costElementName: costElement?.elementName || 'Unknown',
          estimated: v.estimatedAmount,
          actual: v.actualAmount,
          variance: v.varianceAmount,
          variancePct: v.variancePct,
          category: v.varianceAmount >= 0 ? 'Unfavorable' : 'Favorable'
        });
      }

      return result;
    });

    // ===========================================
    // HELPER METHODS
    // ===========================================

    this._updateAFEActuals = async (afeId) => {
      const result = await SELECT.one.from(CostActuals)
        .columns('sum(amount) as total')
        .where({ afe_ID: afeId, isReversed: false });

      const db = await cds.connect.to('db');
      const { AFEs } = db.entities('wcm.afe');

      await UPDATE(AFEs).set({
        actualCost: result?.total || 0,
        modifiedAt: new Date()
      }).where({ ID: afeId });
    };

    this._updateAFECommitments = async (afeId) => {
      const result = await SELECT.one.from(Commitments)
        .columns('sum(remainingAmount) as total')
        .where({ afe_ID: afeId, status: 'Open' });

      const db = await cds.connect.to('db');
      const { AFEs } = db.entities('wcm.afe');

      await UPDATE(AFEs).set({
        committedCost: result?.total || 0,
        modifiedAt: new Date()
      }).where({ ID: afeId });
    };

    await super.init();
  }
};
