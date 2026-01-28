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
    country_ID,
    region,
    isActive
  ],

  UI.LineItem: [
    { Value: fieldCode, Label: 'Field Code', ![@UI.Importance]: #High },
    { Value: fieldName, Label: 'Field Name', ![@UI.Importance]: #High },
    { Value: basin, Label: 'Basin' },
    { Value: country.countryName, Label: 'Country', ![@UI.Importance]: #High },
    { Value: region, Label: 'Region' },
    { Value: operatorName, Label: 'Operator' },
    { Value: isActive, Label: 'Active', ![@UI.Importance]: #High }
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
      ID: 'S4InfoFacet',
      Label: 'SAP S/4HANA',
      Target: '@UI.FieldGroup#S4Info'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'WellsFacet',
      Label: 'Wells',
      Target: 'wells/@UI.LineItem'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: fieldCode, Label: 'Field Code' },
      { Value: fieldName, Label: 'Field Name' },
      { Value: basin, Label: 'Basin' },
      { Value: country_ID, Label: 'Country' },
      { Value: region, Label: 'Region' },
      { Value: operatorName, Label: 'Operator' },
      { Value: isActive, Label: 'Active' }
    ]
  },

  UI.FieldGroup#S4Info: {
    Label: 'SAP S/4HANA Integration',
    Data: [
      { Value: s4ProfitCenter, Label: 'Profit Center' },
      { Value: s4CostCenter, Label: 'Cost Center' }
    ]
  }
);

annotate MasterDataService.Fields with {
  ID @UI.Hidden;
  fieldCode @title: 'Field Code' @Common.FieldControl: #Mandatory;
  fieldName @title: 'Field Name' @Common.FieldControl: #Mandatory;
  basin @title: 'Basin';
  region @title: 'Region';
  operatorName @title: 'Operator Name';
  country @title: 'Country' @Common.ValueList: {
    CollectionPath: 'Countries',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: country_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'countryName' }
    ]
  };
  isActive @title: 'Active';
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
    { Value: wellNumber, Label: 'Well Number', ![@UI.Importance]: #High },
    { Value: wellName, Label: 'Well Name', ![@UI.Importance]: #High },
    { Value: field.fieldName, Label: 'Field', ![@UI.Importance]: #High },
    { Value: wellType, Label: 'Type' },
    { Value: wellboreType, Label: 'Wellbore Type' },
    { Value: status, Label: 'Status', ![@UI.Importance]: #High, Criticality: statusCriticality },
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
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'LocationInfoFacet',
      Label: 'Location',
      Target: '@UI.FieldGroup#LocationInfo'
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
      { Value: totalDepthTVD, Label: 'Total Depth (TVD)' }
    ]
  },

  UI.FieldGroup#LocationInfo: {
    Label: 'Location',
    Data: [
      { Value: surfaceLatitude, Label: 'Surface Latitude' },
      { Value: surfaceLongitude, Label: 'Surface Longitude' }
    ]
  },

  UI.FieldGroup#S4Info: {
    Label: 'SAP S/4HANA Integration',
    Data: [
      { Value: s4WBSElement, Label: 'WBS Element' },
      { Value: s4hanaSyncStatus, Label: 'Sync Status' },
      { Value: s4hanaLastSyncAt, Label: 'Last Sync' }
    ]
  }
);

annotate MasterDataService.Wells with {
  ID @UI.Hidden;
  statusCriticality @Core.Computed;
  wellNumber @title: 'Well Number' @Common.FieldControl: #Mandatory;
  wellName @title: 'Well Name' @Common.FieldControl: #Mandatory;
  wellType @title: 'Well Type' @Common.FieldControl: #Mandatory;
  wellboreType @title: 'Wellbore Type';
  status @title: 'Status';
  spudDate @title: 'Spud Date';
  field @title: 'Field' @Common.FieldControl: #Mandatory @Common.ValueList: {
    CollectionPath: 'Fields',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: field_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'fieldName' }
    ]
  };
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
    parent_ID,
    isActive
  ],

  UI.LineItem: [
    { Value: categoryCode, Label: 'Code', ![@UI.Importance]: #High },
    { Value: categoryName, Label: 'Name', ![@UI.Importance]: #High },
    { Value: categoryType, Label: 'Type', ![@UI.Importance]: #High },
    { Value: hierarchyLevel, Label: 'Level' },
    { Value: parent.categoryName, Label: 'Parent' },
    { Value: accountingTreatment, Label: 'Accounting' },
    { Value: s4CostElement, Label: 'S/4 Cost Element' },
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
      ID: 'ChildrenFacet',
      Label: 'Child Categories',
      Target: 'children/@UI.LineItem'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: categoryCode, Label: 'Category Code' },
      { Value: categoryName, Label: 'Category Name' },
      { Value: categoryType, Label: 'Category Type' },
      { Value: parent_ID, Label: 'Parent Category' },
      { Value: hierarchyLevel, Label: 'Hierarchy Level' },
      { Value: accountingTreatment, Label: 'Accounting Treatment' },
      { Value: s4CostElement, Label: 'S/4 Cost Element' },
      { Value: isActive, Label: 'Active' }
    ]
  }
);

annotate MasterDataService.CostCategories with {
  ID @UI.Hidden;
  categoryCode @title: 'Category Code' @Common.FieldControl: #Mandatory;
  categoryName @title: 'Category Name' @Common.FieldControl: #Mandatory;
  categoryType @title: 'Category Type' @Common.FieldControl: #Mandatory;
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
    { Value: elementCode, Label: 'Element Code', ![@UI.Importance]: #High },
    { Value: elementName, Label: 'Element Name', ![@UI.Importance]: #High },
    { Value: category.categoryName, Label: 'Category', ![@UI.Importance]: #High },
    { Value: uom.uomCode, Label: 'UOM' },
    { Value: s4GLAccount, Label: 'GL Account' },
    { Value: s4CostElement, Label: 'S/4 Cost Element' },
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
      { Value: elementCode, Label: 'Element Code' },
      { Value: elementName, Label: 'Element Name' },
      { Value: category_ID, Label: 'Category' },
      { Value: uom_ID, Label: 'Unit of Measure' },
      { Value: s4GLAccount, Label: 'S/4 GL Account' },
      { Value: s4CostElement, Label: 'S/4 Cost Element' },
      { Value: taxCode, Label: 'Tax Code' },
      { Value: isActive, Label: 'Active' }
    ]
  }
);

annotate MasterDataService.CostElements with {
  ID @UI.Hidden;
  elementCode @title: 'Element Code' @Common.FieldControl: #Mandatory;
  elementName @title: 'Element Name' @Common.FieldControl: #Mandatory;
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
    country_ID,
    isActive
  ],

  UI.LineItem: [
    { Value: vendorCode, Label: 'Vendor Code', ![@UI.Importance]: #High },
    { Value: vendorName, Label: 'Vendor Name', ![@UI.Importance]: #High },
    { Value: vendorType, Label: 'Type' },
    { Value: country.countryName, Label: 'Country' },
    { Value: currency.currencyCode, Label: 'Currency' },
    { Value: s4VendorNo, Label: 'S/4 Vendor #' },
    { Value: contactName, Label: 'Contact' },
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
      ID: 'ContactInfoFacet',
      Label: 'Contact Information',
      Target: '@UI.FieldGroup#ContactInfo'
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
      { Value: vendorCode, Label: 'Vendor Code' },
      { Value: vendorName, Label: 'Vendor Name' },
      { Value: vendorType, Label: 'Vendor Type' },
      { Value: country_ID, Label: 'Country' },
      { Value: currency_code, Label: 'Currency' },
      { Value: paymentTerms, Label: 'Payment Terms' },
      { Value: taxId, Label: 'Tax ID' },
      { Value: isActive, Label: 'Active' }
    ]
  },

  UI.FieldGroup#ContactInfo: {
    Label: 'Contact Information',
    Data: [
      { Value: contactName, Label: 'Contact Name' },
      { Value: contactEmail, Label: 'Contact Email' },
      { Value: contactPhone, Label: 'Contact Phone' }
    ]
  },

  UI.FieldGroup#S4Info: {
    Label: 'SAP S/4HANA Integration',
    Data: [
      { Value: s4VendorNo, Label: 'S/4 Vendor Number' },
      { Value: s4BusinessPartner, Label: 'S/4 Business Partner' },
      { Value: s4hanaSyncStatus, Label: 'Sync Status' },
      { Value: s4hanaLastSyncAt, Label: 'Last Sync' }
    ]
  }
);

annotate MasterDataService.Vendors with {
  ID @UI.Hidden;
  vendorCode @title: 'Vendor Code' @Common.FieldControl: #Mandatory;
  vendorName @title: 'Vendor Name' @Common.FieldControl: #Mandatory;
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
    country_ID,
    isActive
  ],

  UI.LineItem: [
    { Value: partnerCode, Label: 'Partner Code', ![@UI.Importance]: #High },
    { Value: partnerName, Label: 'Partner Name', ![@UI.Importance]: #High },
    { Value: partnerType, Label: 'Type', ![@UI.Importance]: #High },
    { Value: country.countryName, Label: 'Country' },
    { Value: workingInterestDefault, Label: 'Default WI %' },
    { Value: contactName, Label: 'Contact' },
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
      ID: 'ContactInfoFacet',
      Label: 'Contact Information',
      Target: '@UI.FieldGroup#ContactInfo'
    }
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'General Information',
    Data: [
      { Value: partnerCode, Label: 'Partner Code' },
      { Value: partnerName, Label: 'Partner Name' },
      { Value: partnerType, Label: 'Partner Type' },
      { Value: country_ID, Label: 'Country' },
      { Value: workingInterestDefault, Label: 'Default Working Interest %' },
      { Value: s4BusinessPartner, Label: 'S/4 Business Partner' },
      { Value: isActive, Label: 'Active' }
    ]
  },

  UI.FieldGroup#ContactInfo: {
    Label: 'Contact Information',
    Data: [
      { Value: contactName, Label: 'Contact Name' },
      { Value: contactEmail, Label: 'Contact Email' },
      { Value: billingAddress, Label: 'Billing Address' }
    ]
  }
);

annotate MasterDataService.Partners with {
  ID @UI.Hidden;
  partnerCode @title: 'Partner Code' @Common.FieldControl: #Mandatory;
  partnerName @title: 'Partner Name' @Common.FieldControl: #Mandatory;
  partnerType @title: 'Partner Type' @Common.FieldControl: #Mandatory;
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
    { Value: templateCode, Label: 'Template Code', ![@UI.Importance]: #High },
    { Value: templateName, Label: 'Template Name', ![@UI.Importance]: #High },
    { Value: wellType, Label: 'Well Type', ![@UI.Importance]: #High },
    { Value: wellboreType, Label: 'Wellbore Type' },
    { Value: region, Label: 'Region' },
    { Value: hierarchyLevels, Label: 'Levels' },
    { Value: versionNumber, Label: 'Version' },
    { Value: isActive, Label: 'Active' }
  ]
);

annotate MasterDataService.WBSTemplates with {
  ID @UI.Hidden;
  templateCode @title: 'Template Code' @Common.FieldControl: #Mandatory;
  templateName @title: 'Template Name' @Common.FieldControl: #Mandatory;
  wellType @title: 'Well Type' @Common.FieldControl: #Mandatory;
}

// ============================================
// REFERENCE DATA (Read-Only)
// ============================================
annotate MasterDataService.Countries with @(
  UI.HeaderInfo: {
    TypeName: 'Country',
    TypeNamePlural: 'Countries',
    Title: { Value: countryCode },
    Description: { Value: countryName }
  },

  UI.LineItem: [
    { Value: countryCode, Label: 'Code (3)' },
    { Value: countryCode2, Label: 'Code (2)' },
    { Value: countryName, Label: 'Country Name' },
    { Value: region, Label: 'Region' }
  ]
);

annotate MasterDataService.Currencies with @(
  UI.HeaderInfo: {
    TypeName: 'Currency',
    TypeNamePlural: 'Currencies',
    Title: { Value: currencyCode },
    Description: { Value: currencyName }
  },

  UI.LineItem: [
    { Value: currencyCode, Label: 'Currency Code' },
    { Value: currencyName, Label: 'Currency Name' },
    { Value: decimalPlaces, Label: 'Decimal Places' }
  ]
);

annotate MasterDataService.UnitsOfMeasure with @(
  UI.HeaderInfo: {
    TypeName: 'Unit of Measure',
    TypeNamePlural: 'Units of Measure',
    Title: { Value: uomCode },
    Description: { Value: uomName }
  },

  UI.LineItem: [
    { Value: uomCode, Label: 'UOM Code' },
    { Value: uomName, Label: 'UOM Name' },
    { Value: uomType, Label: 'Type' },
    { Value: s4UoM, Label: 'S/4 UOM' }
  ]
);

annotate MasterDataService.ExchangeRates with @(
  UI.HeaderInfo: {
    TypeName: 'Exchange Rate',
    TypeNamePlural: 'Exchange Rates',
    Title: { Value: rateDate }
  },

  UI.LineItem: [
    { Value: fromCurrency.currencyCode, Label: 'From Currency' },
    { Value: toCurrency.currencyCode, Label: 'To Currency' },
    { Value: rateDate, Label: 'Rate Date' },
    { Value: exchangeRate, Label: 'Exchange Rate' },
    { Value: rateType, Label: 'Rate Type' }
  ]
);
