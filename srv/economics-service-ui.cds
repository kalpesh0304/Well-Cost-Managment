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
    { Value: analysisNumber, Label: 'Analysis #' },
    { Value: analysisName, Label: 'Name' },
    { Value: analysisType, Label: 'Type' },
    { Value: npv, Label: 'NPV' },
    { Value: irr, Label: 'IRR %' },
    { Value: paybackPeriod, Label: 'Payback (yrs)' },
    { Value: profitabilityIndex, Label: 'PI' },
    { Value: status, Label: 'Status' }
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
      ID: 'CashFlowsFacet',
      Label: 'Cash Flows',
      Target: 'cashFlows/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ScenariosFacet',
      Label: 'Scenarios',
      Target: 'scenarios/@UI.LineItem'
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
      { Value: profitabilityIndex, Label: 'Profitability Index (PI)' }
    ]
  }
);

annotate EconomicsService.EconomicsAnalyses with {
  ID @UI.Hidden;
  analysisNumber @title: 'Analysis Number';
  analysisName @title: 'Analysis Name';
  npv @title: 'NPV';
  irr @title: 'IRR %';
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
    { Value: year, Label: 'Year' },
    { Value: revenue, Label: 'Revenue' },
    { Value: opex, Label: 'OPEX' },
    { Value: capex, Label: 'CAPEX' },
    { Value: taxes, Label: 'Taxes' },
    { Value: netCashFlow, Label: 'Net Cash Flow' },
    { Value: cumulativeCashFlow, Label: 'Cumulative CF' },
    { Value: discountedCashFlow, Label: 'Discounted CF' }
  ]
);

annotate EconomicsService.CashFlows with {
  ID @UI.Hidden;
  analysis @UI.Hidden;
  year @title: 'Year';
  netCashFlow @title: 'Net Cash Flow';
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
    { Value: rateName, Label: 'Rate Name' },
    { Value: rateType, Label: 'Type' },
    { Value: rate, Label: 'Rate %' },
    { Value: effectiveFrom, Label: 'Effective From' },
    { Value: effectiveTo, Label: 'Effective To' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate EconomicsService.HurdleRates with {
  ID @UI.Hidden;
  rateName @title: 'Rate Name';
  rateType @title: 'Rate Type';
  rate @title: 'Rate %';
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
    { Value: scenarioName, Label: 'Scenario Name' },
    { Value: scenarioType, Label: 'Type' },
    { Value: probability, Label: 'Probability %' },
    { Value: priceMultiplier, Label: 'Price Mult.' },
    { Value: costMultiplier, Label: 'Cost Mult.' },
    { Value: npv, Label: 'NPV' },
    { Value: irr, Label: 'IRR %' }
  ]
);

annotate EconomicsService.Scenarios with {
  ID @UI.Hidden;
  analysis @UI.Hidden;
  scenarioName @title: 'Scenario Name';
  scenarioType @title: 'Scenario Type';
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
    { Value: deckName, Label: 'Deck Name' },
    { Value: deckType, Label: 'Type' },
    { Value: description, Label: 'Description' },
    { Value: effectiveDate, Label: 'Effective Date' },
    { Value: status, Label: 'Status' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'PricesFacet',
      Label: 'Prices',
      Target: 'prices/@UI.LineItem'
    }
  ]
);

annotate EconomicsService.PriceDecks with {
  ID @UI.Hidden;
  deckName @title: 'Deck Name';
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
    { Value: year, Label: 'Year' },
    { Value: oilPrice, Label: 'Oil Price ($/bbl)' },
    { Value: gasPrice, Label: 'Gas Price ($/mcf)' },
    { Value: nglPrice, Label: 'NGL Price ($/bbl)' }
  ]
);

annotate EconomicsService.PriceDeckItems with {
  ID @UI.Hidden;
  deck @UI.Hidden;
  year @title: 'Year';
  oilPrice @title: 'Oil Price';
  gasPrice @title: 'Gas Price';
}
