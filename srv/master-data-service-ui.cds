// UI Annotations for Master Data Service
using MasterDataService from './master-data-service';

// ============================================
// FIELDS
// ============================================
annotate MasterDataService.Fields with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Field',
    TypeNamePlural: 'Fields',
    Title: { Value: fieldCode },
    Description: { Value: fieldName }
  },

  UI.SelectionFields: [
    region,
    isActive
  ],

  UI.LineItem: [
    { Value: fieldCode, Label: 'Field Code' },
    { Value: fieldName, Label: 'Field Name' },
    { Value: basin, Label: 'Basin' },
    { Value: region, Label: 'Region' },
    { Value: operatorName, Label: 'Operator' },
    { Value: isActive, Label: 'Active' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'General Information',
      Target: '@UI.FieldGroup#GeneralInfo'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: fieldCode, Label: 'Field Code' },
      { Value: fieldName, Label: 'Field Name' },
      { Value: basin, Label: 'Basin' },
      { Value: region, Label: 'Region' },
      { Value: operatorName, Label: 'Operator' },
      { Value: s4ProfitCenter, Label: 'Profit Center' },
      { Value: s4CostCenter, Label: 'Cost Center' },
      { Value: isActive, Label: 'Active' }
    ]
  }
);

annotate MasterDataService.Fields with {
  ID @UI.Hidden;
  fieldCode @title: 'Field Code';
  fieldName @title: 'Field Name';
}

// ============================================
// WELLS
// ============================================
annotate MasterDataService.Wells with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Well',
    TypeNamePlural: 'Wells',
    Title: { Value: wellNumber },
    Description: { Value: wellName }
  },

  UI.SelectionFields: [
    field_ID,
    wellType,
    status,
    isActive
  ],

  UI.LineItem: [
    { Value: wellNumber, Label: 'Well Number' },
    { Value: wellName, Label: 'Well Name' },
    { Value: wellType, Label: 'Type' },
    { Value: wellboreType, Label: 'Wellbore Type' },
    { Value: status, Label: 'Status' },
    { Value: spudDate, Label: 'Spud Date' },
    { Value: totalDepthMD, Label: 'TD (MD)' },
    { Value: isActive, Label: 'Active' }
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
      ID: 'DepthInfoFacet',
      Label: 'Depth Information',
      Target: '@UI.FieldGroup#DepthInfo'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: wellNumber, Label: 'Well Number' },
      { Value: wellName, Label: 'Well Name' },
      { Value: field_ID, Label: 'Field' },
      { Value: wellType, Label: 'Well Type' },
      { Value: wellboreType, Label: 'Wellbore Type' },
      { Value: status, Label: 'Status' },
      { Value: spudDate, Label: 'Spud Date' },
      { Value: isActive, Label: 'Active' }
    ]
  },

  UI.FieldGroup#DepthInfo: {
    Label: 'Depth Information',
    Data: [
      { Value: totalDepthMD, Label: 'Total Depth (MD)' },
      { Value: totalDepthTVD, Label: 'Total Depth (TVD)' },
      { Value: surfaceLatitude, Label: 'Surface Latitude' },
      { Value: surfaceLongitude, Label: 'Surface Longitude' }
    ]
  }
);

annotate MasterDataService.Wells with {
  ID @UI.Hidden;
  wellNumber @title: 'Well Number';
  wellName @title: 'Well Name';
  wellType @title: 'Well Type';
  status @title: 'Status';
}

// ============================================
// COST CATEGORIES
// ============================================
annotate MasterDataService.CostCategories with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cost Category',
    TypeNamePlural: 'Cost Categories',
    Title: { Value: categoryCode },
    Description: { Value: categoryName }
  },

  UI.SelectionFields: [
    categoryType,
    isActive
  ],

  UI.LineItem: [
    { Value: categoryCode, Label: 'Code' },
    { Value: categoryName, Label: 'Name' },
    { Value: categoryType, Label: 'Type' },
    { Value: hierarchyLevel, Label: 'Level' },
    { Value: accountingTreatment, Label: 'Accounting' },
    { Value: s4CostElement, Label: 'S/4 Cost Element' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate MasterDataService.CostCategories with {
  ID @UI.Hidden;
  categoryCode @title: 'Category Code';
  categoryName @title: 'Category Name';
  categoryType @title: 'Category Type';
}

// ============================================
// COST ELEMENTS
// ============================================
annotate MasterDataService.CostElements with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cost Element',
    TypeNamePlural: 'Cost Elements',
    Title: { Value: elementCode },
    Description: { Value: elementName }
  },

  UI.SelectionFields: [
    category_ID,
    isActive
  ],

  UI.LineItem: [
    { Value: elementCode, Label: 'Element Code' },
    { Value: elementName, Label: 'Element Name' },
    { Value: s4GLAccount, Label: 'GL Account' },
    { Value: s4CostElement, Label: 'S/4 Cost Element' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate MasterDataService.CostElements with {
  ID @UI.Hidden;
  elementCode @title: 'Element Code';
  elementName @title: 'Element Name';
}

// ============================================
// VENDORS
// ============================================
annotate MasterDataService.Vendors with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Vendor',
    TypeNamePlural: 'Vendors',
    Title: { Value: vendorCode },
    Description: { Value: vendorName }
  },

  UI.SelectionFields: [
    vendorType,
    isActive
  ],

  UI.LineItem: [
    { Value: vendorCode, Label: 'Vendor Code' },
    { Value: vendorName, Label: 'Vendor Name' },
    { Value: vendorType, Label: 'Type' },
    { Value: s4VendorNo, Label: 'S/4 Vendor #' },
    { Value: contactName, Label: 'Contact' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate MasterDataService.Vendors with {
  ID @UI.Hidden;
  vendorCode @title: 'Vendor Code';
  vendorName @title: 'Vendor Name';
}

// ============================================
// PARTNERS
// ============================================
annotate MasterDataService.Partners with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Partner',
    TypeNamePlural: 'Partners',
    Title: { Value: partnerCode },
    Description: { Value: partnerName }
  },

  UI.SelectionFields: [
    partnerType,
    isActive
  ],

  UI.LineItem: [
    { Value: partnerCode, Label: 'Partner Code' },
    { Value: partnerName, Label: 'Partner Name' },
    { Value: partnerType, Label: 'Type' },
    { Value: workingInterestDefault, Label: 'Default WI %' },
    { Value: contactName, Label: 'Contact' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate MasterDataService.Partners with {
  ID @UI.Hidden;
  partnerCode @title: 'Partner Code';
  partnerName @title: 'Partner Name';
  partnerType @title: 'Partner Type';
}

// ============================================
// WBS TEMPLATES
// ============================================
annotate MasterDataService.WBSTemplates with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'WBS Template',
    TypeNamePlural: 'WBS Templates',
    Title: { Value: templateCode },
    Description: { Value: templateName }
  },

  UI.SelectionFields: [
    wellType,
    region,
    isActive
  ],

  UI.LineItem: [
    { Value: templateCode, Label: 'Template Code' },
    { Value: templateName, Label: 'Template Name' },
    { Value: wellType, Label: 'Well Type' },
    { Value: wellboreType, Label: 'Wellbore Type' },
    { Value: region, Label: 'Region' },
    { Value: hierarchyLevels, Label: 'Levels' },
    { Value: versionNumber, Label: 'Version' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate MasterDataService.WBSTemplates with {
  ID @UI.Hidden;
  templateCode @title: 'Template Code';
  templateName @title: 'Template Name';
  wellType @title: 'Well Type';
}

// ============================================
// REFERENCE DATA (Read-Only)
// ============================================
annotate MasterDataService.Countries with @(
  UI.LineItem: [
    { Value: countryCode, Label: 'Code (3)' },
    { Value: countryCode2, Label: 'Code (2)' },
    { Value: countryName, Label: 'Country Name' },
    { Value: region, Label: 'Region' }
  ]
);

annotate MasterDataService.Currencies with @(
  UI.LineItem: [
    { Value: currencyCode, Label: 'Currency Code' },
    { Value: currencyName, Label: 'Currency Name' },
    { Value: decimalPlaces, Label: 'Decimal Places' }
  ]
);

annotate MasterDataService.UnitsOfMeasure with @(
  UI.LineItem: [
    { Value: uomCode, Label: 'UOM Code' },
    { Value: uomName, Label: 'UOM Name' },
    { Value: uomType, Label: 'Type' },
    { Value: s4UoM, Label: 'S/4 UOM' }
  ]
);

annotate MasterDataService.ExchangeRates with @(
  UI.LineItem: [
    { Value: rateDate, Label: 'Rate Date' },
    { Value: exchangeRate, Label: 'Exchange Rate' },
    { Value: rateType, Label: 'Rate Type' }
  ]
);
