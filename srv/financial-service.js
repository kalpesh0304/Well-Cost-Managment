const cds = require('@sap/cds');

module.exports = class FinancialService extends cds.ApplicationService {

  async init() {
    const { CostActuals, Commitments, PartnerInterests, JIBStatements, Variances, VarianceCategories } = this.entities;

    // ============================================
    // COST ACTUALS CRUD
    // ============================================
    this.before('CREATE', CostActuals, async (req) => {
      if (!req.data.costType) req.data.costType = 'Actual';
      if (!req.data.postingDate) req.data.postingDate = new Date().toISOString().split('T')[0];
    });

    this.after('CREATE', CostActuals, async (data, req) => {
      // Trigger variance calculation
      await this.calculateVariance(data.afe_ID, data.costElement_ID);
    });

    // ============================================
    // COMMITMENTS CRUD
    // ============================================
    this.before('CREATE', Commitments, async (req) => {
      if (!req.data.status) req.data.status = 'Open';
      req.data.remainingAmount = req.data.commitmentAmount - (req.data.consumedAmount || 0);
    });

    this.before('UPDATE', Commitments, async (req) => {
      if (req.data.consumedAmount !== undefined) {
        const commitment = await SELECT.one.from(Commitments).where({ ID: req.data.ID });
        if (commitment) {
          req.data.remainingAmount = commitment.commitmentAmount - req.data.consumedAmount;
          if (req.data.remainingAmount <= 0) req.data.status = 'Closed';
          else if (req.data.consumedAmount > 0) req.data.status = 'PartiallyConsumed';
        }
      }
    });

    // ============================================
    // PARTNER INTERESTS CRUD
    // ============================================
    this.before('CREATE', PartnerInterests, async (req) => {
      // Validate working interest sum
      const wellId = req.data.well_ID;
      const existing = await SELECT.from(PartnerInterests).where({ well_ID: wellId });
      const totalWI = existing.reduce((sum, pi) => sum + (pi.workingInterest || 0), 0) + (req.data.workingInterest || 0);
      if (totalWI > 1.0001) {
        req.error(400, `Total working interest exceeds 100%. Current: ${(totalWI * 100).toFixed(2)}%`);
      }
      if (!req.data.consentStatus) req.data.consentStatus = 'Pending';
    });

    // ============================================
    // JIB STATEMENTS CRUD
    // ============================================
    this.before('CREATE', JIBStatements, async (req) => {
      if (!req.data.statementNumber) {
        req.data.statementNumber = await generateJIBNumber();
      }
      if (!req.data.status) req.data.status = 'Draft';
      // Calculate partner share
      if (req.data.grossAmount && req.data.workingInterest) {
        req.data.partnerShare = req.data.grossAmount * req.data.workingInterest;
      }
    });

    // ============================================
    // VARIANCES CRUD
    // ============================================
    this.before('CREATE', Variances, async (req) => {
      if (req.data.estimatedAmount && req.data.actualAmount) {
        req.data.varianceAmount = req.data.actualAmount - req.data.estimatedAmount;
        req.data.variancePct = req.data.estimatedAmount !== 0
          ? (req.data.varianceAmount / req.data.estimatedAmount) * 100
          : 0;
        req.data.approvalRequired = Math.abs(req.data.variancePct) > 10;
      }
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('postCost', async (req) => {
      const { afeId, costElementId, amount, postingDate, vendorId, description } = req.data;
      const newCost = {
        ID: cds.utils.uuid(),
        afe_ID: afeId,
        costElement_ID: costElementId,
        vendor_ID: vendorId,
        actualAmount: amount,
        postingDate: postingDate || new Date().toISOString().split('T')[0],
        costType: 'Actual'
      };
      await INSERT.into(CostActuals).entries(newCost);
      return SELECT.one.from(CostActuals).where({ ID: newCost.ID });
    });

    this.on('consumeCommitment', async (req) => {
      const { ID } = req.params[0];
      const { amount } = req.data;
      const commitment = await SELECT.one.from(Commitments).where({ ID });
      if (!commitment) req.error(404, 'Commitment not found');

      const newConsumed = (commitment.consumedAmount || 0) + amount;
      const newRemaining = commitment.commitmentAmount - newConsumed;
      const newStatus = newRemaining <= 0 ? 'Closed' : 'PartiallyConsumed';

      await UPDATE(Commitments).set({
        consumedAmount: newConsumed,
        remainingAmount: newRemaining,
        status: newStatus
      }).where({ ID });
      return SELECT.one.from(Commitments).where({ ID });
    });

    this.on('sendJIB', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(JIBStatements).set({
        status: 'Sent',
        sentDate: new Date().toISOString()
      }).where({ ID });
      return SELECT.one.from(JIBStatements).where({ ID });
    });

    this.on('markJIBPaid', async (req) => {
      const { ID } = req.params[0];
      const { paymentDate } = req.data || {};
      await UPDATE(JIBStatements).set({
        status: 'Paid',
        paidDate: paymentDate || new Date().toISOString().split('T')[0]
      }).where({ ID });
      return SELECT.one.from(JIBStatements).where({ ID });
    });

    this.on('approveVariance', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Variances).set({
        approvedBy: req.user.id,
        approvedAt: new Date().toISOString()
      }).where({ ID });
      return SELECT.one.from(Variances).where({ ID });
    });

    this.on('grantConsent', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(PartnerInterests).set({
        consentStatus: 'Consent',
        consentDate: new Date().toISOString()
      }).where({ ID });
      return SELECT.one.from(PartnerInterests).where({ ID });
    });

    this.on('denyConsent', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(PartnerInterests).set({
        consentStatus: 'NonConsent',
        consentDate: new Date().toISOString()
      }).where({ ID });
      return SELECT.one.from(PartnerInterests).where({ ID });
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getCostSummaryByAFE', async (req) => {
      const { afeId } = req.data;
      const actuals = await SELECT.from(CostActuals).where({ afe_ID: afeId });
      const commitments = await SELECT.from(Commitments).where({ afe_ID: afeId });

      return {
        afeId,
        totalActuals: actuals.reduce((sum, c) => sum + (c.actualAmount || 0), 0),
        totalCommitted: commitments.reduce((sum, c) => sum + (c.commitmentAmount || 0), 0),
        totalConsumed: commitments.reduce((sum, c) => sum + (c.consumedAmount || 0), 0),
        totalRemaining: commitments.reduce((sum, c) => sum + (c.remainingAmount || 0), 0),
        recordCount: actuals.length
      };
    });

    this.on('getPartnerShareByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(PartnerInterests).where({ well_ID: wellId });
    });

    this.on('getVariancesByAFE', async (req) => {
      const { afeId } = req.data;
      return SELECT.from(Variances).where({ afe_ID: afeId });
    });

    this.on('generateJIBStatements', async (req) => {
      const { afeId, billingPeriodFrom, billingPeriodTo } = req.data;
      const partners = await SELECT.from(PartnerInterests).where({ afe_ID: afeId, consentStatus: 'Consent' });
      const actuals = await SELECT.from(CostActuals).where({
        afe_ID: afeId,
        postingDate: { between: billingPeriodFrom, and: billingPeriodTo }
      });

      const grossAmount = actuals.reduce((sum, c) => sum + (c.actualAmount || 0), 0);
      const statements = [];

      for (const partner of partners) {
        const stmt = {
          ID: cds.utils.uuid(),
          statementNumber: await generateJIBNumber(),
          afe_ID: afeId,
          partner_ID: partner.partner_ID,
          billingPeriodFrom,
          billingPeriodTo,
          workingInterest: partner.workingInterest,
          grossAmount,
          partnerShare: grossAmount * partner.workingInterest,
          status: 'Draft'
        };
        await INSERT.into(JIBStatements).entries(stmt);
        statements.push(stmt);
      }
      return statements;
    });

    await super.init();
  }

  async calculateVariance(afeId, costElementId) {
    // Variance calculation logic would go here
  }
};

async function generateJIBNumber() {
  const year = new Date().getFullYear();
  const month = (new Date().getMonth() + 1).toString().padStart(2, '0');
  const seq = Math.floor(Math.random() * 9999).toString().padStart(4, '0');
  return `JIB-${year}${month}-${seq}`;
}
