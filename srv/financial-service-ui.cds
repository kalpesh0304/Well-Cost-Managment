// UI Annotations for Financial Service
using FinancialService from './financial-service';

// ============================================
// COST ACTUALS
// ============================================
annotate FinancialService.CostActuals with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cost Actual',
    TypeNamePlural: 'Cost Actuals',
    Title: { Value: documentNumber },
    Description: { Value: description }
  },

  UI.SelectionFields: [
    afe_ID,
    costElement_ID,
    vendor_ID,
    postingDate
  ],

  UI.LineItem: [
    { Value: documentNumber, Label: 'Document #', ![@UI.Importance]: #High },
    { Value: postingDate, Label: 'Posting Date', ![@UI.Importance]: #High },
    { Value: afe.afeNumber, Label: 'AFE', ![@UI.Importance]: #High },
    { Value: costElement.elementName, Label: 'Cost Element' },
    { Value: vendor.vendorName, Label: 'Vendor' },
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Qty' },
    { Value: amount, Label: 'Amount', ![@UI.Importance]: #High },
    { Value: currency.currencyCode, Label: 'Curr' },
    { Value: s4DocumentNumber, Label: 'S/4 Doc #' }
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
      ID: 'AmountInfoFacet',
      Label: 'Amount Details',
      Target: '@UI.FieldGroup#AmountInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'S4InfoFacet',
      Label: 'SAP S/4HANA',
      Target: '@UI.FieldGroup#S4Info'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: documentNumber, Label: 'Document Number' },
      { Value: postingDate, Label: 'Posting Date' },
      { Value: afe_ID, Label: 'AFE' },
      { Value: wbsElement_ID, Label: 'WBS Element' },
      { Value: costElement_ID, Label: 'Cost Element' },
      { Value: vendor_ID, Label: 'Vendor' },
      { Value: description, Label: 'Description' }
    ]
  },

  UI.FieldGroup#AmountInfo: {
    Label: 'Amount Details',
    Data: [
      { Value: quantity, Label: 'Quantity' },
      { Value: uom_ID, Label: 'Unit of Measure' },
      { Value: unitRate, Label: 'Unit Rate' },
      { Value: amount, Label: 'Amount' },
      { Value: currency_code, Label: 'Currency' }
    ]
  },

  UI.FieldGroup#S4Info: {
    Label: 'SAP S/4HANA Integration',
    Data: [
      { Value: s4DocumentNumber, Label: 'S/4 Document Number' },
      { Value: s4FiscalYear, Label: 'S/4 Fiscal Year' },
      { Value: s4CompanyCode, Label: 'S/4 Company Code' },
      { Value: s4hanaSyncStatus, Label: 'Sync Status' },
      { Value: s4hanaLastSyncAt, Label: 'Last Sync' }
    ]
  }
);

annotate FinancialService.CostActuals with {
  ID @UI.Hidden;
  documentNumber @title: 'Document Number';
  postingDate @title: 'Posting Date' @Common.FieldControl: #Mandatory;
  description @title: 'Description';
  amount @title: 'Amount' @Common.FieldControl: #Mandatory @Measures.ISOCurrency: currency_code;
  afe @title: 'AFE' @Common.FieldControl: #Mandatory @Common.ValueList: {
    CollectionPath: 'AFEs',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: afe_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'afeNumber' }
    ]
  };
}

// ============================================
// COMMITMENTS
// ============================================
annotate FinancialService.Commitments with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: false }
  },

  UI.HeaderInfo: {
    TypeName: 'Commitment',
    TypeNamePlural: 'Commitments',
    Title: { Value: purchaseOrder },
    Description: { Value: description }
  },

  UI.SelectionFields: [
    afe_ID,
    vendor_ID,
    status
  ],

  UI.LineItem: [
    { Value: purchaseOrder, Label: 'PO Number', ![@UI.Importance]: #High },
    { Value: poLineItem, Label: 'PO Line' },
    { Value: afe.afeNumber, Label: 'AFE', ![@UI.Importance]: #High },
    { Value: vendor.vendorName, Label: 'Vendor', ![@UI.Importance]: #High },
    { Value: description, Label: 'Description' },
    { Value: committedAmount, Label: 'Committed', ![@UI.Importance]: #High },
    { Value: consumedAmount, Label: 'Consumed' },
    { Value: remainingAmount, Label: 'Remaining' },
    { Value: status, Label: 'Status', Criticality: statusCriticality }
  ]
);

annotate FinancialService.Commitments with {
  ID @UI.Hidden;
  statusCriticality @Core.Computed;
  purchaseOrder @title: 'PO Number' @Common.FieldControl: #Mandatory;
  committedAmount @title: 'Committed Amount' @Measures.ISOCurrency: currency_code;
  consumedAmount @title: 'Consumed Amount' @Measures.ISOCurrency: currency_code;
  remainingAmount @title: 'Remaining Amount' @Measures.ISOCurrency: currency_code;
}

// ============================================
// PARTNER INTERESTS
// ============================================
annotate FinancialService.PartnerInterests with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Partner Interest',
    TypeNamePlural: 'Partner Interests',
    Title: { Value: partner.partnerName },
    Description: { Value: well.wellName }
  },

  UI.SelectionFields: [
    well_ID,
    partner_ID,
    consentStatus
  ],

  UI.LineItem: [
    { Value: well.wellName, Label: 'Well', ![@UI.Importance]: #High },
    { Value: partner.partnerName, Label: 'Partner', ![@UI.Importance]: #High },
    { Value: workingInterest, Label: 'Working Interest %', ![@UI.Importance]: #High },
    { Value: netRevenueInterest, Label: 'NRI %' },
    { Value: consentStatus, Label: 'Consent Status', Criticality: consentCriticality },
    { Value: effectiveFromDate, Label: 'Effective From' },
    { Value: effectiveToDate, Label: 'Effective To' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'Interest Details',
      Target: '@UI.FieldGroup#GeneralInfo'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'Interest Details',
    Data: [
      { Value: well_ID, Label: 'Well' },
      { Value: afe_ID, Label: 'AFE' },
      { Value: partner_ID, Label: 'Partner' },
      { Value: workingInterest, Label: 'Working Interest %' },
      { Value: netRevenueInterest, Label: 'Net Revenue Interest %' },
      { Value: consentStatus, Label: 'Consent Status' },
      { Value: effectiveFromDate, Label: 'Effective From' },
      { Value: effectiveToDate, Label: 'Effective To' }
    ]
  }
);

annotate FinancialService.PartnerInterests with {
  ID @UI.Hidden;
  consentCriticality @Core.Computed;
  well @title: 'Well' @Common.FieldControl: #Mandatory;
  partner @title: 'Partner' @Common.FieldControl: #Mandatory;
  workingInterest @title: 'Working Interest %' @Common.FieldControl: #Mandatory;
}

// ============================================
// JIB STATEMENTS
// ============================================
annotate FinancialService.JIBStatements with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'JIB Statement',
    TypeNamePlural: 'JIB Statements',
    Title: { Value: statementNumber },
    Description: { Value: partner.partnerName }
  },

  UI.SelectionFields: [
    well_ID,
    partner_ID,
    status,
    periodYear
  ],

  UI.LineItem: [
    { Value: statementNumber, Label: 'Statement #', ![@UI.Importance]: #High },
    { Value: well.wellName, Label: 'Well', ![@UI.Importance]: #High },
    { Value: partner.partnerName, Label: 'Partner', ![@UI.Importance]: #High },
    { Value: periodYear, Label: 'Year' },
    { Value: periodMonth, Label: 'Month' },
    { Value: grossAmount, Label: 'Gross Amount', ![@UI.Importance]: #High },
    { Value: partnerShare, Label: 'Partner Share', ![@UI.Importance]: #High },
    { Value: status, Label: 'Status', Criticality: statusCriticality },
    { Value: dueDate, Label: 'Due Date' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'Statement Details',
      Target: '@UI.FieldGroup#GeneralInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'AmountsFacet',
      Label: 'Amounts',
      Target: '@UI.FieldGroup#Amounts'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'LineItemsFacet',
      Label: 'Line Items',
      Target: 'lineItems/@UI.LineItem'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'Statement Details',
    Data: [
      { Value: statementNumber, Label: 'Statement Number' },
      { Value: well_ID, Label: 'Well' },
      { Value: afe_ID, Label: 'AFE' },
      { Value: partner_ID, Label: 'Partner' },
      { Value: periodYear, Label: 'Period Year' },
      { Value: periodMonth, Label: 'Period Month' },
      { Value: status, Label: 'Status' },
      { Value: dueDate, Label: 'Due Date' }
    ]
  },

  UI.FieldGroup#Amounts: {
    Label: 'Amounts',
    Data: [
      { Value: grossAmount, Label: 'Gross Amount' },
      { Value: workingInterest, Label: 'Working Interest %' },
      { Value: partnerShare, Label: 'Partner Share' },
      { Value: currency_code, Label: 'Currency' },
      { Value: paidAmount, Label: 'Paid Amount' },
      { Value: paidDate, Label: 'Paid Date' }
    ]
  }
);

annotate FinancialService.JIBStatements with {
  ID @UI.Hidden;
  statusCriticality @Core.Computed;
  statementNumber @title: 'Statement Number';
  grossAmount @title: 'Gross Amount' @Measures.ISOCurrency: currency_code;
  partnerShare @title: 'Partner Share' @Measures.ISOCurrency: currency_code;
  well @title: 'Well' @Common.FieldControl: #Mandatory;
  partner @title: 'Partner' @Common.FieldControl: #Mandatory;
}

// ============================================
// JIB LINE ITEMS
// ============================================
annotate FinancialService.JIBLineItems with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'JIB Line Item',
    TypeNamePlural: 'JIB Line Items',
    Title: { Value: lineNumber }
  },

  UI.LineItem: [
    { Value: lineNumber, Label: 'Line #' },
    { Value: costElement.elementName, Label: 'Cost Element', ![@UI.Importance]: #High },
    { Value: description, Label: 'Description', ![@UI.Importance]: #High },
    { Value: grossAmount, Label: 'Gross Amount', ![@UI.Importance]: #High },
    { Value: partnerShare, Label: 'Partner Share', ![@UI.Importance]: #High }
  ]
);

// ============================================
// VARIANCES
// ============================================
annotate FinancialService.Variances with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: false }
  },

  UI.HeaderInfo: {
    TypeName: 'Variance',
    TypeNamePlural: 'Variances',
    Title: { Value: afe.afeNumber }
  },

  UI.SelectionFields: [
    afe_ID,
    varianceCategory_ID,
    status
  ],

  UI.LineItem: [
    { Value: afe.afeNumber, Label: 'AFE', ![@UI.Importance]: #High },
    { Value: costElement.elementName, Label: 'Cost Element', ![@UI.Importance]: #High },
    { Value: budgetAmount, Label: 'Budget', ![@UI.Importance]: #High },
    { Value: actualAmount, Label: 'Actual', ![@UI.Importance]: #High },
    { Value: varianceAmount, Label: 'Variance', ![@UI.Importance]: #High, Criticality: varianceCriticality },
    { Value: variancePercent, Label: 'Var %', Criticality: varianceCriticality },
    { Value: varianceCategory.categoryName, Label: 'Category' },
    { Value: status, Label: 'Status' }
  ]
);

annotate FinancialService.Variances with {
  ID @UI.Hidden;
  varianceCriticality @Core.Computed;
  budgetAmount @title: 'Budget Amount' @Measures.ISOCurrency: currency_code;
  actualAmount @title: 'Actual Amount' @Measures.ISOCurrency: currency_code;
  varianceAmount @title: 'Variance Amount' @Measures.ISOCurrency: currency_code;
}

// ============================================
// COST ALLOCATIONS (Read-Only)
// ============================================
annotate FinancialService.CostAllocations with @(
  UI.HeaderInfo: {
    TypeName: 'Cost Allocation',
    TypeNamePlural: 'Cost Allocations'
  },

  UI.LineItem: [
    { Value: afe.afeNumber, Label: 'AFE' },
    { Value: partner.partnerName, Label: 'Partner' },
    { Value: grossAmount, Label: 'Gross Amount' },
    { Value: workingInterest, Label: 'WI %' },
    { Value: netAmount, Label: 'Net Amount' },
    { Value: allocationDate, Label: 'Allocation Date' }
  ]
);
