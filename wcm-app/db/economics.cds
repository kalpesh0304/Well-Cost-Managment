// Investment Economics Entities
namespace wcm.economics;

using { wcm.common as common } from './common';
using { wcm.master as master } from './master-data';
using { wcm.afe as afe } from './afe';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// ECONOMICS ANALYSIS
// ============================================
entity EconomicsAnalyses : cuid, managed {
  key ID                : UUID;
  analysisName          : String(100) not null;
  well                  : Association to master.Wells;
  afe                   : Association to afe.AFEs;
  analysisType          : String(20) not null; // NEW_WELL, WORKOVER, ACQUISITION
  discountRate          : common.Percentage not null @assert.range: [0, 0.50];
  inflationRate         : common.Percentage;

  // Calculated Results
  npv                   : common.Amount;           // Net Present Value
  irr                   : common.Percentage;       // Internal Rate of Return
  mirr                  : common.Percentage;       // Modified IRR
  paybackYears          : Decimal(5, 2);           // Simple payback
  discountedPayback     : Decimal(5, 2);           // Discounted payback
  profitabilityIndex    : common.Percentage;       // NPV / Investment

  recommendation        : common.Recommendation;
  calculatedAt          : Timestamp;
  status                : common.AnalysisStatus not null default 'Draft';

  // Compositions
  cashFlows             : Composition of many CashFlows on cashFlows.analysis = $self;
  scenarios             : Composition of many Scenarios on scenarios.analysis = $self;
  sensitivities         : Composition of many SensitivityResults on sensitivities.analysis = $self;
  assumptions           : Composition of many EconomicsAssumptions on assumptions.analysis = $self;
}

// ============================================
// CASH FLOWS
// ============================================
entity CashFlows : cuid {
  analysis              : Association to EconomicsAnalyses not null;
  yearNumber            : Integer not null @assert.range: [0,];
  capex                 : common.Amount;
  opex                  : common.Amount;
  revenue               : common.Amount;
  royalty               : common.Amount;
  taxes                 : common.Amount;
  netCashFlow           : common.Amount;           // Calculated
  discountedCashFlow    : common.Amount;           // Calculated
  cumulativeCashFlow    : common.Amount;           // Calculated
  oilProduction         : Decimal(15, 2);          // Barrels
  gasProduction         : Decimal(15, 2);          // MCF
}

// ============================================
// HURDLE RATES
// ============================================
entity HurdleRates : common.MasterData {
  key ID                : UUID;
  rateType              : String(20) not null; // CORPORATE, ASSET, PROJECT
  field                 : Association to master.Fields;
  rateName              : String(50) not null;
  rateValue             : common.Percentage not null @assert.range: [0, 0.50];
  riskPremium           : common.Percentage;
  effectiveFromDate     : Date not null;
  effectiveToDate       : Date;
  approvedBy            : String(100);
}

// ============================================
// SCENARIOS (P10/P50/P90)
// ============================================
entity Scenarios : cuid {
  analysis              : Association to EconomicsAnalyses not null;
  scenarioType          : String(20) not null; // P10, P50, P90, BASE
  scenarioName          : String(100);
  npv                   : common.Amount;
  irr                   : common.Percentage;
  probability           : Decimal(5, 4);

  // Scenario-specific parameters
  oilPrice              : common.Amount;
  gasPrice              : common.Amount;
  capexMultiplier       : common.Percentage;
  opexMultiplier        : common.Percentage;
  productionMultiplier  : common.Percentage;
}

// ============================================
// SENSITIVITY ANALYSIS
// ============================================
entity SensitivityResults : cuid {
  analysis              : Association to EconomicsAnalyses not null;
  variableName          : String(50) not null; // Oil Price, CAPEX, OPEX, Production
  baseValue             : Decimal(15, 4);
  lowValue              : Decimal(15, 4);
  highValue             : Decimal(15, 4);
  npvLow                : common.Amount;
  npvHigh               : common.Amount;
  impactRange           : common.Amount;        // Calculated: npvHigh - npvLow
  sortOrder             : Integer;              // By impact magnitude
}

// ============================================
// ECONOMICS ASSUMPTIONS
// ============================================
entity EconomicsAssumptions : cuid {
  analysis              : Association to EconomicsAnalyses not null;
  assumptionType        : String(50) not null;
  assumptionName        : String(100) not null;
  assumptionValue       : String(200);
  numericValue          : Decimal(15, 4);
  unit                  : String(20);
  source                : String(100);
  effectiveDate         : Date;
}

// ============================================
// PRICE DECKS
// ============================================
entity PriceDecks : common.MasterData {
  key ID                : UUID;
  deckName              : String(100) not null;
  deckType              : String(20); // OFFICIAL, PLANNING, SCENARIO
  effectiveFromDate     : Date not null;
  effectiveToDate       : Date;
  approvedBy            : String(100);
  approvedAt            : Timestamp;

  prices                : Composition of many PriceDeckItems on prices.deck = $self;
}

entity PriceDeckItems : cuid {
  deck                  : Association to PriceDecks not null;
  yearNumber            : Integer not null;
  oilPrice              : common.Amount;         // $/bbl
  gasPrice              : common.Amount;         // $/MCF
  nglPrice              : common.Amount;         // $/bbl
  currency              : Association to master.Currencies;
}
