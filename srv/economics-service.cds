// Economics Service (NPV, IRR, Cash Flows)
using { wcm.economics as econ } from '../db/economics';
using { wcm.master as master } from '../db/master-data';
using { wcm.afe as afe } from '../db/afe';

@path: '/api/economics'
@requires: 'authenticated-user'
service EconomicsService {

  // ============================================
  // ECONOMICS ANALYSES
  // ============================================
  @odata.draft.enabled
  @requires: ['EconomicsRead', 'Admin']
  entity EconomicsAnalyses as projection on econ.EconomicsAnalyses {
    *,
    well : redirected to Wells,
    afe : redirected to AFEs,
    cashFlows : redirected to CashFlows,
    scenarios : redirected to Scenarios,
    sensitivities : redirected to SensitivityResults,
    assumptions : redirected to EconomicsAssumptions
  } actions {
    // Calculation Actions
    @requires: 'EconomicsWrite'
    action calculateNPV() returns EconomicsAnalyses;

    @requires: 'EconomicsWrite'
    action calculateIRR() returns EconomicsAnalyses;

    @requires: 'EconomicsWrite'
    action calculateAll() returns EconomicsAnalyses;

    @requires: 'EconomicsWrite'
    action runMonteCarlo(iterations: Integer) returns EconomicsAnalyses;

    @requires: 'EconomicsWrite'
    action runSensitivityAnalysis() returns EconomicsAnalyses;

    // Lifecycle Actions
    @requires: 'EconomicsWrite'
    action submitForApproval() returns EconomicsAnalyses;

    @requires: 'EconomicsWrite'
    action approve(comments: String) returns EconomicsAnalyses;

    @requires: 'EconomicsWrite'
    action reject(comments: String) returns EconomicsAnalyses;

    // Export
    @requires: 'EconomicsRead'
    action exportToExcel() returns LargeBinary;

    @requires: 'EconomicsRead'
    action generateReport() returns LargeBinary;
  };

  // ============================================
  // CASH FLOWS
  // ============================================
  @requires: ['EconomicsRead', 'Admin']
  entity CashFlows as projection on econ.CashFlows {
    *,
    analysis : redirected to EconomicsAnalyses
  };

  // ============================================
  // HURDLE RATES
  // ============================================
  @odata.draft.enabled
  @requires: ['EconomicsRead', 'Admin']
  entity HurdleRates as projection on econ.HurdleRates {
    *,
    field : redirected to Fields
  } actions {
    @requires: 'Admin'
    action activate() returns HurdleRates;

    @requires: 'Admin'
    action deactivate() returns HurdleRates;
  };

  // ============================================
  // SCENARIOS
  // ============================================
  @requires: ['EconomicsRead', 'Admin']
  entity Scenarios as projection on econ.Scenarios {
    *,
    analysis : redirected to EconomicsAnalyses
  } actions {
    @requires: 'EconomicsWrite'
    action calculate() returns Scenarios;
  };

  // ============================================
  // SENSITIVITY RESULTS
  // ============================================
  @readonly
  entity SensitivityResults as projection on econ.SensitivityResults {
    *,
    analysis : redirected to EconomicsAnalyses
  };

  // ============================================
  // ECONOMICS ASSUMPTIONS
  // ============================================
  @requires: ['EconomicsRead', 'Admin']
  entity EconomicsAssumptions as projection on econ.EconomicsAssumptions {
    *,
    analysis : redirected to EconomicsAnalyses
  };

  // ============================================
  // PRICE DECKS
  // ============================================
  @odata.draft.enabled
  @requires: ['EconomicsRead', 'Admin']
  entity PriceDecks as projection on econ.PriceDecks {
    *,
    prices : redirected to PriceDeckItems
  } actions {
    @requires: 'Admin'
    action approve() returns PriceDecks;

    @requires: 'EconomicsWrite'
    action copyDeck(newName: String) returns PriceDecks;
  };

  @requires: ['EconomicsRead', 'Admin']
  entity PriceDeckItems as projection on econ.PriceDeckItems {
    *,
    deck : redirected to PriceDecks,
    currency : redirected to Currencies
  };

  // ============================================
  // REFERENCE ENTITIES
  // ============================================
  @readonly
  entity Wells as projection on master.Wells;

  @readonly
  entity Fields as projection on master.Fields;

  @readonly
  entity AFEs as projection on afe.AFEs;

  @readonly
  entity Currencies as projection on master.Currencies;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getAnalysesByWell(wellId: UUID) returns array of EconomicsAnalyses;
  function getActiveHurdleRate(rateType: String, fieldId: UUID) returns HurdleRates;
  function getActivePriceDeck() returns PriceDecks;

  function calculateNPVPreview(
    cashFlows: array of { year: Integer; netCashFlow: Decimal },
    discountRate: Decimal
  ) returns Decimal;

  function calculateIRRPreview(
    cashFlows: array of { year: Integer; netCashFlow: Decimal }
  ) returns Decimal;

  function getTornadoChartData(analysisId: UUID) returns array of {
    variable: String;
    baseNPV: Decimal;
    lowNPV: Decimal;
    highNPV: Decimal;
    impact: Decimal;
  };

  function getMonteCarloDistribution(analysisId: UUID) returns {
    p10: Decimal;
    p50: Decimal;
    p90: Decimal;
    mean: Decimal;
    stdDev: Decimal;
  };

  // ============================================
  // ACTIONS
  // ============================================
  @requires: 'EconomicsWrite'
  action createAnalysisFromAFE(afeId: UUID, analysisName: String) returns EconomicsAnalyses;

  @requires: 'EconomicsWrite'
  action compareScenarios(analysisIds: array of UUID) returns array of {
    analysisId: UUID;
    analysisName: String;
    npv: Decimal;
    irr: Decimal;
    payback: Decimal;
    recommendation: String;
  };
}
