// AFE (Authorization for Expenditure) Service
using { wcm.afe as afe } from '../db/afe';
using { wcm.master as master } from '../db/master-data';

@path: '/api/afe'
@requires: 'authenticated-user'
service AFEService {

  // ============================================
  // AFE MANAGEMENT
  // ============================================
  @odata.draft.enabled
  @requires: ['AFERead', 'Admin']
  entity AFEs as projection on afe.AFEs {
    *,
    well : redirected to Wells,
    currency : redirected to Currencies,
    parentAFE : redirected to AFEs,
    supplements : redirected to AFEs,
    lineItems : redirected to AFELineItems,
    wbsElements : redirected to WBSElements,
    approvals : redirected to Approvals,
    documents : redirected to AFEDocuments,
    costEstimates : redirected to CostEstimates
  } actions {
    // Lifecycle Actions
    @requires: 'AFEWrite'
    action submitForApproval() returns AFEs;

    @requires: 'AFEApprove'
    action approve(comments: String, conditions: String) returns AFEs;

    @requires: 'AFEApprove'
    action reject(comments: String) returns AFEs;

    @requires: 'AFEApprove'
    action returnForRevision(comments: String) returns AFEs;

    @requires: 'AFEWrite'
    action activate() returns AFEs;

    @requires: 'AFEWrite'
    action close() returns AFEs;

    @requires: 'Admin'
    action cancel() returns AFEs;

    // Supplement Actions
    @requires: 'AFEWrite'
    action createSupplement(estimatedCost: Decimal, justification: String) returns AFEs;

    // S/4HANA Integration
    @requires: 'AFEWrite'
    action createS4Project() returns AFEs;

    @requires: 'AFEWrite'
    action reserveBudget() returns AFEs;

    // Utilities
    @requires: 'AFEWrite'
    action copyFromTemplate(templateId: UUID) returns AFEs;

    @requires: 'AFERead'
    action generateReport(format: String) returns LargeBinary;
  };

  // ============================================
  // AFE LINE ITEMS
  // ============================================
  @requires: ['AFERead', 'Admin']
  entity AFELineItems as projection on afe.AFELineItems {
    *,
    afe : redirected to AFEs,
    wbsElement : redirected to WBSElements,
    costElement : redirected to CostElements,
    vendor : redirected to Vendors,
    uom : redirected to UnitsOfMeasure,
    currency : redirected to Currencies
  };

  // ============================================
  // WBS ELEMENTS
  // ============================================
  @requires: ['AFERead', 'Admin']
  entity WBSElements as projection on afe.WBSElements {
    *,
    afe : redirected to AFEs,
    parent : redirected to WBSElements,
    children : redirected to WBSElements
  };

  // ============================================
  // COST ESTIMATES
  // ============================================
  @odata.draft.enabled
  @requires: ['AFERead', 'Admin']
  entity CostEstimates as projection on afe.CostEstimates {
    *,
    afe : redirected to AFEs,
    wbsElement : redirected to WBSElements,
    costElement : redirected to CostElements,
    vendor : redirected to Vendors,
    uom : redirected to UnitsOfMeasure,
    currency : redirected to Currencies
  } actions {
    @requires: 'AFEWrite'
    action copyToBenchmark() returns CostEstimates;
  };

  // ============================================
  // APPROVALS
  // ============================================
  @requires: ['AFERead', 'Admin']
  entity Approvals as projection on afe.Approvals {
    *,
    afe : redirected to AFEs
  } actions {
    @requires: 'AFEApprove'
    action delegate(toUserId: String, toUserName: String) returns Approvals;

    @requires: 'AFEApprove'
    action escalate() returns Approvals;
  };

  // ============================================
  // AFE DOCUMENTS
  // ============================================
  @requires: ['AFERead', 'Admin']
  entity AFEDocuments as projection on afe.AFEDocuments {
    *,
    afe : redirected to AFEs
  };

  // ============================================
  // REFERENCE ENTITIES (from Master Data)
  // ============================================
  @readonly
  entity Wells as projection on master.Wells;

  @readonly
  entity CostElements as projection on master.CostElements;

  @readonly
  entity Vendors as projection on master.Vendors;

  @readonly
  entity Currencies as projection on master.Currencies;

  @readonly
  entity UnitsOfMeasure as projection on master.UnitsOfMeasure;

  // ============================================
  // FUNCTIONS
  // ============================================
  function getAFEsByWell(wellId: UUID) returns array of AFEs;
  function getAFEsByStatus(status: String) returns array of AFEs;
  function getPendingApprovals(userId: String) returns array of Approvals;
  function getMyPendingApprovals() returns array of Approvals;
  function getAFESummary(afeId: UUID) returns {
    estimatedTotal: Decimal;
    actualTotal: Decimal;
    committedTotal: Decimal;
    varianceAmount: Decimal;
    variancePct: Decimal;
  };
  function validateAFE(afeId: UUID) returns array of {
    ruleCode: String;
    severity: String;
    message: String;
  };
}
