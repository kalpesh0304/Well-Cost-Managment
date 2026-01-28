// Master Data Service
using { wcm.master as master } from '../db/master-data';

@path: '/api/master'
@requires: 'authenticated-user'
service MasterDataService {

  // ============================================
  // FIELDS
  // ============================================
  @odata.draft.enabled
  @requires: ['WellRead', 'Admin']
  entity Fields as projection on master.Fields {
    *,
    wells : redirected to Wells
  } actions {
    @requires: 'WellWrite'
    action activate() returns Fields;
    @requires: 'WellWrite'
    action deactivate() returns Fields;
  };

  // ============================================
  // WELLS
  // ============================================
  @odata.draft.enabled
  @requires: ['WellRead', 'Admin']
  entity Wells as projection on master.Wells {
    *,
    field : redirected to Fields
  } actions {
    @requires: 'WellWrite'
    action updateStatus(newStatus: String) returns Wells;
    @requires: 'WellWrite'
    action syncToS4HANA() returns Wells;
  };

  // ============================================
  // COST CATEGORIES
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity CostCategories as projection on master.CostCategories {
    *,
    parent : redirected to CostCategories,
    children : redirected to CostCategories
  };

  // ============================================
  // COST ELEMENTS
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity CostElements as projection on master.CostElements {
    *,
    category : redirected to CostCategories,
    uom : redirected to UnitsOfMeasure
  } actions {
    @requires: 'Admin'
    action syncFromS4HANA() returns CostElements;
  };

  // ============================================
  // WBS TEMPLATES
  // ============================================
  @odata.draft.enabled
  @requires: ['AFERead', 'Admin']
  entity WBSTemplates as projection on master.WBSTemplates;

  @requires: ['AFERead', 'Admin']
  entity WBSTemplateElements as projection on master.WBSTemplateElements;

  // ============================================
  // VENDORS
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity Vendors as projection on master.Vendors {
    *,
    country : redirected to Countries,
    currency : redirected to Currencies
  } actions {
    @requires: 'Admin'
    action syncFromS4HANA() returns Vendors;
  };

  // ============================================
  // PARTNERS
  // ============================================
  @odata.draft.enabled
  @requires: ['PartnerRead', 'Admin']
  entity Partners as projection on master.Partners {
    *,
    country : redirected to Countries
  };

  // ============================================
  // REFERENCE DATA (Read-Only)
  // ============================================
  @readonly
  entity Countries as projection on master.Countries;

  @readonly
  entity Currencies as projection on master.Currencies;

  @readonly
  entity UnitsOfMeasure as projection on master.UnitsOfMeasure;

  @readonly
  entity ExchangeRates as projection on master.ExchangeRates;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getActiveWellsByField(fieldId: UUID) returns array of Wells;
  function getWellsByStatus(status: String) returns array of Wells;
  function getCostElementHierarchy() returns array of CostCategories;
  function getExchangeRate(fromCurrency: String, toCurrency: String, rateDate: Date) returns Decimal;
}
