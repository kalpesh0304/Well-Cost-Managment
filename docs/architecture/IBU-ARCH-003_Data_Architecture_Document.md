---
title: "IBU-ARCH-003_Data_Architecture_Document"
category: "architecture"
type: "Architecture Document"
created_date: "2026-01-28"
source_file: "IBU-ARCH-003_Data_Architecture_Document.docx"
---



> **Document Type**: Architecture Document
>
> This document describes the system architecture, components, and design decisions.

---


**Well Cost Management**

Oil & Gas Drilling Cost Lifecycle Management Solution

**Data Architecture Document**

Foundation Document

*Supports: S/4HANA Public Cloud | S/4HANA RISE | S/4HANA On-Premise*



| Property | Value |
| --- | --- |
| Document ID | IBU-ARCH-003 |
| Version | 1.0 |
| Date | January 2025 |
| Prepared by | Data Pipeline Agent (@data-pipeline) |
| Platform | SAP Business Technology Platform |



*Prepared by Industry Business Unit*

# 1. Document Semantics

## 1.1 Document Properties



| Property | Value |
| --- | --- |
| Document ID | IBU-ARCH-003 |
| Document Title | Well Cost Management Data Architecture Document |
| Document Type | Foundation Document |
| Version | 1.0 |
| Status | Draft |
| Prepared By | Data Pipeline Agent (@data-pipeline) |
| Reviewed By | Solution Architect, CAP Developer, S/4HANA Integrator |
| Approved By | [Pending] |



## 1.2 Amendment History



| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 1.0 | Jan 2025 | Data Pipeline Agent | Initial release - Complete data model for all 13 modules with 65+ entities |



## 1.3 RACI Matrix



| Role | Responsibility |
| --- | --- |
| @data-pipeline | A - Accountable for Data Architecture |
| @cap-developer | R - Responsible for CDS Implementation |
| @master-data | C - Consulted for Master Data Design |
| @s4-integrator | C - Consulted for S/4HANA Mapping |
| @security-agent | C - Consulted for Data Security |
| @compliance-agent | C - Consulted for Data Retention |
| @performance-agent | I - Informed |
| @qa-agent | I - Informed |



# 2. Executive Summary

## 2.1 Purpose

This document defines the complete data model for the Well Cost Management solution, the Oil & Gas Drilling Cost Lifecycle Management system built on SAP Business Technology Platform (BTP). It serves as the foundational reference for all entity definitions, relationships, and data structures across all functional modules.

The data model is designed for implementation on SAP HANA Cloud using the SAP Cloud Application Programming Model (CAP) with Core Data Services (CDS). It includes comprehensive mappings to SAP S/4HANA for enterprise integration with Project System (PS), Materials Management (MM), and Finance/Controlling (FI/CO) modules.

## 2.2 Scope

This document covers:

- Complete entity definitions for all Well Cost Management modules

- Entity Relationship Diagrams (ERD) showing all associations

- S/4HANA integration entity mappings (PS, MM, FI/CO, PM)

- Data dictionary with field specifications

- Validation rules and constraints

- Performance optimization guidelines

- Data governance and quality standards

## 2.3 Data Model Summary



| Category | Entity Count | System of Record |
| --- | --- | --- |
| Master Data Entities | 18 | Well Cost + S/4HANA |
| Transactional Entities | 15 | Well Cost Management |
| Financial Entities | 10 | Well Cost + S/4HANA |
| Investment Economics Entities | 8 | Well Cost Management |
| Integration Entities | 6 | Well Cost Management |
| Security & Audit Entities | 5 | Well Cost Management |
| Configuration Entities | 4 | Well Cost Management |
| TOTAL | 66 | - |



# 3. Data Architecture Overview

## 3.1 Architecture Principles

- Hybrid Data Architecture: Well Cost Management maintains drilling-specific data locally while integrating with S/4HANA for enterprise master data and financial postings.

- CAP-Native Design: All entities designed for SAP Cloud Application Programming Model using CDS with managed aspects.

- UUID Primary Keys: All Well Cost entities use UUID for primary keys ensuring global uniqueness across distributed systems.

- Managed Aspect: All entities include audit fields (createdAt, createdBy, modifiedAt, modifiedBy) for SOX compliance.

- Soft Delete: Records are deactivated (isActive=false) rather than physically deleted for audit trail preservation.

- Referential Integrity: Foreign key constraints enforced at application and database level.

## 3.2 Technology Stack



| Component | Technology |
| --- | --- |
| Database | SAP HANA Cloud |
| Data Modeling | Core Data Services (CDS) |
| Application Framework | SAP CAP (Node.js runtime) |
| API Protocol | OData V4 |
| ERP Integration | SAP S/4HANA via SAP Integration Suite |
| Event Architecture | SAP Event Mesh |
| AI/ML Platform | SAP AI Core for Predictions |



## 3.3 Data Flow Architecture

The Well Cost Management data architecture follows a hub-and-spoke pattern with the following data flows:

- Inbound from S/4HANA: WBS Structure, Cost Elements, Vendor Master, Material Master, Plant/Storage Location

- Outbound to S/4HANA: Budget Reservations, WBS Creation, Cost Postings, Commitment Updates

- External Inbound: Drilling data (WITSML), Daily drilling reports, Vendor invoices, Time-depth curves

- External Outbound: Partner AFE distribution, JIB statements, Cost reports

# 4. Master Data Entities

Master data entities represent the foundational reference data used across all Well Cost Management modules. These entities are relatively static and serve as lookup references for transactional data.

## 4.1 Well (Wells)



| Entity Name | Well |
| --- | --- |
| CDS Table | wellcost.db.Wells |
| System of Record | Well Cost Management |
| Expected Volume | ~10,000 records |
| Description | Core well master with drilling specifications and classifications |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| wellNumber | String(20) | Yes | UK | Unique well identifier (API number format) |
| wellName | String(100) | Yes | - | Well name/description |
| wellType | String(20) | Yes | - | Exploration, Development, Workover, Sidetrack |
| field | Association | Yes | FK | Link to Fields entity |
| spudDate | Date | No | - | Planned/actual spud date |
| totalDepthMD | Decimal(10,2) | No | - | Total measured depth (meters) |
| totalDepthTVD | Decimal(10,2) | No | - | Total vertical depth (meters) |
| wellboreType | String(20) | No | - | Vertical, Horizontal, Directional |
| surfaceLatitude | Decimal(10,6) | No | - | Surface location latitude |
| surfaceLongitude | Decimal(10,6) | No | - | Surface location longitude |
| s4WBSElement | String(24) | No | - | S/4HANA WBS Element (POSID) |
| status | String(20) | Yes | - | Planned, Drilling, Completed, Suspended, P&A |
| isActive | Boolean | No | - | Active status (default: true) |



## 4.2 Field (Fields)



| Entity Name | Field |
| --- | --- |
| CDS Table | wellcost.db.Fields |
| System of Record | Well Cost Management |
| Expected Volume | ~500 records |
| Description | Oil and gas field/asset master data |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| fieldCode | String(20) | Yes | UK | Field identifier code |
| fieldName | String(100) | Yes | - | Field name |
| basin | String(50) | No | - | Geological basin name |
| country | Association | Yes | FK | Link to Countries |
| region | String(50) | No | - | Operating region (APAC, EMEA, Americas) |
| operator | String(100) | No | - | Operating company name |
| s4ProfitCenter | String(10) | No | - | S/4HANA Profit Center |
| s4CostCenter | String(10) | No | - | S/4HANA Cost Center |
| isActive | Boolean | No | - | Active status |



## 4.3 Cost Category (CostCategories)



| Entity Name | Cost Category |
| --- | --- |
| CDS Table | wellcost.db.CostCategories |
| System of Record | Well Cost Management + S/4HANA |
| Expected Volume | ~50 records |
| Description | High-level cost classification (Tangibles, Intangibles, Services) |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| categoryCode | String(10) | Yes | UK | Category code (TAN, INT, SVC) |
| categoryName | String(100) | Yes | - | Category name |
| categoryType | String(20) | Yes | - | CAPEX, OPEX, Contingency |
| parentCategory | Association | No | FK | Parent category for hierarchy |
| s4CostElement | String(10) | No | - | S/4HANA Cost Element group |
| accountingTreatment | String(20) | No | - | Capitalize, Expense |
| isActive | Boolean | No | - | Active status |



## 4.4 Cost Element (CostElements)



| Entity Name | Cost Element |
| --- | --- |
| CDS Table | wellcost.db.CostElements |
| System of Record | Well Cost Management + S/4HANA |
| Expected Volume | ~500 records |
| Description | Detailed cost line items mapped to S/4HANA cost elements |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| elementCode | String(20) | Yes | UK | Cost element code |
| elementName | String(100) | Yes | - | Cost element description |
| category | Association | Yes | FK | Link to CostCategories |
| uom | Association | Yes | FK | Default unit of measure |
| s4GLAccount | String(10) | No | - | S/4HANA GL Account |
| s4CostElement | String(10) | No | - | S/4HANA Cost Element |
| taxCode | String(5) | No | - | Default tax code |
| isActive | Boolean | No | - | Active status |



## 4.5 WBS Template (WBSTemplates)



| Entity Name | WBS Template |
| --- | --- |
| CDS Table | wellcost.db.WBSTemplates |
| System of Record | Well Cost Management |
| Expected Volume | ~100 records |
| Description | Pre-configured WBS structures by well type with 5+ hierarchy levels |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| templateCode | String(20) | Yes | UK | Template identifier |
| templateName | String(100) | Yes | - | Template name |
| wellType | String(20) | Yes | - | Exploration, Development, Workover |
| wellboreType | String(20) | No | - | Vertical, Horizontal, Directional |
| region | String(50) | No | - | Geographic region applicability |
| hierarchyLevels | Integer | Yes | - | Number of WBS levels (typically 5) |
| version | Integer | Yes | - | Template version number |
| effectiveFrom | Date | Yes | - | Template effective start date |
| effectiveTo | Date | No | - | Template effective end date |
| isActive | Boolean | No | - | Active status |



## 4.6 Vendor (Vendors)



| Entity Name | Vendor |
| --- | --- |
| CDS Table | wellcost.db.Vendors |
| System of Record | Well Cost Management + S/4HANA |
| Expected Volume | ~2,000 records |
| Description | Service providers and suppliers for drilling operations |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| vendorCode | String(20) | Yes | UK | Well Cost vendor code |
| vendorName | String(100) | Yes | - | Vendor legal name |
| vendorType | String(20) | Yes | - | Drilling, Completion, Services, Equipment |
| country | Association | Yes | FK | Link to Countries |
| currency | Association | No | FK | Preferred currency |
| paymentTerms | String(20) | No | - | Payment terms code |
| s4VendorNo | String(10) | No | - | S/4HANA Vendor (LIFNR) |
| s4BusinessPartner | String(10) | No | - | S/4HANA Business Partner |
| taxId | String(20) | No | - | Tax identification number |
| contactName | String(100) | No | - | Primary contact name |
| contactEmail | String(100) | No | - | Contact email |
| contactPhone | String(20) | No | - | Contact phone |
| isActive | Boolean | No | - | Active status |



## 4.7 Partner (Partners)



| Entity Name | Partner |
| --- | --- |
| CDS Table | wellcost.db.Partners |
| System of Record | Well Cost Management |
| Expected Volume | ~200 records |
| Description | Joint venture partners for cost sharing and JIB processing |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| partnerCode | String(20) | Yes | UK | Partner identifier |
| partnerName | String(100) | Yes | - | Partner company name |
| partnerType | String(20) | Yes | - | Operator, Non-Operator, Carried |
| country | Association | Yes | FK | Link to Countries |
| workingInterestDefault | Decimal(8,4) | No | - | Default working interest % |
| s4BusinessPartner | String(10) | No | - | S/4HANA Business Partner |
| billingAddress | String(500) | No | - | Billing address |
| contactName | String(100) | No | - | Primary contact |
| contactEmail | String(100) | No | - | Contact email |
| isActive | Boolean | No | - | Active status |



## 4.8 Country (Countries)



| Entity Name | Country |
| --- | --- |
| CDS Table | wellcost.db.Countries |
| System of Record | S/4HANA (T005) |
| Expected Volume | ~250 records |



## 4.9 Currency (Currencies)



| Entity Name | Currency |
| --- | --- |
| CDS Table | wellcost.db.Currencies |
| System of Record | S/4HANA (TCURC) |
| Expected Volume | ~180 records |



## 4.10 Unit of Measure (UnitsOfMeasure)



| Entity Name | Unit of Measure |
| --- | --- |
| CDS Table | wellcost.db.UnitsOfMeasure |
| System of Record | S/4HANA (T006) |
| Expected Volume | ~100 records |
| Description | Units for drilling (meters, feet, days, hours, barrels) |



# 5. Transactional Entities

Transactional entities capture the business operations and events that occur within Well Cost Management. These entities have higher data volumes and are the primary focus of operational processing.

## 5.1 AFE (AFEs)



| Entity Name | Authorization for Expenditure |
| --- | --- |
| CDS Table | wellcost.db.AFEs |
| System of Record | Well Cost Management |
| Expected Volume | ~10,000 records/year |
| Description | Core AFE document with approval workflow integration |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| afeNumber | String(20) | Yes | UK | Sequential AFE number with prefix |
| afeName | String(100) | Yes | - | AFE description |
| afeType | String(20) | Yes | - | Original, Supplement, Revision |
| well | Association | Yes | FK | Link to Wells |
| estimatedCost | Decimal(15,2) | Yes | - | Total estimated cost |
| currency | Association | Yes | FK | AFE currency |
| contingencyAmount | Decimal(15,2) | No | - | Contingency amount |
| contingencyPct | Decimal(5,2) | No | - | Contingency percentage |
| validFrom | Date | Yes | - | AFE effective start date |
| validTo | Date | Yes | - | AFE effective end date |
| parentAFE | Association | No | FK | Original AFE (for supplements) |
| version | Integer | Yes | - | AFE version number |
| approvalStatus | String(20) | Yes | - | Draft, Pending, Approved, Rejected |
| approvedDate | Timestamp | No | - | Approval timestamp |
| approvedBy | String(100) | No | - | Approver user ID |
| s4ProjectNo | String(24) | No | - | S/4HANA Project (PSPNR) |
| s4WBSElement | String(24) | No | - | S/4HANA WBS Element |
| status | String(20) | Yes | - | Active, Closed, Cancelled |



## 5.2 Cost Estimate (CostEstimates)



| Entity Name | Cost Estimate |
| --- | --- |
| CDS Table | wellcost.db.CostEstimates |
| System of Record | Well Cost Management |
| Expected Volume | ~50,000 records/year |
| Description | Detailed cost estimate line items linked to AFE |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| afe | Association | Yes | FK | Link to AFEs |
| wbsElement | Association | Yes | FK | Link to WBS element |
| costElement | Association | Yes | FK | Link to CostElements |
| vendor | Association | No | FK | Preferred vendor |
| description | String(200) | No | - | Line item description |
| quantity | Decimal(15,4) | Yes | - | Estimated quantity |
| uom | Association | Yes | FK | Unit of measure |
| unitRate | Decimal(15,4) | Yes | - | Unit rate |
| estimatedAmount | Decimal(15,2) | Yes | - | Total amount (calculated) |
| currency | Association | Yes | FK | Line item currency |
| startDate | Date | No | - | Planned start date |
| endDate | Date | No | - | Planned end date |
| durationDays | Decimal(10,2) | No | - | Estimated duration |
| sourceType | String(20) | No | - | Manual, Benchmark, Contract |



## 5.3 Cost Actual (CostActuals)



| Entity Name | Cost Actual |
| --- | --- |
| CDS Table | wellcost.db.CostActuals |
| System of Record | Well Cost Management + S/4HANA |
| Expected Volume | ~200,000 records/year |
| Description | Actual cost postings from S/4HANA with variance tracking |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| afe | Association | Yes | FK | Link to AFEs |
| wbsElement | Association | Yes | FK | Link to WBS element |
| costElement | Association | Yes | FK | Link to CostElements |
| vendor | Association | No | FK | Actual vendor |
| postingDate | Date | Yes | - | S/4HANA posting date |
| documentDate | Date | Yes | - | Document date |
| quantity | Decimal(15,4) | No | - | Actual quantity |
| uom | Association | No | FK | Unit of measure |
| actualAmount | Decimal(15,2) | Yes | - | Actual posted amount |
| currency | Association | Yes | FK | Posting currency |
| s4DocumentNo | String(10) | No | - | S/4HANA FI Document |
| s4PONumber | String(10) | No | - | S/4HANA PO Number |
| referenceText | String(100) | No | - | Reference/invoice number |
| costType | String(20) | Yes | - | Actual, Commitment, Accrual |



## 5.4 Daily Drilling Report (DailyReports)



| Entity Name | Daily Drilling Report |
| --- | --- |
| CDS Table | wellcost.db.DailyReports |
| System of Record | Well Cost Management |
| Expected Volume | ~100,000 records/year |
| Description | Daily operations data for cost/day and NPT tracking |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| well | Association | Yes | FK | Link to Wells |
| afe | Association | Yes | FK | Link to AFEs |
| reportDate | Date | Yes | UK | Report date (unique per well) |
| dayNumber | Integer | Yes | - | Days since spud |
| depthMD | Decimal(10,2) | No | - | Current measured depth (m) |
| depthTVD | Decimal(10,2) | No | - | Current true vertical depth (m) |
| footageDrilled | Decimal(10,2) | No | - | Footage drilled today (m) |
| productiveHours | Decimal(5,2) | No | - | Productive time (hours) |
| nptHours | Decimal(5,2) | No | - | Non-productive time (hours) |
| nptCategory | String(50) | No | - | NPT category (Weather, Equipment, etc.) |
| dailyCost | Decimal(15,2) | No | - | Total cost for the day |
| cumulativeCost | Decimal(15,2) | No | - | Cumulative cost to date |
| operationPhase | String(20) | Yes | - | Drilling, Completion, Testing |
| remarks | String(1000) | No | - | Operations summary |



## 5.5 Approval (Approvals)



| Entity Name | Approval |
| --- | --- |
| CDS Table | wellcost.db.Approvals |
| System of Record | Well Cost Management |
| Expected Volume | ~50,000 records/year |
| Description | Approval workflow history and audit trail |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| afe | Association | Yes | FK | Link to AFEs |
| approvalLevel | Integer | Yes | - | Approval level (1, 2, 3...) |
| approverRole | String(50) | Yes | - | Approver role (Engineering, Finance, etc.) |
| approverUserId | String(100) | Yes | - | Assigned approver user ID |
| approverName | String(100) | No | - | Approver display name |
| delegatedFrom | String(100) | No | - | Original approver if delegated |
| assignedDate | Timestamp | Yes | - | Assignment timestamp |
| dueDate | Timestamp | No | - | Approval deadline |
| actionDate | Timestamp | No | - | Action taken timestamp |
| action | String(20) | No | - | Approved, Rejected, Returned, Pending |
| comments | String(1000) | No | - | Approver comments |
| conditions | String(500) | No | - | Approval conditions if any |



# 6. Financial Entities

Financial entities support commitment tracking, cost allocation, partner billing, and integration with SAP S/4HANA Finance (FI/CO) and Project System (PS) modules.

## 6.1 Commitment (Commitments)



| Entity Name | Commitment |
| --- | --- |
| CDS Table | wellcost.db.Commitments |
| System of Record | Well Cost Management + S/4HANA |
| Expected Volume | ~100,000 records/year |
| Description | Purchase order commitments from S/4HANA |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| afe | Association | Yes | FK | Link to AFEs |
| wbsElement | Association | Yes | FK | Link to WBS element |
| costElement | Association | Yes | FK | Link to CostElements |
| vendor | Association | No | FK | Link to Vendors |
| s4PONumber | String(10) | Yes | - | S/4HANA PO Number (EBELN) |
| s4POItem | String(5) | Yes | - | S/4HANA PO Item (EBELP) |
| commitmentDate | Date | Yes | - | Commitment creation date |
| commitmentAmount | Decimal(15,2) | Yes | - | Committed amount |
| consumedAmount | Decimal(15,2) | No | - | Amount consumed by actuals |
| remainingAmount | Decimal(15,2) | No | - | Remaining commitment |
| currency | Association | Yes | FK | Commitment currency |
| status | String(20) | Yes | - | Open, PartiallyConsumed, Closed |



## 6.2 Partner Interest (PartnerInterests)



| Entity Name | Partner Interest |
| --- | --- |
| CDS Table | wellcost.db.PartnerInterests |
| System of Record | Well Cost Management |
| Expected Volume | ~5,000 records |
| Description | Working interest percentages by well/AFE for JIB allocation |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| well | Association | Yes | FK | Link to Wells |
| afe | Association | No | FK | Link to AFEs (if AFE-specific) |
| partner | Association | Yes | FK | Link to Partners |
| workingInterest | Decimal(8,4) | Yes | - | Working interest percentage |
| netRevenueInterest | Decimal(8,4) | No | - | Net revenue interest % |
| effectiveFrom | Date | Yes | - | Interest effective start date |
| effectiveTo | Date | No | - | Interest effective end date |
| consentStatus | String(20) | No | - | Consent, Non-Consent, Pending |
| consentDate | Timestamp | No | - | Consent response timestamp |
| isOperator | Boolean | No | - | Is this partner the operator? |



## 6.3 JIB Statement (JIBStatements)



| Entity Name | Joint Interest Billing Statement |
| --- | --- |
| CDS Table | wellcost.db.JIBStatements |
| System of Record | Well Cost Management |
| Expected Volume | ~20,000 records/year |
| Description | Monthly JIB statements for partner cost allocation |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| statementNumber | String(20) | Yes | UK | JIB statement number |
| well | Association | Yes | FK | Link to Wells |
| afe | Association | Yes | FK | Link to AFEs |
| partner | Association | Yes | FK | Link to Partners |
| billingPeriodFrom | Date | Yes | - | Billing period start |
| billingPeriodTo | Date | Yes | - | Billing period end |
| workingInterest | Decimal(8,4) | Yes | - | Applied working interest % |
| grossAmount | Decimal(15,2) | Yes | - | Total gross costs |
| partnerShare | Decimal(15,2) | Yes | - | Partner's share amount |
| currency | Association | Yes | FK | Statement currency |
| dueDate | Date | No | - | Payment due date |
| status | String(20) | Yes | - | Draft, Sent, Paid, Disputed |



# 7. Investment Economics Entities

Investment Economics entities support the Business Case Management module (BC-F001 through BC-F005), enabling NPV/IRR calculations, scenario analysis, and investment decision support.

## 7.1 Economics Analysis (EconomicsAnalyses)



| Entity Name | Economics Analysis |
| --- | --- |
| CDS Table | wellcost.db.EconomicsAnalyses |
| System of Record | Well Cost Management |
| Expected Volume | ~5,000 records/year |
| Description | Investment analysis records with NPV/IRR results |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| analysisName | String(100) | Yes | - | Analysis name/description |
| well | Association | Yes | FK | Link to Wells |
| afe | Association | No | FK | Link to AFEs (if linked) |
| analysisType | String(20) | Yes | - | NEW_WELL, WORKOVER, ACQUISITION |
| discountRate | Decimal(8,4) | Yes | - | Discount rate (e.g., 0.10 for 10%) |
| inflationRate | Decimal(8,4) | No | - | Inflation rate assumption |
| npv | Decimal(15,2) | No | - | Calculated Net Present Value |
| irr | Decimal(8,4) | No | - | Calculated Internal Rate of Return |
| mirr | Decimal(8,4) | No | - | Modified IRR (if enabled) |
| paybackYears | Decimal(5,2) | No | - | Simple payback period (years) |
| discountedPayback | Decimal(5,2) | No | - | Discounted payback (years) |
| profitabilityIndex | Decimal(8,4) | No | - | PI ratio (PV inflows/outflows) |
| recommendation | String(20) | No | - | RECOMMEND, MARGINAL, DO_NOT_RECOMMEND |
| calculatedAt | Timestamp | No | - | Last calculation timestamp |
| status | String(20) | Yes | - | Draft, Pending, Approved |



## 7.2 Cash Flow (CashFlows)



| Entity Name | Cash Flow |
| --- | --- |
| CDS Table | wellcost.db.CashFlows |
| System of Record | Well Cost Management |
| Expected Volume | ~100,000 records/year |
| Description | Year-by-year cash flow projections for economics analysis |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| analysis | Association | Yes | FK | Link to EconomicsAnalyses |
| year | Integer | Yes | - | Year number (0, 1, 2, ... n) |
| capex | Decimal(15,2) | No | - | Capital expenditure |
| opex | Decimal(15,2) | No | - | Operating expenditure |
| revenue | Decimal(15,2) | No | - | Gross revenue |
| royalty | Decimal(15,2) | No | - | Royalty payments |
| taxes | Decimal(15,2) | No | - | Income taxes |
| netCashFlow | Decimal(15,2) | Yes | - | Net cash flow (calculated) |
| discountedCashFlow | Decimal(15,2) | No | - | Discounted cash flow |
| cumulativeCashFlow | Decimal(15,2) | No | - | Running cumulative total |
| oilProduction | Decimal(15,2) | No | - | Oil production (barrels) |
| gasProduction | Decimal(15,2) | No | - | Gas production (mcf) |



## 7.3 Hurdle Rate (HurdleRates)



| Entity Name | Hurdle Rate |
| --- | --- |
| CDS Table | wellcost.db.HurdleRates |
| System of Record | Well Cost Management |
| Expected Volume | ~50 records |
| Description | Corporate, asset, and project-level hurdle rate configurations |



### Field Specifications



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| rateType | String(20) | Yes | - | CORPORATE, ASSET, PROJECT |
| field | Association | No | FK | Link to Fields (for asset-level) |
| rateName | String(50) | Yes | - | Rate name/description |
| rate | Decimal(8,4) | Yes | - | Hurdle rate value |
| riskPremium | Decimal(8,4) | No | - | Additional risk premium |
| effectiveFrom | Date | Yes | - | Rate effective start date |
| effectiveTo | Date | No | - | Rate effective end date |
| approvedBy | String(100) | No | - | Rate approver |
| isActive | Boolean | No | - | Active status |



# 8. S/4HANA Integration Mapping

This section documents the mapping between Well Cost Management entities and SAP S/4HANA structures for integration via SAP Integration Suite.

## 8.1 Master Data Mapping



| Well Cost Entity | S/4HANA Table | API | Direction |
| --- | --- | --- | --- |
| Vendors | BUT000 / LFA1 | API_BUSINESS_PARTNER | Inbound |
| CostElements | CSKA / CSKB | API_COSTCENTER_SRV | Inbound |
| Countries | T005 | Standard OData | Inbound |
| Currencies | TCURC | Standard OData | Inbound |
| UnitsOfMeasure | T006 | Standard OData | Inbound |
| WBSTemplates | PRPS | API_PROJECT_SRV | Bidirectional |



## 8.2 Transactional Mapping



| Well Cost Entity | S/4HANA Table | API | Direction |
| --- | --- | --- | --- |
| AFEs (Budget) | FMPS / BPBK | API_PROJECT_SRV | Outbound |
| AFEs (WBS) | PRPS | API_PROJECT_SRV | Outbound |
| CostActuals | BKPF / BSEG | API_JOURNALENTRY | Inbound |
| Commitments | EKKO / EKPO | API_PURCHASEORDER | Inbound |
| JIBStatements | BKPF / BSEG | API_JOURNALENTRY | Outbound |



## 8.3 Key Field Mapping



| Well Cost Field | S/4HANA Field | Table | Notes |
| --- | --- | --- | --- |
| Vendor.s4VendorNo | LIFNR | LFA1 | 10-char vendor number |
| AFE.s4ProjectNo | PSPNR | PROJ | Internal project number |
| AFE.s4WBSElement | POSID | PRPS | 24-char WBS element |
| CostElement.s4GLAccount | SAKNR | SKA1 | 10-char GL account |
| CostActual.s4DocumentNo | BELNR | BKPF | 10-char FI document |
| Commitment.s4PONumber | EBELN | EKKO | 10-char PO number |
| Field.s4ProfitCenter | PRCTR | CEPC | 10-char profit center |
| Field.s4CostCenter | KOSTL | CSKS | 10-char cost center |



# 9. Indexes and Performance

## 9.1 Recommended Indexes



| Index Name | Entity | Fields | Purpose |
| --- | --- | --- | --- |
| idx_well_number | Wells | wellNumber | Well lookup by API number |
| idx_well_field | Wells | field_ID, status | Wells by field queries |
| idx_afe_number | AFEs | afeNumber | AFE lookup |
| idx_afe_well | AFEs | well_ID, approvalStatus | AFEs by well |
| idx_estimate_afe | CostEstimates | afe_ID | Estimates by AFE |
| idx_actual_afe_date | CostActuals | afe_ID, postingDate | Actuals for variance |
| idx_daily_well_date | DailyReports | well_ID, reportDate | Daily report lookup |
| idx_approval_afe | Approvals | afe_ID, action | Approval status lookup |
| idx_commitment_afe | Commitments | afe_ID, status | Commitment tracking |
| idx_jib_period | JIBStatements | billingPeriodFrom, partner_ID | JIB queries |



## 9.2 Performance Guidelines

- Partitioning Strategy: Partition transactional tables (CostActuals, DailyReports, Commitments) by posting date for improved query performance and data lifecycle management.

- Data Archiving: Implement archiving for records older than 7 years to maintain SOX compliance while optimizing performance.

- Query Optimization: Use CDS views with appropriate projections to limit data transfer. Implement calculation views for complex aggregations.

- Caching: Implement TTL-based caching for master data (15-30 minutes) and hurdle rates (24 hours).

- Batch Processing: Schedule cost actual syncs during off-peak hours. Target < 15 minute refresh for real-time variance dashboards.

# 10. Validation Rules Summary



| Error Code | Entity | Rule Description | Severity |
| --- | --- | --- | --- |
| WCM-MD-001 | Well | wellNumber must be unique | Error |
| WCM-MD-002 | Well | spudDate cannot be future for status=Drilling | Error |
| WCM-MD-003 | Field | fieldCode must be unique | Error |
| WCM-MD-004 | CostElement | elementCode must be unique | Error |
| WCM-MD-005 | Vendor | vendorCode must be unique | Error |
| WCM-AFE-001 | AFE | afeNumber must be unique | Error |
| WCM-AFE-002 | AFE | validFrom must be < validTo | Error |
| WCM-AFE-003 | AFE | Supplement requires parentAFE | Error |
| WCM-AFE-004 | AFE | estimatedCost must be > 0 | Error |
| WCM-AFE-005 | AFE | contingencyPct between 0-50% | Warning |
| WCM-EST-001 | CostEstimate | quantity must be > 0 | Error |
| WCM-EST-002 | CostEstimate | unitRate must be >= 0 | Error |
| WCM-ACT-001 | CostActual | actualAmount cannot be 0 | Error |
| WCM-VAR-001 | Variance | Variance > 10% requires approval | Warning |
| WCM-JIB-001 | PartnerInterest | Sum of workingInterest must = 100% | Error |
| WCM-JIB-002 | JIBStatement | billingPeriodFrom < billingPeriodTo | Error |
| WCM-ECO-001 | EconomicsAnalysis | discountRate between 0-50% | Error |
| WCM-ECO-002 | CashFlow | Year 0 typically has negative netCashFlow | Warning |



# 11. Appendix

## 11.1 Entity Count by Module



| Module | Module Name | Entity Count | Key Entities |
| --- | --- | --- | --- |
| WCM-01 | Business Case Management | 8 | EconomicsAnalyses, CashFlows, HurdleRates |
| WCM-02 | Cost Estimation | 6 | CostEstimates, WBSTemplates, CostElements |
| WCM-03 | AFE Lifecycle | 8 | AFEs, Approvals, AFEVersions |
| WCM-04 | Variance Analysis | 5 | CostActuals, Variances, VarianceCategories |
| WCM-05 | Reporting & Analytics | 4 | DailyReports, KPISnapshots |
| WCM-06 | S/4HANA Integration | 6 | IntegrationLogs, MappingConfigs |
| WCM-07 | Data Pipeline | 5 | DataQualityRules, ETLJobs |
| WCM-08 | Master Data | 10 | Wells, Fields, Vendors, Partners |
| WCM-09 | Partner/JIB Operations | 6 | PartnerInterests, JIBStatements |
| WCM-10 | Document Management | 4 | Documents, Attachments |
| WCM-11 | Security Management | 4 | Users, Roles, AuditLogs |
| TOTAL | - | 66 | - |



## 11.2 Glossary



| Term | Definition |
| --- | --- |
| AFE | Authorization for Expenditure - formal approval document for well costs |
| AvE | Actual vs Estimate - variance analysis between planned and actual costs |
| CAP | SAP Cloud Application Programming Model |
| CDS | Core Data Services - SAP data modeling language |
| IRR | Internal Rate of Return - investment metric |
| JIB | Joint Interest Billing - cost allocation for joint ventures |
| NPT | Non-Productive Time - drilling time not contributing to progress |
| NPV | Net Present Value - investment metric |
| RACI | Responsible, Accountable, Consulted, Informed - responsibility matrix |
| WBS | Work Breakdown Structure - hierarchical cost structure |
| WITSML | Wellsite Information Transfer Standard Markup Language |



## 11.3 References

- IBU-ARCH-001: Solution Architecture Document - Well Cost Management

- PFD-WCM-2025-001: Product Feature Document - Well Cost Management

- FSD-WCM-BC-001: Functional Specification - Investment Economics Engine

- WCM-RACI-001: Well Cost Management RACI Matrix

- SAP CAP Documentation: https://cap.cloud.sap/docs/

- SAP HANA Cloud: https://help.sap.com/hana-cloud

- SAP API Business Hub: https://api.sap.com

*--- End of Document ---*
