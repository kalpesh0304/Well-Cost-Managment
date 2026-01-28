const cds = require('@sap/cds');

module.exports = class EconomicsService extends cds.ApplicationService {

  async init() {
    const { EconomicsAnalyses, CashFlows, HurdleRates, Scenarios, SensitivityResults } = this.entities;

    // ============================================
    // ECONOMICS ANALYSES CRUD
    // ============================================
    this.before('CREATE', EconomicsAnalyses, async (req) => {
      if (!req.data.status) req.data.status = 'Draft';
      if (!req.data.discountRate) req.data.discountRate = 0.10; // Default 10%
    });

    this.after('READ', EconomicsAnalyses, (data) => {
      if (Array.isArray(data)) data.forEach(enrichAnalysis);
      else if (data) enrichAnalysis(data);
    });

    // ============================================
    // CASH FLOWS CRUD
    // ============================================
    this.before('CREATE', CashFlows, async (req) => {
      // Calculate net cash flow
      const { capex = 0, opex = 0, revenue = 0, royalty = 0, taxes = 0 } = req.data;
      req.data.netCashFlow = revenue - capex - opex - royalty - taxes;
    });

    this.after('CREATE', CashFlows, async (data, req) => {
      // Recalculate analysis NPV/IRR
      await this.recalculateAnalysis(data.analysis_ID);
    });

    // ============================================
    // HURDLE RATES CRUD
    // ============================================
    this.before('CREATE', HurdleRates, async (req) => {
      if (req.data.rateValue < 0 || req.data.rateValue > 0.5) {
        req.error(400, 'Hurdle rate must be between 0% and 50%');
      }
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('calculateNPV', async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });
      if (!analysis) req.error(404, 'Analysis not found');

      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID }).orderBy('yearNumber');
      const npv = calculateNPV(cashFlows, analysis.discountRate);
      const irr = calculateIRR(cashFlows);
      const payback = calculatePayback(cashFlows);

      await UPDATE(EconomicsAnalyses).set({
        npv,
        irr,
        paybackYears: payback.simple,
        discountedPayback: payback.discounted,
        calculatedAt: new Date().toISOString()
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    this.on('runSensitivity', async (req) => {
      const { ID } = req.params[0];
      const { variables } = req.data;
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });
      if (!analysis) req.error(404, 'Analysis not found');

      const results = [];
      const baseCashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID });
      const baseNPV = calculateNPV(baseCashFlows, analysis.discountRate);

      for (const variable of variables || ['OilPrice', 'CAPEX', 'OPEX', 'ProductionRate']) {
        const lowNPV = baseNPV * 0.8;  // Simplified -20%
        const highNPV = baseNPV * 1.2; // Simplified +20%

        const result = {
          ID: cds.utils.uuid(),
          analysis_ID: ID,
          variableName: variable,
          baseValue: 100,
          lowValue: 80,
          highValue: 120,
          npvLow: lowNPV,
          npvHigh: highNPV,
          impactRange: highNPV - lowNPV
        };
        await INSERT.into(SensitivityResults).entries(result);
        results.push(result);
      }
      return results;
    });

    this.on('generateScenarios', async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });
      if (!analysis) req.error(404, 'Analysis not found');

      const scenarios = [
        { type: 'P10', probability: 0.10, factor: 0.7 },
        { type: 'P50', probability: 0.50, factor: 1.0 },
        { type: 'P90', probability: 0.90, factor: 1.3 }
      ];

      const results = [];
      for (const s of scenarios) {
        const scenarioData = {
          ID: cds.utils.uuid(),
          analysis_ID: ID,
          scenarioType: s.type,
          scenarioName: `${s.type} Scenario`,
          npv: (analysis.npv || 0) * s.factor,
          irr: (analysis.irr || 0) * s.factor,
          probability: s.probability
        };
        await INSERT.into(Scenarios).entries(scenarioData);
        results.push(scenarioData);
      }
      return results;
    });

    this.on('submitForApproval', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(EconomicsAnalyses).set({ status: 'Pending' }).where({ ID });
      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    this.on('approve', async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });
      if (!analysis) req.error(404, 'Analysis not found');

      // Determine recommendation based on hurdle rate
      const hurdleRate = await SELECT.one.from(HurdleRates).where({ isActive: true, rateType: 'CORPORATE' });
      let recommendation = 'Recommend';
      if (analysis.irr < (hurdleRate?.rateValue || 0.10)) {
        recommendation = analysis.irr < (hurdleRate?.rateValue || 0.10) * 0.8 ? 'DoNotRecommend' : 'Marginal';
      }

      await UPDATE(EconomicsAnalyses).set({
        status: 'Approved',
        recommendation
      }).where({ ID });
      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getAnalysesByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(EconomicsAnalyses).where({ well_ID: wellId });
    });

    this.on('getCashFlowProjection', async (req) => {
      const { analysisId } = req.data;
      return SELECT.from(CashFlows).where({ analysis_ID: analysisId }).orderBy('yearNumber');
    });

    this.on('getHurdleRate', async (req) => {
      const { rateType, fieldId } = req.data;
      if (fieldId) {
        return SELECT.one.from(HurdleRates).where({ rateType, field_ID: fieldId, isActive: true });
      }
      return SELECT.one.from(HurdleRates).where({ rateType, isActive: true });
    });

    this.on('compareScenarios', async (req) => {
      const { analysisId } = req.data;
      return SELECT.from(Scenarios).where({ analysis_ID: analysisId });
    });

    await super.init();
  }

  async recalculateAnalysis(analysisId) {
    const { EconomicsAnalyses, CashFlows } = this.entities;
    const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID: analysisId });
    if (!analysis) return;

    const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: analysisId }).orderBy('yearNumber');
    const npv = calculateNPV(cashFlows, analysis.discountRate);
    const irr = calculateIRR(cashFlows);

    await UPDATE(EconomicsAnalyses).set({ npv, irr, calculatedAt: new Date().toISOString() }).where({ ID: analysisId });
  }
};

// Helper functions
function calculateNPV(cashFlows, discountRate) {
  return cashFlows.reduce((npv, cf, i) => {
    const discountFactor = Math.pow(1 + discountRate, cf.yearNumber || i);
    return npv + (cf.netCashFlow || 0) / discountFactor;
  }, 0);
}

function calculateIRR(cashFlows, guess = 0.1) {
  // Newton-Raphson iteration for IRR
  let rate = guess;
  for (let i = 0; i < 100; i++) {
    let npv = 0, dnpv = 0;
    cashFlows.forEach((cf, idx) => {
      const year = cf.yearNumber || idx;
      const flow = cf.netCashFlow || 0;
      npv += flow / Math.pow(1 + rate, year);
      dnpv -= year * flow / Math.pow(1 + rate, year + 1);
    });
    if (Math.abs(npv) < 0.001) break;
    rate = rate - npv / dnpv;
  }
  return rate;
}

function calculatePayback(cashFlows) {
  let cumulative = 0, discCumulative = 0;
  let simple = null, discounted = null;

  for (const cf of cashFlows) {
    cumulative += cf.netCashFlow || 0;
    discCumulative += cf.discountedCashFlow || cf.netCashFlow || 0;

    if (simple === null && cumulative >= 0) simple = cf.yearNumber;
    if (discounted === null && discCumulative >= 0) discounted = cf.yearNumber;
  }
  return { simple, discounted };
}

function enrichAnalysis(analysis) {
  if (analysis && analysis.npv !== undefined && analysis.irr !== undefined) {
    analysis.profitabilityIndex = analysis.npv > 0 ? analysis.npv / Math.abs(analysis.npv) : 0;
  }
}
