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
    vendor_ID
  ],

  UI.LineItem: [
    { Value: documentNumber, Label: 'Document #' },
    { Value: postingDate, Label: 'Posting Date' },
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Qty' },
    { Value: amount, Label: 'Amount' },
    { Value: s4DocumentNumber, Label: 'S/4 Doc #' }
  ]
);

annotate FinancialService.CostActuals with {
  ID @UI.Hidden;
  documentNumber @title: 'Document Number';
  postingDate @title: 'Posting Date';
  description @title: 'Description';
  amount @title: 'Amount';
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
    { Value: purchaseOrder, Label: 'PO Number' },
    { Value: poLineItem, Label: 'PO Line' },
    { Value: description, Label: 'Description' },
    { Value: committedAmount, Label: 'Committed' },
    { Value: consumedAmount, Label: 'Consumed' },
    { Value: remainingAmount, Label: 'Remaining' },
    { Value: status, Label: 'Status' }
  ]
);

annotate FinancialService.Commitments with {
  ID @UI.Hidden;
  purchaseOrder @title: 'PO Number';
  committedAmount @title: 'Committed Amount';
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
    TypeNamePlural: 'Partner Interests'
  },

  UI.SelectionFields: [
    well_ID,
    partner_ID,
    consentStatus
  ],

  UI.LineItem: [
    { Value: workingInterest, Label: 'Working Interest %' },
    { Value: netRevenueInterest, Label: 'NRI %' },
    { Value: consentStatus, Label: 'Consent Status' },
    { Value: effectiveFromDate, Label: 'Effective From' },
    { Value: effectiveToDate, Label: 'Effective To' }
  ]
);

annotate FinancialService.PartnerInterests with {
  ID @UI.Hidden;
  workingInterest @title: 'Working Interest %';
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
    Title: { Value: statementNumber }
  },

  UI.SelectionFields: [
    well_ID,
    partner_ID,
    status,
    periodYear
  ],

  UI.LineItem: [
    { Value: statementNumber, Label: 'Statement #' },
    { Value: periodYear, Label: 'Year' },
    { Value: periodMonth, Label: 'Month' },
    { Value: grossAmount, Label: 'Gross Amount' },
    { Value: partnerShare, Label: 'Partner Share' },
    { Value: status, Label: 'Status' },
    { Value: dueDate, Label: 'Due Date' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'LineItemsFacet',
      Label: 'Line Items',
      Target: 'lineItems/@UI.LineItem'
    }
  ]
);

annotate FinancialService.JIBStatements with {
  ID @UI.Hidden;
  statementNumber @title: 'Statement Number';
  grossAmount @title: 'Gross Amount';
  partnerShare @title: 'Partner Share';
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
    { Value: description, Label: 'Description' },
    { Value: grossAmount, Label: 'Gross Amount' },
    { Value: partnerShare, Label: 'Partner Share' }
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
    TypeNamePlural: 'Variances'
  },

  UI.SelectionFields: [
    afe_ID,
    status
  ],

  UI.LineItem: [
    { Value: budgetAmount, Label: 'Budget' },
    { Value: actualAmount, Label: 'Actual' },
    { Value: varianceAmount, Label: 'Variance' },
    { Value: variancePercent, Label: 'Var %' },
    { Value: status, Label: 'Status' }
  ]
);

annotate FinancialService.Variances with {
  ID @UI.Hidden;
  budgetAmount @title: 'Budget Amount';
  actualAmount @title: 'Actual Amount';
  varianceAmount @title: 'Variance Amount';
}
