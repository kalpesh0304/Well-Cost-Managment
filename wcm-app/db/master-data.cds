// Master Data Entities for Well Cost Management
namespace wcm.master;

using { wcm.common as common } from './common';
using { Country, Currency, cuid, managed } from '@sap/cds/common';

// ============================================
// FIELD / ASSET MASTER
// ============================================
entity Fields : common.MasterData {
  key ID             : UUID;
  fieldCode          : String(20) not null @mandatory;
  fieldName          : String(100) not null;
  basin              : String(50);
  country            : Association to Countries;
  region             : String(50);  // APAC, EMEA, Americas
  operatorName       : String(100);
  s4ProfitCenter     : String(10);
  s4CostCenter       : String(10);

  // Associations
  wells              : Association to many Wells on wells.field = $self;
}

// ============================================
// WELL MASTER
// ============================================
entity Wells : common.MasterData, common.S4HANAMapping {
  key ID             : UUID;
  wellNumber         : String(20) not null @mandatory;
  wellName           : String(100) not null;
  wellType           : common.WellType not null;
  wellboreType       : common.WellboreType;
  field              : Association to Fields;
  spudDate           : Date;
  totalDepthMD       : common.Depth;
  totalDepthTVD      : common.Depth;
  surfaceLatitude    : common.Coordinate;
  surfaceLongitude   : common.Coordinate;
  s4WBSElement       : String(24);
  status             : common.WellStatus not null default 'Planned';

  // Associations
  afes               : Association to many wcm.afe.AFEs on afes.well = $self;
  partnerInterests   : Association to many wcm.financial.PartnerInterests on partnerInterests.well = $self;
  dailyReports       : Association to many wcm.operations.DailyReports on dailyReports.well = $self;
}

// ============================================
// COST CATEGORY (Hierarchical)
// ============================================
entity CostCategories : common.MasterData {
  key ID              : UUID;
  categoryCode        : String(10) not null @mandatory;
  categoryName        : String(100) not null;
  categoryType        : String(20) not null; // CAPEX, OPEX, Contingency
  parent              : Association to CostCategories;
  children            : Association to many CostCategories on children.parent = $self;
  s4CostElement       : String(10);
  accountingTreatment : String(20); // Capitalize, Expense
  hierarchyLevel      : Integer default 1;
}

// ============================================
// COST ELEMENT
// ============================================
entity CostElements : common.MasterData, common.S4HANAMapping {
  key ID            : UUID;
  elementCode       : String(20) not null @mandatory;
  elementName       : String(100) not null;
  category          : Association to CostCategories;
  uom               : Association to UnitsOfMeasure;
  s4GLAccount       : String(10);
  s4CostElement     : String(10);
  taxCode           : String(5);
}

// ============================================
// WBS TEMPLATE
// ============================================
entity WBSTemplates : common.MasterData {
  key ID             : UUID;
  templateCode       : String(20) not null @mandatory;
  templateName       : String(100) not null;
  wellType           : common.WellType not null;
  wellboreType       : common.WellboreType;
  region             : String(50);
  hierarchyLevels    : Integer default 5;
  versionNumber      : Integer default 1;
  effectiveFromDate  : Date;
  effectiveToDate    : Date;

  // Composition
  elements           : Composition of many WBSTemplateElements on elements.template = $self;
}

entity WBSTemplateElements : cuid {
  template           : Association to WBSTemplates;
  elementCode        : String(24) not null;
  elementName        : String(100) not null;
  parent             : Association to WBSTemplateElements;
  hierarchyLevel     : Integer not null;
  sortOrder          : Integer;
}

// ============================================
// VENDOR MASTER
// ============================================
entity Vendors : common.MasterData, common.S4HANAMapping {
  key ID             : UUID;
  vendorCode         : String(20) not null @mandatory;
  vendorName         : String(100) not null;
  vendorType         : String(20); // Drilling, Completion, Services, Equipment
  country            : Association to Countries;
  currency           : Association to Currencies;
  paymentTerms       : String(20);
  s4VendorNo         : String(10);
  s4BusinessPartner  : String(10);
  taxId              : String(20);
  contactName        : String(100);
  contactEmail       : String(100);
  contactPhone       : String(20);
}

// ============================================
// PARTNER MASTER (JV Partners)
// ============================================
entity Partners : common.MasterData {
  key ID                   : UUID;
  partnerCode              : String(20) not null @mandatory;
  partnerName              : String(100) not null;
  partnerType              : String(20) not null; // Operator, Non-Operator, Carried
  country                  : Association to Countries;
  workingInterestDefault   : common.Percentage;
  s4BusinessPartner        : String(10);
  billingAddress           : String(500);
  contactName              : String(100);
  contactEmail             : String(100);
}

// ============================================
// REFERENCE DATA
// ============================================
entity Countries : common.MasterData {
  key ID           : UUID;
  countryCode      : String(3) not null @mandatory;  // ISO 3166-1 alpha-3
  countryCode2     : String(2) not null;             // ISO 3166-1 alpha-2
  countryName      : String(100) not null;
  region           : String(50);
}

entity Currencies : common.MasterData {
  key ID           : UUID;
  currencyCode     : String(3) not null @mandatory;  // ISO 4217
  currencyName     : String(100) not null;
  decimalPlaces    : Integer default 2;
}

entity UnitsOfMeasure : common.MasterData {
  key ID         : UUID;
  uomCode        : String(10) not null @mandatory;
  uomName        : String(50) not null;
  uomType        : String(20); // Length, Time, Volume, Weight
  s4UoM          : String(3);
}

// ============================================
// EXCHANGE RATES
// ============================================
entity ExchangeRates : cuid, managed {
  fromCurrency   : Association to Currencies;
  toCurrency     : Association to Currencies;
  rateDate       : Date not null;
  exchangeRate   : common.Rate not null;
  rateType       : String(10) default 'SPOT';
}
