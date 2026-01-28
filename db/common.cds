// Common Types and Aspects for Well Cost Management
namespace wcm.common;

using { cuid, managed, temporal, Country, Currency } from '@sap/cds/common';

// Common Types
type Amount      : Decimal(15, 2);
type Percentage  : Decimal(8, 4);
type Quantity    : Decimal(15, 4);
type Rate        : Decimal(15, 4);
type Depth       : Decimal(10, 2);
type Coordinate  : Decimal(10, 6);

// Status Enums
type WellStatus       : String(20) enum { Planned; Drilling; Completed; Suspended; PandA; };
type WellType         : String(20) enum { Exploration; Development; Workover; Sidetrack; };
type WellboreType     : String(20) enum { Vertical; Horizontal; Directional; };
type AFEType          : String(20) enum { Original; Supplement; Revision; };
type ApprovalStatus   : String(20) enum { Draft; Pending; Approved; Rejected; };
type AFEStatus        : String(20) enum { Active; Closed; Cancelled; };
type CostType         : String(20) enum { Actual; Commitment; Accrual; };
type ConsentStatus    : String(20) enum { Consent; NonConsent; Pending; };
type JIBStatus        : String(20) enum { Draft; Sent; Paid; Disputed; };
type AnalysisStatus   : String(20) enum { Draft; Pending; Approved; };
type Recommendation   : String(20) enum { Recommend; Marginal; DoNotRecommend; };
type IntegrationStatus: String(20) enum { Success; Failed; PartialSuccess; };
type Severity         : String(20) enum { Error; Warning; Info; };

// Reusable Aspects
aspect MasterData : cuid, managed {
  isActive : Boolean default true;
}

aspect S4HANAMapping {
  s4SyncStatus   : String(20);
  s4LastSyncAt   : Timestamp;
  s4ErrorMessage : String(500);
}
