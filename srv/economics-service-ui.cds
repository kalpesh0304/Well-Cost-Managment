// UI Annotations for Economics Service
using EconomicsService from './economics-service';

// ============================================
// ECONOMICS ANALYSES
// ============================================
annotate EconomicsService.EconomicsAnalyses with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Economics Analysis',
    TypeNamePlural: 'Economics Analyses',
    Title: { Value: analysisNumber },
    Description: { Value: analysisName }
  },

  UI.SelectionFields: [
    well_ID,
    analysisType,
    status
  ],

  UI.LineItem: [
    { Value: analysisNumber, Label: 'Analysis #', ![@UI.Importance]: #High },
    { Value: analysisName, Label: 'Name', ![@UI.Importance]: #High },
    { Value: well.wellName, Label: 'Well', ![@UI.Importance]: #High },
    { Value: analysisType, Label: 'Type' },
    { Value: npv, Label: 'NPV', ![@UI.Importance]: #High },
    { Value: irr, Label: 'IRR %', ![@UI.Importance]: #High },
    { Value: paybackPeriod, Label: 'Payback (yrs)' },
    { Value: profitabilityIndex, Label: 'PI' },
    { Value: status, Label: 'Status', Criticality: statusCriticality }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'General Information',
      Target: '@UI.FieldGroup#GeneralInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ResultsFacet',
      Label: 'Analysis Results',
      Target: '@UI.FieldGroup#Results'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'MonteCarloFacet',
      Label: 'Monte Carlo Results',
      Target: '@UI.FieldGroup#MonteCarlo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'CashFlowsFacet',
      Label: 'Cash Flows',
      Target: 'cashFlows/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ScenariosFacet',
      Label: 'Scenarios',
      Target: 'scenarios/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'SensitivitiesFacet',
      Label: 'Sensitivity Analysis',
      Target: 'sensitivities/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'AssumptionsFacet',
      Label: 'Assumptions',
      Target: 'assumptions/@UI.LineItem'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: analysisNumber, Label: 'Analysis Number' },
      { Value: analysisName, Label: 'Analysis Name' },
      { Value: analysisType, Label: 'Analysis Type' },
      { Value: well_ID, Label: 'Well' },
      { Value: afe_ID, Label: 'AFE' },
      { Value: discountRate, Label: 'Discount Rate %' },
      { Value: analysisDate, Label: 'Analysis Date' },
      { Value: status, Label: 'Status' }
    ]
  },

  UI.FieldGroup#Results: {
    Label: 'Analysis Results',
    Data: [
      { Value: npv, Label: 'Net Present Value (NPV)' },
      { Value: irr, Label: 'Internal Rate of Return (IRR) %' },
      { Value: paybackPeriod, Label: 'Payback Period (Years)' },
      { Value: profitabilityIndex, Label: 'Profitability Index (PI)' },
      { Value: totalCapex, Label: 'Total CAPEX' },
      { Value: totalOpex, Label: 'Total OPEX' },
      { Value: totalRevenue, Label: 'Total Revenue' }
    ]
  },

  UI.FieldGroup#MonteCarlo: {
    Label: 'Monte Carlo Results',
    Data: [
      { Value: npvP10, Label: 'NPV P10' },
      { Value: npvP50, Label: 'NPV P50' },
      { Value: npvP90, Label: 'NPV P90' },
      { Value: npvMean, Label: 'NPV Mean' },
      { Value: monteCarloIterations, Label: 'Iterations' }
    ]
  }
);

annotate EconomicsService.EconomicsAnalyses with {
  ID @UI.Hidden;
  statusCriticality @Core.Computed;
  analysisNumber @title: 'Analysis Number';
  analysisName @title: 'Analysis Name' @Common.FieldControl: #Mandatory;
  analysisType @title: 'Analysis Type';
  discountRate @title: 'Discount Rate %';
  npv @title: 'NPV' @Measures.ISOCurrency: currency_code;
  irr @title: 'IRR %';
  paybackPeriod @title: 'Payback Period (Years)';
  profitabilityIndex @title: 'Profitability Index';
  well @title: 'Well' @Common.FieldControl: #Mandatory;
}

// ============================================
// CASH FLOWS
// ============================================
annotate EconomicsService.CashFlows with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cash Flow',
    TypeNamePlural: 'Cash Flows',
    Title: { Value: year }
  },

  UI.LineItem: [
    { Value: year, Label: 'Year', ![@UI.Importance]: #High },
    { Value: revenue, Label: 'Revenue', ![@UI.Importance]: #High },
    { Value: opex, Label: 'OPEX' },
    { Value: capex, Label: 'CAPEX' },
    { Value: taxes, Label: 'Taxes' },
    { Value: netCashFlow, Label: 'Net Cash Flow', ![@UI.Importance]: #High },
    { Value: cumulativeCashFlow, Label: 'Cumulative CF' },
    { Value: discountedCashFlow, Label: 'Discounted CF' }
  ]
);

annotate EconomicsService.CashFlows with {
  ID @UI.Hidden;
  analysis @UI.Hidden;
  year @title: 'Year' @Common.FieldControl: #Mandatory;
  revenue @title: 'Revenue' @Measures.ISOCurrency: currency_code;
  opex @title: 'OPEX' @Measures.ISOCurrency: currency_code;
  capex @title: 'CAPEX' @Measures.ISOCurrency: currency_code;
  netCashFlow @title: 'Net Cash Flow' @Measures.ISOCurrency: currency_code;
}

// ============================================
// HURDLE RATES
// ============================================
annotate EconomicsService.HurdleRates with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Hurdle Rate',
    TypeNamePlural: 'Hurdle Rates',
    Title: { Value: rateName }
  },

  UI.SelectionFields: [
    rateType,
    field_ID,
    isActive
  ],

  UI.LineItem: [
    { Value: rateName, Label: 'Rate Name', ![@UI.Importance]: #High },
    { Value: rateType, Label: 'Type', ![@UI.Importance]: #High },
    { Value: rate, Label: 'Rate %', ![@UI.Importance]: #High },
    { Value: field.fieldName, Label: 'Field' },
    { Value: effectiveFrom, Label: 'Effective From' },
    { Value: effectiveTo, Label: 'Effective To' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate EconomicsService.HurdleRates with {
  ID @UI.Hidden;
  rateName @title: 'Rate Name' @Common.FieldControl: #Mandatory;
  rateType @title: 'Rate Type' @Common.FieldControl: #Mandatory;
  rate @title: 'Rate %' @Common.FieldControl: #Mandatory;
}

// ============================================
// SCENARIOS
// ============================================
annotate EconomicsService.Scenarios with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Scenario',
    TypeNamePlural: 'Scenarios',
    Title: { Value: scenarioName }
  },

  UI.LineItem: [
    { Value: scenarioName, Label: 'Scenario Name', ![@UI.Importance]: #High },
    { Value: scenarioType, Label: 'Type', ![@UI.Importance]: #High },
    { Value: probability, Label: 'Probability %' },
    { Value: priceMultiplier, Label: 'Price Mult.' },
    { Value: costMultiplier, Label: 'Cost Mult.' },
    { Value: npv, Label: 'NPV', ![@UI.Importance]: #High },
    { Value: irr, Label: 'IRR %' }
  ]
);

annotate EconomicsService.Scenarios with {
  ID @UI.Hidden;
  analysis @UI.Hidden;
  scenarioName @title: 'Scenario Name' @Common.FieldControl: #Mandatory;
  scenarioType @title: 'Scenario Type' @Common.FieldControl: #Mandatory;
  npv @title: 'NPV' @Measures.ISOCurrency: currency_code;
}

// ============================================
// SENSITIVITY RESULTS
// ============================================
annotate EconomicsService.SensitivityResults with @(
  UI.HeaderInfo: {
    TypeName: 'Sensitivity Result',
    TypeNamePlural: 'Sensitivity Results',
    Title: { Value: variable }
  },

  UI.LineItem: [
    { Value: variable, Label: 'Variable', ![@UI.Importance]: #High },
    { Value: baseValue, Label: 'Base Value' },
    { Value: lowValue, Label: 'Low Value' },
    { Value: highValue, Label: 'High Value' },
    { Value: baseNPV, Label: 'Base NPV' },
    { Value: lowNPV, Label: 'Low NPV' },
    { Value: highNPV, Label: 'High NPV' },
    { Value: npvImpact, Label: 'NPV Impact', ![@UI.Importance]: #High }
  ]
);

// ============================================
// ECONOMICS ASSUMPTIONS
// ============================================
annotate EconomicsService.EconomicsAssumptions with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Assumption',
    TypeNamePlural: 'Assumptions',
    Title: { Value: assumptionType }
  },

  UI.LineItem: [
    { Value: assumptionType, Label: 'Type', ![@UI.Importance]: #High },
    { Value: assumptionName, Label: 'Name', ![@UI.Importance]: #High },
    { Value: value, Label: 'Value', ![@UI.Importance]: #High },
    { Value: unit, Label: 'Unit' },
    { Value: source, Label: 'Source' },
    { Value: notes, Label: 'Notes' }
  ]
);

annotate EconomicsService.EconomicsAssumptions with {
  ID @UI.Hidden;
  analysis @UI.Hidden;
  assumptionType @title: 'Assumption Type' @Common.FieldControl: #Mandatory;
  assumptionName @title: 'Assumption Name' @Common.FieldControl: #Mandatory;
  value @title: 'Value' @Common.FieldControl: #Mandatory;
}

// ============================================
// PRICE DECKS
// ============================================
annotate EconomicsService.PriceDecks with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Price Deck',
    TypeNamePlural: 'Price Decks',
    Title: { Value: deckName },
    Description: { Value: description }
  },

  UI.SelectionFields: [
    deckType,
    status,
    isActive
  ],

  UI.LineItem: [
    { Value: deckName, Label: 'Deck Name', ![@UI.Importance]: #High },
    { Value: deckType, Label: 'Type' },
    { Value: description, Label: 'Description' },
    { Value: effectiveDate, Label: 'Effective Date', ![@UI.Importance]: #High },
    { Value: status, Label: 'Status', Criticality: statusCriticality },
    { Value: isActive, Label: 'Active', ![@UI.Importance]: #High }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'Deck Details',
      Target: '@UI.FieldGroup#GeneralInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'PricesFacet',
      Label: 'Prices',
      Target: 'prices/@UI.LineItem'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'Deck Details',
    Data: [
      { Value: deckName, Label: 'Deck Name' },
      { Value: deckType, Label: 'Deck Type' },
      { Value: description, Label: 'Description' },
      { Value: effectiveDate, Label: 'Effective Date' },
      { Value: expirationDate, Label: 'Expiration Date' },
      { Value: status, Label: 'Status' },
      { Value: isActive, Label: 'Active' }
    ]
  }
);

annotate EconomicsService.PriceDecks with {
  ID @UI.Hidden;
  statusCriticality @Core.Computed;
  deckName @title: 'Deck Name' @Common.FieldControl: #Mandatory;
  deckType @title: 'Deck Type';
}

// ============================================
// PRICE DECK ITEMS
// ============================================
annotate EconomicsService.PriceDeckItems with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Price',
    TypeNamePlural: 'Prices',
    Title: { Value: year }
  },

  UI.LineItem: [
    { Value: year, Label: 'Year', ![@UI.Importance]: #High },
    { Value: oilPrice, Label: 'Oil Price ($/bbl)', ![@UI.Importance]: #High },
    { Value: gasPrice, Label: 'Gas Price ($/mcf)', ![@UI.Importance]: #High },
    { Value: nglPrice, Label: 'NGL Price ($/bbl)' },
    { Value: currency.currencyCode, Label: 'Currency' }
  ]
);

annotate EconomicsService.PriceDeckItems with {
  ID @UI.Hidden;
  deck @UI.Hidden;
  year @title: 'Year' @Common.FieldControl: #Mandatory;
  oilPrice @title: 'Oil Price' @Measures.ISOCurrency: currency_code;
  gasPrice @title: 'Gas Price' @Measures.ISOCurrency: currency_code;
  nglPrice @title: 'NGL Price' @Measures.ISOCurrency: currency_code;
}
