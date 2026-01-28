// UI Annotations for AFE Service
using AFEService from './afe-service';

// ============================================
// AFEs - Main Entity
// ============================================
annotate AFEService.AFEs with @(
  // Enable CRUD capabilities
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  // Header information for object page
  UI.HeaderInfo: {
    TypeName: 'AFE',
    TypeNamePlural: 'AFEs',
    Title: { Value: afeNumber },
    Description: { Value: afeName }
  },

  // Filter fields in list report
  UI.SelectionFields: [
    well_ID,
    afeType,
    approvalStatus,
    status
  ],

  // Table columns
  UI.LineItem: [
    { Value: afeNumber, Label: 'AFE Number' },
    { Value: afeName, Label: 'AFE Name' },
    { Value: afeType, Label: 'Type' },
    { Value: estimatedCost, Label: 'Estimated Cost' },
    { Value: approvalStatus, Label: 'Approval Status' },
    { Value: status, Label: 'Status' },
    { Value: validFromDate, Label: 'Valid From' },
    { Value: validToDate, Label: 'Valid To' }
  ],

  // Object page facets
  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'General Information',
      Target: '@UI.FieldGroup#GeneralInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'CostInfoFacet',
      Label: 'Cost Information',
      Target: '@UI.FieldGroup#CostInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'LineItemsFacet',
      Label: 'Line Items',
      Target: 'lineItems/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ApprovalsFacet',
      Label: 'Approvals',
      Target: 'approvals/@UI.LineItem'
    }
  ],

  // Field groups
  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: afeNumber, Label: 'AFE Number' },
      { Value: afeName, Label: 'AFE Name' },
      { Value: afeType, Label: 'AFE Type' },
      { Value: well_ID, Label: 'Well' },
      { Value: validFromDate, Label: 'Valid From' },
      { Value: validToDate, Label: 'Valid To' },
      { Value: versionNumber, Label: 'Version' },
      { Value: status, Label: 'Status' }
    ]
  },

  UI.FieldGroup#CostInfo: {
    Label: 'Cost Information',
    Data: [
      { Value: estimatedCost, Label: 'Estimated Cost' },
      { Value: contingencyAmount, Label: 'Contingency Amount' },
      { Value: contingencyPct, Label: 'Contingency %' }
    ]
  }
);

// Field labels
annotate AFEService.AFEs with {
  ID @UI.Hidden;
  afeNumber @title: 'AFE Number';
  afeName @title: 'AFE Name';
  afeType @title: 'AFE Type';
  estimatedCost @title: 'Estimated Cost';
  approvalStatus @title: 'Approval Status';
  status @title: 'Status';
  validFromDate @title: 'Valid From';
  validToDate @title: 'Valid To';
}

// ============================================
// AFE Line Items
// ============================================
annotate AFEService.AFELineItems with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Line Item',
    TypeNamePlural: 'Line Items',
    Title: { Value: lineNumber },
    Description: { Value: description }
  },

  UI.LineItem: [
    { Value: lineNumber, Label: 'Line #' },
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Quantity' },
    { Value: unitRate, Label: 'Unit Rate' },
    { Value: estimatedAmount, Label: 'Amount' },
    { Value: startDate, Label: 'Start' },
    { Value: endDate, Label: 'End' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'LineItemDetailFacet',
      Label: 'Line Item Details',
      Target: '@UI.FieldGroup#LineItemDetail'
    }
  ],

  UI.FieldGroup#LineItemDetail: {
    Label: 'Line Item Details',
    Data: [
      { Value: lineNumber, Label: 'Line Number' },
      { Value: description, Label: 'Description' },
      { Value: quantity, Label: 'Quantity' },
      { Value: unitRate, Label: 'Unit Rate' },
      { Value: estimatedAmount, Label: 'Estimated Amount' },
      { Value: startDate, Label: 'Start Date' },
      { Value: endDate, Label: 'End Date' },
      { Value: durationDays, Label: 'Duration (Days)' },
      { Value: sourceType, Label: 'Source Type' }
    ]
  }
);

annotate AFEService.AFELineItems with {
  ID @UI.Hidden;
  afe @UI.Hidden;
  lineNumber @title: 'Line #';
  description @title: 'Description';
  quantity @title: 'Quantity';
  unitRate @title: 'Unit Rate';
  estimatedAmount @title: 'Amount';
}

// ============================================
// WBS Elements
// ============================================
annotate AFEService.WBSElements with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'WBS Element',
    TypeNamePlural: 'WBS Elements',
    Title: { Value: elementCode },
    Description: { Value: elementName }
  },

  UI.LineItem: [
    { Value: elementCode, Label: 'Code' },
    { Value: elementName, Label: 'Name' },
    { Value: hierarchyLevel, Label: 'Level' },
    { Value: sortOrder, Label: 'Sort Order' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AFEService.WBSElements with {
  ID @UI.Hidden;
  afe @UI.Hidden;
  elementCode @title: 'Element Code';
  elementName @title: 'Element Name';
  hierarchyLevel @title: 'Hierarchy Level';
}

// ============================================
// Cost Estimates
// ============================================
annotate AFEService.CostEstimates with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cost Estimate',
    TypeNamePlural: 'Cost Estimates',
    Title: { Value: description }
  },

  UI.LineItem: [
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Quantity' },
    { Value: unitRate, Label: 'Unit Rate' },
    { Value: estimatedAmount, Label: 'Amount' },
    { Value: confidenceLevel, Label: 'Confidence' }
  ]
);

// ============================================
// Approvals
// ============================================
annotate AFEService.Approvals with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: false }
  },

  UI.HeaderInfo: {
    TypeName: 'Approval',
    TypeNamePlural: 'Approvals',
    Title: { Value: approverName },
    Description: { Value: approverRole }
  },

  UI.LineItem: [
    { Value: approvalLevel, Label: 'Level' },
    { Value: approverRole, Label: 'Role' },
    { Value: approverName, Label: 'Approver' },
    { Value: assignedDate, Label: 'Assigned' },
    { Value: dueDate, Label: 'Due Date' },
    { Value: actionStatus, Label: 'Status' },
    { Value: actionDate, Label: 'Action Date' },
    { Value: comments, Label: 'Comments' }
  ]
);

// ============================================
// AFE Documents
// ============================================
annotate AFEService.AFEDocuments with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Document',
    TypeNamePlural: 'Documents',
    Title: { Value: documentName }
  },

  UI.LineItem: [
    { Value: documentName, Label: 'Name' },
    { Value: documentType, Label: 'Type' },
    { Value: documentCategory, Label: 'Category' },
    { Value: fileSize, Label: 'Size (bytes)' },
    { Value: uploadedBy, Label: 'Uploaded By' },
    { Value: uploadedAt, Label: 'Uploaded At' }
  ]
);

// ============================================
// Reference Entities (Read-only)
// ============================================
annotate AFEService.Wells with @(
  UI.LineItem: [
    { Value: wellName, Label: 'Well Name' },
    { Value: wellNumber, Label: 'Well Number' },
    { Value: wellType, Label: 'Type' },
    { Value: status, Label: 'Status' }
  ]
);
