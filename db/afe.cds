// AFE (Authorization for Expenditure) Entities
namespace wcm.afe;

using { wcm.common as common } from './common';
using { wcm.master as master } from './master-data';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// AFE HEADER
// ============================================
entity AFEs : cuid, managed, common.S4HANAMapping {
  key ID               : UUID;
  afeNumber            : String(20) not null @mandatory;
  afeName              : String(100) not null;
  afeType              : common.AFEType not null default 'Original';
  well                 : Association to master.Wells not null;
  estimatedCost        : common.Amount not null;
  currency             : Association to master.Currencies;
  contingencyAmount    : common.Amount;
  contingencyPct       : common.Percentage @assert.range: [0, 0.50];
  validFromDate        : Date not null;
  validToDate          : Date not null;
  parentAFE            : Association to AFEs;
  versionNumber        : Integer default 1;
  approvalStatus       : common.ApprovalStatus not null default 'Draft';
  approvedDate         : Timestamp;
  approvedBy           : String(100);
  s4ProjectNo          : String(24);
  s4WBSElement         : String(24);
  status               : common.AFEStatus not null default 'Active';

  // Compositions
  lineItems            : Composition of many AFELineItems on lineItems.afe = $self;
  wbsElements          : Composition of many WBSElements on wbsElements.afe = $self;
  approvals            : Composition of many Approvals on approvals.afe = $self;
  documents            : Composition of many AFEDocuments on documents.afe = $self;

  // Associations
  costEstimates        : Association to many CostEstimates on costEstimates.afe = $self;
  supplements          : Association to many AFEs on supplements.parentAFE = $self;
}

// ============================================
// AFE LINE ITEMS
// ============================================
entity AFELineItems : cuid {
  afe                  : Association to AFEs not null;
  wbsElement           : Association to WBSElements;
  costElement          : Association to master.CostElements;
  vendor               : Association to master.Vendors;
  lineNumber           : Integer not null;
  description          : String(200) not null;
  quantity             : common.Quantity not null @assert.range: [0,];
  uom                  : Association to master.UnitsOfMeasure;
  unitRate             : common.Rate not null;
  estimatedAmount      : common.Amount not null;  // Calculated: quantity * unitRate
  currency             : Association to master.Currencies;
  startDate            : Date;
  endDate              : Date;
  durationDays         : Decimal(10, 2);
  sourceType           : String(20); // Manual, Benchmark, Contract
}

// ============================================
// WBS ELEMENTS (Instance per AFE)
// ============================================
entity WBSElements : cuid {
  afe                  : Association to AFEs not null;
  elementCode          : String(24) not null;
  elementName          : String(100) not null;
  parent               : Association to WBSElements;
  children             : Association to many WBSElements on children.parent = $self;
  hierarchyLevel       : Integer not null;
  sortOrder            : Integer;
  s4WBSElement         : String(24);
  isActive             : Boolean default true;
}

// ============================================
// COST ESTIMATES
// ============================================
entity CostEstimates : cuid, managed {
  afe                  : Association to AFEs not null;
  wbsElement           : Association to WBSElements;
  costElement          : Association to master.CostElements;
  vendor               : Association to master.Vendors;
  description          : String(200);
  quantity             : common.Quantity not null @assert.range: [0,];
  uom                  : Association to master.UnitsOfMeasure;
  unitRate             : common.Rate not null;
  estimatedAmount      : common.Amount not null;
  currency             : Association to master.Currencies;
  startDate            : Date;
  endDate              : Date;
  durationDays         : Decimal(10, 2);
  sourceType           : String(20);
  confidenceLevel      : String(20); // Low, Medium, High
}

// ============================================
// APPROVALS
// ============================================
entity Approvals : cuid, managed {
  afe                  : Association to AFEs not null;
  approvalLevel        : Integer not null;
  approverRole         : String(50) not null;
  approverUserId       : String(100) not null;
  approverName         : String(100);
  delegatedFrom        : String(100);
  assignedDate         : Timestamp not null;
  dueDate              : Timestamp;
  actionDate           : Timestamp;
  actionStatus         : String(20) not null default 'Pending'; // Approved, Rejected, Returned, Pending
  comments             : String(1000);
  conditions           : String(500);
}

// ============================================
// AFE DOCUMENTS
// ============================================
entity AFEDocuments : cuid, managed {
  afe                  : Association to AFEs not null;
  documentName         : String(200) not null;
  documentType         : String(50);
  documentCategory     : String(50); // Estimate, Approval, Supporting
  fileSize             : Integer;
  mimeType             : String(100);
  storageUrl           : String(500);
  uploadedBy           : String(100);
  uploadedAt           : Timestamp;
}
