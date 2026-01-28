// Financial Service (Cost Actuals, JIB, Partners)
using { wcm.financial as fin } from '../db/financial';
using { wcm.afe as afe } from '../db/afe';
using { wcm.master as master } from '../db/master-data';

@path: '/api/financial'
@requires: 'authenticated-user'
service FinancialService {

  // ============================================
  // COST ACTUALS
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity CostActuals as projection on fin.CostActuals {
    *,
    afe : redirected to AFEs,
    wbsElement : redirected to WBSElements,
    costElement : redirected to CostElements,
    vendor : redirected to Vendors,
    uom : redirected to UnitsOfMeasure,
    currency : redirected to Currencies
  } actions {
    @requires: 'CostWrite'
    action reversePosting(reason: String) returns CostActuals;

    @requires: 'CostWrite'
    action reallocate(newAfeId: UUID, newWbsElementId: UUID) returns CostActuals;
  };

  // ============================================
  // COMMITMENTS
  // ============================================
  @requires: ['CostRead', 'Admin']
  entity Commitments as projection on fin.Commitments {
    *,
    afe : redirected to AFEs,
    wbsElement : redirected to WBSElements,
    costElement : redirected to CostElements,
    vendor : redirected to Vendors,
    currency : redirected to Currencies
  } actions {
    @requires: 'CostWrite'
    action refreshFromS4HANA() returns Commitments;

    @requires: 'CostWrite'
    action closeCommitment() returns Commitments;
  };

  // ============================================
  // PARTNER INTERESTS
  // ============================================
  @odata.draft.enabled
  @requires: ['PartnerRead', 'Admin']
  entity PartnerInterests as projection on fin.PartnerInterests {
    *,
    well : redirected to Wells,
    afe : redirected to AFEs,
    partner : redirected to Partners
  } actions {
    @requires: 'PartnerWrite'
    action grantConsent() returns PartnerInterests;

    @requires: 'PartnerWrite'
    action markNonConsent(reason: String) returns PartnerInterests;
  };

  // ============================================
  // JIB STATEMENTS
  // ============================================
  @odata.draft.enabled
  @requires: ['JIBRead', 'Admin']
  entity JIBStatements as projection on fin.JIBStatements {
    *,
    well : redirected to Wells,
    afe : redirected to AFEs,
    partner : redirected to Partners,
    currency : redirected to Currencies,
    lineItems : redirected to JIBLineItems
  } actions {
    @requires: 'JIBWrite'
    action calculate() returns JIBStatements;

    @requires: 'JIBWrite'
    action sendToPartner() returns JIBStatements;

    @requires: 'JIBWrite'
    action markPaid(paidDate: Date, paymentReference: String) returns JIBStatements;

    @requires: 'JIBWrite'
    action markDisputed(reason: String) returns JIBStatements;

    @requires: 'JIBWrite'
    action postToS4HANA() returns JIBStatements;

    @requires: 'JIBRead'
    action generatePDF() returns LargeBinary;
  };

  @requires: ['JIBRead', 'Admin']
  entity JIBLineItems as projection on fin.JIBLineItems {
    *,
    statement : redirected to JIBStatements,
    costElement : redirected to CostElements
  };

  // ============================================
  // VARIANCES
  // ============================================
  @odata.draft.enabled
  @requires: ['CostRead', 'Admin']
  entity Variances as projection on fin.Variances {
    *,
    afe : redirected to AFEs,
    well : redirected to Wells,
    wbsElement : redirected to WBSElements,
    costElement : redirected to CostElements,
    varianceCategory : redirected to VarianceCategories
  } actions {
    @requires: 'CostWrite'
    action approve(comments: String) returns Variances;

    @requires: 'CostWrite'
    action requestExplanation(userId: String) returns Variances;
  };

  @readonly
  entity VarianceCategories as projection on fin.VarianceCategories;

  // ============================================
  // COST ALLOCATIONS
  // ============================================
  @readonly
  entity CostAllocations as projection on fin.CostAllocations {
    *,
    afe : redirected to AFEs,
    costActual : redirected to CostActuals,
    partner : redirected to Partners,
    currency : redirected to Currencies
  };

  // ============================================
  // REFERENCE ENTITIES
  // ============================================
  @readonly
  entity AFEs as projection on afe.AFEs;

  @readonly
  entity WBSElements as projection on afe.WBSElements;

  @readonly
  entity Wells as projection on master.Wells;

  @readonly
  entity CostElements as projection on master.CostElements;

  @readonly
  entity Vendors as projection on master.Vendors;

  @readonly
  entity Partners as projection on master.Partners;

  @readonly
  entity Currencies as projection on master.Currencies;

  @readonly
  entity UnitsOfMeasure as projection on master.UnitsOfMeasure;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getCostActualsByAFE(afeId: UUID) returns array of CostActuals;
  function getCommitmentsByAFE(afeId: UUID) returns array of Commitments;
  function getPartnerInterestsByWell(wellId: UUID) returns array of PartnerInterests;
  function validatePartnerInterests(wellId: UUID) returns {
    isValid: Boolean;
    totalWI: Decimal;
    message: String;
  };
  function getJIBStatementsByPartner(partnerId: UUID, year: Integer) returns array of JIBStatements;
  function getVarianceAnalysis(afeId: UUID) returns array of {
    costElementId: UUID;
    costElementName: String;
    estimated: Decimal;
    actual: Decimal;
    variance: Decimal;
    variancePct: Decimal;
    category: String;
  };

  // ============================================
  // ACTIONS
  // ============================================
  @requires: 'JIBWrite'
  action generateJIBStatements(wellId: UUID, periodFrom: Date, periodTo: Date) returns array of JIBStatements;

  @requires: 'CostWrite'
  action runVarianceAnalysis(afeId: UUID) returns array of Variances;

  @requires: 'CostWrite'
  action allocateCosts(afeId: UUID, postingDate: Date) returns array of CostAllocations;
}
