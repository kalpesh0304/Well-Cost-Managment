/**
 * Economics Service Handler
 * Implements CRUD operations for Economic Analysis, NPV, IRR calculations
 */
const cds = require('@sap/cds');

module.exports = class EconomicsService extends cds.ApplicationService {

  async init() {
    const { EconomicsAnalyses, CashFlows, HurdleRates, Scenarios, SensitivityResults,
            EconomicsAssumptions, PriceDecks, PriceDeckItems } = this.entities;

    // ===========================================
    // ECONOMICS ANALYSES - CRUD Operations
    // ===========================================

    this.before('CREATE', EconomicsAnalyses, async (req) => {
      const { analysisName, well_ID } = req.data;

      if (!analysisName) {
        return req.error(400, 'Analysis name is required');
      }
      if (!well_ID) {
        return req.error(400, 'Well reference is required');
      }

      // Auto-generate analysis number
      const countResult = await SELECT.one.from(EconomicsAnalyses).columns('count(*) as count');
      const count = (countResult?.count || 0) + 1;
      req.data.analysisNumber = req.data.analysisNumber || `ECON-${new Date().getFullYear()}-${String(count).padStart(4, '0')}`;

      req.data.status = 'Draft';
      req.data.npv = 0;
      req.data.irr = 0;
      req.data.paybackPeriod = 0;
      req.data.profitabilityIndex = 0;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', EconomicsAnalyses, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.before('DELETE', EconomicsAnalyses, async (req) => {
      const analysisId = req.data.ID;
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID: analysisId });

      if (analysis?.status === 'Approved') {
        return req.error(400, 'Cannot delete approved analysis');
      }
    });

    // Action: calculateNPV
    this.on('calculateNPV', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });

      if (!analysis) {
        return req.error(404, 'Analysis not found');
      }

      // Get cash flows
      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID }).orderBy({ year: 'asc' });

      if (cashFlows.length === 0) {
        return req.error(400, 'No cash flows defined for NPV calculation');
      }

      // Get discount rate
      const discountRate = analysis.discountRate || 10;
      const npv = this._calculateNPV(cashFlows, discountRate);

      await UPDATE(EconomicsAnalyses).set({
        npv: npv,
        calculatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: calculateIRR
    this.on('calculateIRR', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });

      if (!analysis) {
        return req.error(404, 'Analysis not found');
      }

      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID }).orderBy({ year: 'asc' });

      if (cashFlows.length === 0) {
        return req.error(400, 'No cash flows defined for IRR calculation');
      }

      const irr = this._calculateIRR(cashFlows);

      await UPDATE(EconomicsAnalyses).set({
        irr: irr,
        calculatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: calculateAll
    this.on('calculateAll', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });

      if (!analysis) {
        return req.error(404, 'Analysis not found');
      }

      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID }).orderBy({ year: 'asc' });

      if (cashFlows.length === 0) {
        return req.error(400, 'No cash flows defined for calculations');
      }

      const discountRate = analysis.discountRate || 10;
      const npv = this._calculateNPV(cashFlows, discountRate);
      const irr = this._calculateIRR(cashFlows);
      const payback = this._calculatePayback(cashFlows);
      const pi = this._calculateProfitabilityIndex(cashFlows, discountRate);

      await UPDATE(EconomicsAnalyses).set({
        npv: npv,
        irr: irr,
        paybackPeriod: payback,
        profitabilityIndex: pi,
        calculatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: runMonteCarlo
    this.on('runMonteCarlo', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const { iterations } = req.data;
      const numIterations = iterations || 1000;

      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });
      if (!analysis) {
        return req.error(404, 'Analysis not found');
      }

      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID });
      const discountRate = analysis.discountRate || 10;

      // Run Monte Carlo simulation
      const results = [];
      for (let i = 0; i < numIterations; i++) {
        // Apply random variation to cash flows (simplified)
        const variedCashFlows = cashFlows.map(cf => ({
          ...cf,
          netCashFlow: cf.netCashFlow * (0.8 + Math.random() * 0.4) // +/- 20% variation
        }));
        results.push(this._calculateNPV(variedCashFlows, discountRate));
      }

      // Calculate percentiles
      results.sort((a, b) => a - b);
      const p10 = results[Math.floor(numIterations * 0.1)];
      const p50 = results[Math.floor(numIterations * 0.5)];
      const p90 = results[Math.floor(numIterations * 0.9)];
      const mean = results.reduce((a, b) => a + b, 0) / numIterations;

      await UPDATE(EconomicsAnalyses).set({
        npvP10: p10,
        npvP50: p50,
        npvP90: p90,
        npvMean: mean,
        monteCarloIterations: numIterations,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: runSensitivityAnalysis
    this.on('runSensitivityAnalysis', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID });

      if (!analysis) {
        return req.error(404, 'Analysis not found');
      }

      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: ID });
      const discountRate = analysis.discountRate || 10;
      const baseNPV = this._calculateNPV(cashFlows, discountRate);

      // Define sensitivity variables
      const variables = ['Oil Price', 'Gas Price', 'CAPEX', 'OPEX', 'Production Rate'];
      const variationPct = 20; // +/- 20%

      for (const variable of variables) {
        // Calculate low and high scenarios
        const lowCashFlows = this._applyVariation(cashFlows, variable, -variationPct);
        const highCashFlows = this._applyVariation(cashFlows, variable, variationPct);

        const lowNPV = this._calculateNPV(lowCashFlows, discountRate);
        const highNPV = this._calculateNPV(highCashFlows, discountRate);

        await INSERT.into(SensitivityResults).entries({
          analysis_ID: ID,
          variable: variable,
          baseValue: 100,
          lowValue: 100 - variationPct,
          highValue: 100 + variationPct,
          baseNPV: baseNPV,
          lowNPV: lowNPV,
          highNPV: highNPV,
          impact: Math.abs(highNPV - lowNPV),
          createdAt: new Date(),
          createdBy: req.user.id
        });
      }

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: submitForApproval
    this.on('submitForApproval', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(EconomicsAnalyses).set({
        status: 'Pending Approval',
        submittedAt: new Date(),
        submittedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: approve (analysis)
    this.on('approve', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const { comments } = req.data;

      await UPDATE(EconomicsAnalyses).set({
        status: 'Approved',
        approvalComments: comments,
        approvedAt: new Date(),
        approvedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: reject (analysis)
    this.on('reject', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      const { comments } = req.data;

      await UPDATE(EconomicsAnalyses).set({
        status: 'Rejected',
        rejectionComments: comments,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(EconomicsAnalyses).where({ ID });
    });

    // Action: exportToExcel
    this.on('exportToExcel', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      return Buffer.from(`Economics Analysis Excel Export for ${ID}`);
    });

    // Action: generateReport
    this.on('generateReport', EconomicsAnalyses, async (req) => {
      const { ID } = req.params[0];
      return Buffer.from(`Economics Analysis Report for ${ID}`);
    });

    // ===========================================
    // CASH FLOWS - CRUD Operations
    // ===========================================

    this.before('CREATE', CashFlows, async (req) => {
      const { analysis_ID, year } = req.data;

      if (!analysis_ID) {
        return req.error(400, 'Analysis reference is required');
      }
      if (year === undefined) {
        return req.error(400, 'Year is required');
      }

      // Calculate net cash flow
      const revenue = req.data.revenue || 0;
      const capex = req.data.capex || 0;
      const opex = req.data.opex || 0;
      const taxes = req.data.taxes || 0;

      req.data.netCashFlow = revenue - capex - opex - taxes;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CashFlows, async (req) => {
      // Recalculate net cash flow if any component changed
      const current = await SELECT.one.from(CashFlows).where({ ID: req.data.ID });

      const revenue = req.data.revenue ?? current?.revenue ?? 0;
      const capex = req.data.capex ?? current?.capex ?? 0;
      const opex = req.data.opex ?? current?.opex ?? 0;
      const taxes = req.data.taxes ?? current?.taxes ?? 0;

      req.data.netCashFlow = revenue - capex - opex - taxes;
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // HURDLE RATES - CRUD Operations
    // ===========================================

    this.before('CREATE', HurdleRates, async (req) => {
      const { rateType, rate } = req.data;

      if (!rateType) {
        return req.error(400, 'Rate type is required');
      }
      if (!rate || rate <= 0) {
        return req.error(400, 'Valid rate is required');
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', HurdleRates, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('activate', HurdleRates, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(HurdleRates).set({
        isActive: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(HurdleRates).where({ ID });
    });

    this.on('deactivate', HurdleRates, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(HurdleRates).set({
        isActive: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(HurdleRates).where({ ID });
    });

    // ===========================================
    // SCENARIOS - CRUD Operations
    // ===========================================

    this.before('CREATE', Scenarios, async (req) => {
      const { analysis_ID, scenarioType } = req.data;

      if (!analysis_ID) {
        return req.error(400, 'Analysis reference is required');
      }
      if (!scenarioType) {
        return req.error(400, 'Scenario type is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.on('calculate', Scenarios, async (req) => {
      const { ID } = req.params[0];
      const scenario = await SELECT.one.from(Scenarios).where({ ID });

      if (!scenario) {
        return req.error(404, 'Scenario not found');
      }

      // Get analysis cash flows and apply scenario multipliers
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID: scenario.analysis_ID });
      const cashFlows = await SELECT.from(CashFlows).where({ analysis_ID: scenario.analysis_ID });

      const priceMultiplier = scenario.priceMultiplier || 1;
      const costMultiplier = scenario.costMultiplier || 1;
      const productionMultiplier = scenario.productionMultiplier || 1;

      const adjustedCashFlows = cashFlows.map(cf => ({
        ...cf,
        revenue: (cf.revenue || 0) * priceMultiplier * productionMultiplier,
        capex: (cf.capex || 0) * costMultiplier,
        opex: (cf.opex || 0) * costMultiplier,
        netCashFlow: ((cf.revenue || 0) * priceMultiplier * productionMultiplier) -
                     ((cf.capex || 0) * costMultiplier) -
                     ((cf.opex || 0) * costMultiplier) -
                     (cf.taxes || 0)
      }));

      const discountRate = analysis.discountRate || 10;
      const npv = this._calculateNPV(adjustedCashFlows, discountRate);
      const irr = this._calculateIRR(adjustedCashFlows);

      await UPDATE(Scenarios).set({
        npv: npv,
        irr: irr,
        calculatedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Scenarios).where({ ID });
    });

    // ===========================================
    // ECONOMICS ASSUMPTIONS - CRUD Operations
    // ===========================================

    this.before('CREATE', EconomicsAssumptions, async (req) => {
      const { analysis_ID, assumptionType, value } = req.data;

      if (!analysis_ID) {
        return req.error(400, 'Analysis reference is required');
      }
      if (!assumptionType) {
        return req.error(400, 'Assumption type is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', EconomicsAssumptions, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // PRICE DECKS - CRUD Operations
    // ===========================================

    this.before('CREATE', PriceDecks, async (req) => {
      const { deckName } = req.data;

      if (!deckName) {
        return req.error(400, 'Deck name is required');
      }

      req.data.status = 'Draft';
      req.data.isActive = false;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', PriceDecks, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('approve', PriceDecks, async (req) => {
      const { ID } = req.params[0];

      // Deactivate other price decks
      await UPDATE(PriceDecks).set({ isActive: false }).where({ ID: { '!=': ID } });

      await UPDATE(PriceDecks).set({
        status: 'Approved',
        isActive: true,
        approvedAt: new Date(),
        approvedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(PriceDecks).where({ ID });
    });

    this.on('copyDeck', PriceDecks, async (req) => {
      const { ID } = req.params[0];
      const { newName } = req.data;

      const sourceDeck = await SELECT.one.from(PriceDecks).where({ ID });
      if (!sourceDeck) {
        return req.error(404, 'Source price deck not found');
      }

      const newDeck = {
        deckName: newName,
        description: `Copy of ${sourceDeck.deckName}`,
        status: 'Draft',
        isActive: false,
        createdAt: new Date(),
        createdBy: req.user.id
      };

      const result = await INSERT.into(PriceDecks).entries(newDeck);
      const newDeckId = result.req.data.ID;

      // Copy price items
      const items = await SELECT.from(PriceDeckItems).where({ deck_ID: ID });
      for (const item of items) {
        await INSERT.into(PriceDeckItems).entries({
          deck_ID: newDeckId,
          year: item.year,
          oilPrice: item.oilPrice,
          gasPrice: item.gasPrice,
          nglPrice: item.nglPrice,
          createdAt: new Date(),
          createdBy: req.user.id
        });
      }

      return SELECT.one.from(PriceDecks).where({ ID: newDeckId });
    });

    // ===========================================
    // PRICE DECK ITEMS - CRUD Operations
    // ===========================================

    this.before('CREATE', PriceDeckItems, async (req) => {
      const { deck_ID, year } = req.data;

      if (!deck_ID) {
        return req.error(400, 'Price deck reference is required');
      }
      if (!year) {
        return req.error(400, 'Year is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', PriceDeckItems, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // SERVICE-LEVEL ACTIONS
    // ===========================================

    this.on('createAnalysisFromAFE', async (req) => {
      const { afeId, analysisName } = req.data;

      const db = await cds.connect.to('db');
      const { AFEs } = db.entities('wcm.afe');

      const afe = await SELECT.one.from(AFEs).where({ ID: afeId });
      if (!afe) {
        return req.error(404, 'AFE not found');
      }

      const countResult = await SELECT.one.from(EconomicsAnalyses).columns('count(*) as count');
      const count = (countResult?.count || 0) + 1;

      const analysis = {
        analysisNumber: `ECON-${new Date().getFullYear()}-${String(count).padStart(4, '0')}`,
        analysisName: analysisName,
        well_ID: afe.well_ID,
        afe_ID: afeId,
        status: 'Draft',
        discountRate: 10, // Default discount rate
        createdAt: new Date(),
        createdBy: req.user.id
      };

      await INSERT.into(EconomicsAnalyses).entries(analysis);
      return SELECT.one.from(EconomicsAnalyses).where({ analysisNumber: analysis.analysisNumber });
    });

    this.on('compareScenarios', async (req) => {
      const { analysisIds } = req.data;
      const results = [];

      for (const analysisId of analysisIds) {
        const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID: analysisId });
        if (analysis) {
          results.push({
            analysisId: analysis.ID,
            analysisName: analysis.analysisName,
            npv: analysis.npv,
            irr: analysis.irr,
            payback: analysis.paybackPeriod,
            recommendation: analysis.npv > 0 && analysis.irr > 10 ? 'Proceed' : 'Review'
          });
        }
      }

      return results.sort((a, b) => b.npv - a.npv);
    });

    // ===========================================
    // FUNCTIONS
    // ===========================================

    this.on('getAnalysesByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(EconomicsAnalyses).where({ well_ID: wellId });
    });

    this.on('getActiveHurdleRate', async (req) => {
      const { rateType, fieldId } = req.data;

      let query = SELECT.one.from(HurdleRates).where({ rateType, isActive: true });
      if (fieldId) {
        query = query.and({ field_ID: fieldId });
      }

      return query;
    });

    this.on('getActivePriceDeck', async (req) => {
      return SELECT.one.from(PriceDecks).where({ isActive: true });
    });

    this.on('calculateNPVPreview', async (req) => {
      const { cashFlows, discountRate } = req.data;
      return this._calculateNPV(cashFlows, discountRate);
    });

    this.on('calculateIRRPreview', async (req) => {
      const { cashFlows } = req.data;
      return this._calculateIRR(cashFlows);
    });

    this.on('getTornadoChartData', async (req) => {
      const { analysisId } = req.data;
      const results = await SELECT.from(SensitivityResults)
        .where({ analysis_ID: analysisId })
        .orderBy({ impact: 'desc' });

      return results.map(r => ({
        variable: r.variable,
        baseNPV: r.baseNPV,
        lowNPV: r.lowNPV,
        highNPV: r.highNPV,
        impact: r.impact
      }));
    });

    this.on('getMonteCarloDistribution', async (req) => {
      const { analysisId } = req.data;
      const analysis = await SELECT.one.from(EconomicsAnalyses).where({ ID: analysisId });

      if (!analysis) {
        return req.error(404, 'Analysis not found');
      }

      return {
        p10: analysis.npvP10 || 0,
        p50: analysis.npvP50 || 0,
        p90: analysis.npvP90 || 0,
        mean: analysis.npvMean || 0,
        stdDev: 0 // Would need to store this during Monte Carlo calculation
      };
    });

    // ===========================================
    // HELPER METHODS
    // ===========================================

    this._calculateNPV = (cashFlows, discountRate) => {
      const rate = discountRate / 100;
      return cashFlows.reduce((npv, cf, index) => {
        const year = cf.year || index;
        return npv + (cf.netCashFlow || 0) / Math.pow(1 + rate, year);
      }, 0);
    };

    this._calculateIRR = (cashFlows, precision = 0.0001) => {
      let low = -0.99;
      let high = 10;
      let guess = 0.1;

      for (let i = 0; i < 1000; i++) {
        const npv = this._calculateNPV(cashFlows, guess * 100);

        if (Math.abs(npv) < precision) {
          return guess * 100;
        }

        if (npv > 0) {
          low = guess;
        } else {
          high = guess;
        }

        guess = (low + high) / 2;
      }

      return guess * 100;
    };

    this._calculatePayback = (cashFlows) => {
      let cumulative = 0;

      for (let i = 0; i < cashFlows.length; i++) {
        const cf = cashFlows[i];
        cumulative += cf.netCashFlow || 0;

        if (cumulative >= 0) {
          // Interpolate for exact payback period
          const prevCumulative = cumulative - (cf.netCashFlow || 0);
          const fraction = -prevCumulative / (cf.netCashFlow || 1);
          return i + fraction;
        }
      }

      return cashFlows.length; // Never pays back
    };

    this._calculateProfitabilityIndex = (cashFlows, discountRate) => {
      const rate = discountRate / 100;
      let pvInflows = 0;
      let pvOutflows = 0;

      cashFlows.forEach((cf, index) => {
        const year = cf.year || index;
        const discountFactor = Math.pow(1 + rate, year);
        const ncf = cf.netCashFlow || 0;

        if (ncf > 0) {
          pvInflows += ncf / discountFactor;
        } else {
          pvOutflows += Math.abs(ncf) / discountFactor;
        }
      });

      return pvOutflows > 0 ? pvInflows / pvOutflows : 0;
    };

    this._applyVariation = (cashFlows, variable, variationPct) => {
      const multiplier = 1 + (variationPct / 100);

      return cashFlows.map(cf => {
        const newCf = { ...cf };

        switch (variable) {
          case 'Oil Price':
          case 'Gas Price':
          case 'Production Rate':
            newCf.revenue = (cf.revenue || 0) * multiplier;
            break;
          case 'CAPEX':
            newCf.capex = (cf.capex || 0) * multiplier;
            break;
          case 'OPEX':
            newCf.opex = (cf.opex || 0) * multiplier;
            break;
        }

        newCf.netCashFlow = (newCf.revenue || 0) - (newCf.capex || 0) - (newCf.opex || 0) - (newCf.taxes || 0);
        return newCf;
      });
    };

    await super.init();
  }
};
