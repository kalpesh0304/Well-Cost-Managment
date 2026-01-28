// Financial Entities for Well Cost Management
namespace wcm.financial;

using { wcm.common as common } from './common';
using { wcm.master as master } from './master-data';
using { wcm.afe as afe } from './afe';
using { cuid, managed } from '@sap/cds/common';

// ============================================
// COST ACTUALS
// ============================================
entity CostActuals : cuid, managed, common.S4HANAMapping {
  key ID               : UUID;
  afe                  : Association to afe.AFEs not null;
  wbsElement           : Association to afe.WBSElements;
  costElement          : Association to master.CostElements;
  vendor               : Association to master.Vendors;
  postingDate          : Date not null;
  documentDate         : Date;
  quantity             : common.Quantity;
  uom                  : Association to master.UnitsOfMeasure;
  actualAmount         : common.Amount not null;
  currency             : Association to master.Currencies;
  s4DocumentNo         : String(10);
  s4PONumber           : String(10);
  referenceText        : String(100);
  costType             : common.CostType not null default 'Actual';
}

// ============================================
// COMMITMENTS (PO-based)
// ============================================
entity Commitments : cuid, managed, common.S4HANAMapping {
  key ID               : UUID;
  afe                  : Association to afe.AFEs not null;
  wbsElement           : Association to afe.WBSElements;
  costElement          : Association to master.CostElements;
  vendor               : Association to master.Vendors;
  s4PONumber           : String(10) not null;
  s4POItem             : String(5) not null;
  commitmentDate       : Date not null;
  commitmentAmount     : common.Amount not null;
  consumedAmount       : common.Amount default 0;
  remainingAmount      : common.Amount;  // Calculated
  currency             : Association to master.Currencies;
  status               : String(20) not null default 'Open'; // Open, PartiallyConsumed, Closed
}

// ============================================
// PARTNER INTERESTS (JV)
// ============================================
entity PartnerInterests : cuid, managed {
  key ID               : UUID;
  well                 : Association to master.Wells not null;
  afe                  : Association to afe.AFEs;
  partner              : Association to master.Partners not null;
  workingInterest      : common.Percentage not null; // Sum per well = 1.0000
  netRevenueInterest   : common.Percentage;
  effectiveFromDate    : Date not null;
  effectiveToDate      : Date;
  consentStatus        : common.ConsentStatus default 'Pending';
  consentDate          : Timestamp;
  isOperator           : Boolean default false;
}

// ============================================
// JIB STATEMENTS
// ============================================
entity JIBStatements : cuid, managed {
  key ID               : UUID;
  statementNumber      : String(20) not null @mandatory;
  well                 : Association to master.Wells not null;
  afe                  : Association to afe.AFEs;
  partner              : Association to master.Partners not null;
  billingPeriodFrom    : Date not null;
  billingPeriodTo      : Date not null;
  workingInterest      : common.Percentage not null;
  grossAmount          : common.Amount not null;
  partnerShare         : common.Amount not null;  // Calculated: grossAmount * workingInterest
  currency             : Association to master.Currencies;
  dueDate              : Date;
  status               : common.JIBStatus not null default 'Draft';
  sentDate             : Timestamp;
  paidDate             : Date;

  // Line items
  lineItems            : Composition of many JIBLineItems on lineItems.statement = $self;
}

entity JIBLineItems : cuid {
  statement            : Association to JIBStatements not null;
  costElement          : Association to master.CostElements;
  description          : String(200);
  grossAmount          : common.Amount not null;
  partnerShare         : common.Amount not null;
}

// ============================================
// VARIANCE TRACKING
// ============================================
entity Variances : cuid, managed {
  key ID               : UUID;
  afe                  : Association to afe.AFEs not null;
  well                 : Association to master.Wells;
  wbsElement           : Association to afe.WBSElements;
  costElement          : Association to master.CostElements;
  analysisDate         : Date not null;
  estimatedAmount      : common.Amount not null;
  actualAmount         : common.Amount not null;
  varianceAmount       : common.Amount not null;  // Calculated: actual - estimated
  variancePct          : common.Percentage;       // Calculated
  varianceCategory     : Association to VarianceCategories;
  explanation          : String(500);
  approvalRequired     : Boolean default false;   // True if variance > 10%
  approvedBy           : String(100);
  approvedAt           : Timestamp;
}

entity VarianceCategories : common.MasterData {
  key ID               : UUID;
  categoryCode         : String(20) not null @mandatory;
  categoryName         : String(100) not null;
  categoryType         : String(20); // Favorable, Unfavorable
  description          : String(500);
}

// ============================================
// COST ALLOCATION
// ============================================
entity CostAllocations : cuid, managed {
  key ID               : UUID;
  afe                  : Association to afe.AFEs not null;
  costActual           : Association to CostActuals;
  partner              : Association to master.Partners not null;
  allocationDate       : Date not null;
  grossAmount          : common.Amount not null;
  workingInterest      : common.Percentage not null;
  allocatedAmount      : common.Amount not null;  // Calculated
  currency             : Association to master.Currencies;
}
