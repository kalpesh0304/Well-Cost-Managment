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
    { Value: afeNumber, Label: 'AFE Number', ![@UI.Importance]: #High },
    { Value: afeName, Label: 'AFE Name', ![@UI.Importance]: #High },
    { Value: well.wellName, Label: 'Well', ![@UI.Importance]: #High },
    { Value: afeType, Label: 'Type' },
    { Value: estimatedCost, Label: 'Estimated Cost', ![@UI.Importance]: #High },
    { Value: currency.code, Label: 'Currency' },
    { Value: approvalStatus, Label: 'Approval Status', ![@UI.Importance]: #High, Criticality: approvalStatusCriticality },
    { Value: status, Label: 'Status', Criticality: statusCriticality },
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
      ID: 'ApprovalInfoFacet',
      Label: 'Approval Information',
      Target: '@UI.FieldGroup#ApprovalInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'S4InfoFacet',
      Label: 'SAP S/4HANA',
      Target: '@UI.FieldGroup#S4Info'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'LineItemsFacet',
      Label: 'Line Items',
      Target: 'lineItems/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'WBSElementsFacet',
      Label: 'WBS Elements',
      Target: 'wbsElements/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ApprovalsFacet',
      Label: 'Approvals',
      Target: 'approvals/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'DocumentsFacet',
      Label: 'Documents',
      Target: 'documents/@UI.LineItem'
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
      { Value: currency_code, Label: 'Currency' },
      { Value: contingencyAmount, Label: 'Contingency Amount' },
      { Value: contingencyPct, Label: 'Contingency %' }
    ]
  },

  UI.FieldGroup#ApprovalInfo: {
    Label: 'Approval Information',
    Data: [
      { Value: approvalStatus, Label: 'Approval Status' },
      { Value: approvedDate, Label: 'Approved Date' },
      { Value: approvedBy, Label: 'Approved By' },
      { Value: parentAFE_ID, Label: 'Parent AFE' }
    ]
  },

  UI.FieldGroup#S4Info: {
    Label: 'SAP S/4HANA Integration',
    Data: [
      { Value: s4ProjectNo, Label: 'S/4 Project Number' },
      { Value: s4WBSElement, Label: 'S/4 WBS Element' },
      { Value: s4hanaSyncStatus, Label: 'Sync Status' },
      { Value: s4hanaLastSyncAt, Label: 'Last Sync' }
    ]
  }
);

// Virtual fields for criticality
annotate AFEService.AFEs with {
  approvalStatusCriticality @Core.Computed;
  statusCriticality @Core.Computed;
}

// Field labels and value helps
annotate AFEService.AFEs with {
  ID @UI.Hidden;
  afeNumber @title: 'AFE Number' @Common.FieldControl: #Mandatory;
  afeName @title: 'AFE Name' @Common.FieldControl: #Mandatory;
  afeType @title: 'AFE Type' @Common.FieldControl: #Mandatory;
  well @title: 'Well' @Common.FieldControl: #Mandatory @Common.ValueList: {
    CollectionPath: 'Wells',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: well_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'wellName' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'uwi' }
    ]
  };
  estimatedCost @title: 'Estimated Cost' @Measures.ISOCurrency: currency_code;
  currency @title: 'Currency' @Common.ValueList: {
    CollectionPath: 'Currencies',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: currency_code, ValueListProperty: 'code' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
    ]
  };
  contingencyAmount @title: 'Contingency Amount' @Measures.ISOCurrency: currency_code;
  contingencyPct @title: 'Contingency %';
  validFromDate @title: 'Valid From';
  validToDate @title: 'Valid To';
  approvalStatus @title: 'Approval Status';
  status @title: 'Status';
  versionNumber @title: 'Version';
  s4ProjectNo @title: 'S/4 Project No';
  s4WBSElement @title: 'S/4 WBS Element';
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
    { Value: lineNumber, Label: 'Line #', ![@UI.Importance]: #High },
    { Value: description, Label: 'Description', ![@UI.Importance]: #High },
    { Value: wbsElement.elementName, Label: 'WBS Element' },
    { Value: costElement.elementName, Label: 'Cost Element' },
    { Value: vendor.vendorName, Label: 'Vendor' },
    { Value: quantity, Label: 'Quantity' },
    { Value: uom.code, Label: 'UOM' },
    { Value: unitRate, Label: 'Unit Rate' },
    { Value: estimatedAmount, Label: 'Amount', ![@UI.Importance]: #High },
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
      { Value: wbsElement_ID, Label: 'WBS Element' },
      { Value: costElement_ID, Label: 'Cost Element' },
      { Value: vendor_ID, Label: 'Vendor' },
      { Value: quantity, Label: 'Quantity' },
      { Value: uom_ID, Label: 'Unit of Measure' },
      { Value: unitRate, Label: 'Unit Rate' },
      { Value: estimatedAmount, Label: 'Estimated Amount' },
      { Value: currency_code, Label: 'Currency' },
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
  lineNumber @title: 'Line #' @Common.FieldControl: #Mandatory;
  description @title: 'Description' @Common.FieldControl: #Mandatory;
  quantity @title: 'Quantity' @Common.FieldControl: #Mandatory;
  unitRate @title: 'Unit Rate' @Common.FieldControl: #Mandatory;
  estimatedAmount @title: 'Amount' @Measures.ISOCurrency: currency_code;
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
    { Value: elementCode, Label: 'Code', ![@UI.Importance]: #High },
    { Value: elementName, Label: 'Name', ![@UI.Importance]: #High },
    { Value: hierarchyLevel, Label: 'Level' },
    { Value: parent.elementName, Label: 'Parent' },
    { Value: sortOrder, Label: 'Sort Order' },
    { Value: s4WBSElement, Label: 'S/4 WBS' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate AFEService.WBSElements with {
  ID @UI.Hidden;
  afe @UI.Hidden;
  elementCode @title: 'Element Code' @Common.FieldControl: #Mandatory;
  elementName @title: 'Element Name' @Common.FieldControl: #Mandatory;
  hierarchyLevel @title: 'Hierarchy Level' @Common.FieldControl: #Mandatory;
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
    { Value: description, Label: 'Description', ![@UI.Importance]: #High },
    { Value: wbsElement.elementName, Label: 'WBS Element' },
    { Value: costElement.elementName, Label: 'Cost Element' },
    { Value: quantity, Label: 'Quantity' },
    { Value: unitRate, Label: 'Unit Rate' },
    { Value: estimatedAmount, Label: 'Amount', ![@UI.Importance]: #High },
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
    { Value: approvalLevel, Label: 'Level', ![@UI.Importance]: #High },
    { Value: approverRole, Label: 'Role', ![@UI.Importance]: #High },
    { Value: approverName, Label: 'Approver', ![@UI.Importance]: #High },
    { Value: assignedDate, Label: 'Assigned' },
    { Value: dueDate, Label: 'Due Date' },
    { Value: actionStatus, Label: 'Status', ![@UI.Importance]: #High, Criticality: actionStatusCriticality },
    { Value: actionDate, Label: 'Action Date' },
    { Value: comments, Label: 'Comments' }
  ]
);

annotate AFEService.Approvals with {
  actionStatusCriticality @Core.Computed;
}

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
    { Value: documentName, Label: 'Name', ![@UI.Importance]: #High },
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
    { Value: uwi, Label: 'UWI' },
    { Value: field.fieldName, Label: 'Field' },
    { Value: wellType, Label: 'Type' },
    { Value: status, Label: 'Status' }
  ]
);
