# Well Cost Management - Database Design Document

**Document ID**: WCM-DB-001
**Version**: 1.0
**Date**: January 2026
**Status**: Draft

---

## Table of Contents

1. [Overview](#1-overview)
2. [Database Architecture](#2-database-architecture)
3. [Entity Relationship Diagram](#3-entity-relationship-diagram)
4. [Entity Definitions](#4-entity-definitions)
5. [S/4HANA Integration Mappings](#5-s4hana-integration-mappings)
6. [Indexes and Performance](#6-indexes-and-performance)
7. [Data Validation Rules](#7-data-validation-rules)
8. [Data Volume Projections](#8-data-volume-projections)

---

## 1. Overview

### 1.1 Purpose

This document defines the database design for the Well Cost Management (WCM) system, a comprehensive oil & gas drilling cost lifecycle management solution built on SAP Business Technology Platform (BTP) with SAP HANA Cloud.

### 1.2 Scope

The database design covers:
- 66+ entities across 7 functional layers
- Master data, transactional, and financial entities
- Investment economics and JV operations
- S/4HANA integration mappings
- Security and audit trail

### 1.3 Database Platform

| Attribute | Value |
|-----------|-------|
| Database | SAP HANA Cloud |
| Platform | SAP Business Technology Platform (BTP) |
| ORM | CAP CDS (Core Data Services) |
| API Layer | OData V4 |

---

## 2. Database Architecture

### 2.1 Data Layer Organization

```
┌─────────────────────────────────────────────────────────────────┐
│                     DATABASE LAYERS                              │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1: MASTER DATA (18 entities)                             │
│  └── Wells, Fields, Vendors, Partners, CostElements, etc.       │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: TRANSACTIONAL (15 entities)                           │
│  └── AFEs, AFELineItems, CostEstimates, CostActuals, etc.       │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3: FINANCIAL (10 entities)                               │
│  └── Commitments, PartnerInterests, JIBStatements, etc.         │
├─────────────────────────────────────────────────────────────────┤
│  Layer 4: INVESTMENT ECONOMICS (8 entities)                     │
│  └── EconomicsAnalyses, CashFlows, HurdleRates, Scenarios       │
├─────────────────────────────────────────────────────────────────┤
│  Layer 5: INTEGRATION (6 entities)                              │
│  └── IntegrationLogs, DataQualityRules, MappingConfigs          │
├─────────────────────────────────────────────────────────────────┤
│  Layer 6: SECURITY & AUDIT (5 entities)                         │
│  └── Users, Roles, AuditLogs, UserRoles, RoleScopes             │
├─────────────────────────────────────────────────────────────────┤
│  Layer 7: CONFIGURATION (4 entities)                            │
│  └── ApprovalMatrix, SystemConfig, UserPreferences              │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Entity Summary

| Layer | Entity Count | Purpose |
|-------|--------------|---------|
| Master Data | 18 | Reference data (wells, vendors, partners) |
| Transactional | 15 | Core business transactions (AFEs, estimates) |
| Financial | 10 | Cost tracking and JV operations |
| Investment Economics | 8 | NPV/IRR calculations, cash flows |
| Integration | 6 | S/4HANA sync and data quality |
| Security & Audit | 5 | Access control and audit trail |
| Configuration | 4 | System settings and approval rules |
| **Total** | **66** | |

---

## 3. Entity Relationship Diagram

### 3.1 High-Level ERD

```
                                    ┌──────────────┐
                                    │   Country    │
                                    └──────┬───────┘
                                           │
              ┌────────────────────────────┼────────────────────────────┐
              │                            │                            │
              ▼                            ▼                            ▼
       ┌──────────────┐            ┌──────────────┐            ┌──────────────┐
       │    Field     │            │    Vendor    │            │   Partner    │
       └──────┬───────┘            └──────┬───────┘            └──────┬───────┘
              │                           │                           │
              │                           │                           │
              ▼                           │                           │
       ┌──────────────┐                   │                           │
       │     Well     │◄──────────────────┼───────────────────────────┘
       └──────┬───────┘                   │                           │
              │                           │                           │
              │                           ▼                           ▼
              │                    ┌──────────────┐            ┌──────────────┐
              │                    │ CostEstimate │            │PartnerIntrst │
              │                    └──────┬───────┘            └──────┬───────┘
              │                           │                           │
              ▼                           │                           │
       ┌──────────────┐                   │                           │
       │     AFE      │◄──────────────────┘                           │
       └──────┬───────┘                                               │
              │                                                       │
    ┌─────────┼─────────┬─────────────────┬───────────────┐          │
    │         │         │                 │               │          │
    ▼         ▼         ▼                 ▼               ▼          ▼
┌────────┐┌────────┐┌────────┐     ┌──────────┐   ┌──────────┐┌──────────┐
│AFELine ││Approval││CostActl│     │DailyRprt │   │Economics ││JIBStmnt  │
│  Item  ││        ││        │     │          │   │Analysis  ││          │
└────────┘└────────┘└────────┘     └──────────┘   └────┬─────┘└──────────┘
                                                       │
                                                       ▼
                                                 ┌──────────┐
                                                 │ CashFlow │
                                                 └──────────┘
```

### 3.2 Core Business Entity Relationships

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MASTER DATA RELATIONSHIPS                             │
│                                                                              │
│   Country ──1:M──> Field ──1:M──> Well                                      │
│      │                              │                                        │
│      └──1:M──> Vendor               ├──M:1──> WBSTemplate                   │
│      └──1:M──> Partner              └──1:M──> PartnerInterest               │
│                                                                              │
│   CostCategory ──1:M──> CostElement ──M:1──> UnitOfMeasure                  │
│        │ (hierarchical self-reference)                                       │
│        └──M:1──> CostCategory (parent)                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                     AFE LIFECYCLE RELATIONSHIPS                              │
│                                                                              │
│   AFE ──M:1──> Well                                                         │
│    │                                                                         │
│    ├──1:M──> AFELineItem ──M:1──> WBSElement                               │
│    │              └──M:1──> CostElement                                     │
│    │              └──M:1──> Vendor                                          │
│    │                                                                         │
│    ├──1:M──> Approval ──M:1──> User                                        │
│    │                                                                         │
│    ├──1:M──> CostEstimate ──M:1──> WBSElement                              │
│    │              └──M:1──> CostElement                                     │
│    │                                                                         │
│    ├──1:M──> CostActual ──M:1──> WBSElement                                │
│    │              └──M:1──> CostElement                                     │
│    │              └──M:1──> Vendor                                          │
│    │                                                                         │
│    ├──1:M──> Commitment ──M:1──> Vendor                                    │
│    │                                                                         │
│    ├──1:M──> DailyReport                                                   │
│    │                                                                         │
│    ├──M:1──> AFE (parentAFE - self-reference for supplements)              │
│    │                                                                         │
│    └──1:M──> AFEDocument                                                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                  FINANCIAL/JV RELATIONSHIPS                                  │
│                                                                              │
│   PartnerInterest ──M:1──> Well                                             │
│         │          ──M:1──> AFE (optional)                                  │
│         │          ──M:1──> Partner                                         │
│         │                                                                    │
│         └──1:M──> JIBStatement                                              │
│                                                                              │
│   Variance ──M:1──> CostActual                                              │
│            ──M:1──> CostEstimate                                            │
│            ──M:1──> VarianceCategory                                        │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                 INVESTMENT ECONOMICS RELATIONSHIPS                           │
│                                                                              │
│   EconomicsAnalysis ──M:1──> Well                                           │
│          │          ──M:1──> AFE (optional)                                 │
│          │                                                                   │
│          ├──1:M──> CashFlow                                                 │
│          ├──1:M──> Scenario                                                 │
│          └──1:M──> SensitivityResult                                        │
│                                                                              │
│   HurdleRate ──M:1──> Field (optional, for asset-level rates)              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Entity Definitions

### 4.1 Master Data Entities

#### 4.1.1 Wells

Primary entity for well master data.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| wellNumber | String(20) | UK, NOT NULL | Unique well identifier (API format) |
| wellName | String(100) | NOT NULL | Well display name |
| wellType | String(20) | NOT NULL | Exploration, Development, Workover, Sidetrack |
| field_ID | UUID | FK → Fields | Associated field |
| spudDate | Date | | Planned/actual spud date |
| totalDepthMD | Decimal(10,2) | | Measured depth (meters) |
| totalDepthTVD | Decimal(10,2) | | True vertical depth (meters) |
| wellboreType | String(20) | | Vertical, Horizontal, Directional |
| surfaceLatitude | Decimal(10,6) | | Surface location latitude |
| surfaceLongitude | Decimal(10,6) | | Surface location longitude |
| s4WBSElement | String(24) | | SAP S/4HANA WBS Element (POSID) |
| status | String(20) | NOT NULL | Planned, Drilling, Completed, Suspended, P&A |
| isActive | Boolean | DEFAULT true | Active flag |
| createdAt | Timestamp | | Creation timestamp |
| createdBy | String(100) | | Created by user |
| modifiedAt | Timestamp | | Last modification timestamp |
| modifiedBy | String(100) | | Modified by user |

**Indexes**: `wellNumber` (unique), `(field_ID, status)`

---

#### 4.1.2 Fields

Field/asset master data.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| fieldCode | String(20) | UK, NOT NULL | Unique field code |
| fieldName | String(100) | NOT NULL | Field display name |
| basin | String(50) | | Geological basin name |
| country_ID | UUID | FK → Countries | Country reference |
| region | String(50) | | APAC, EMEA, Americas |
| operatorName | String(100) | | Operating company name |
| s4ProfitCenter | String(10) | | S/4HANA Profit Center |
| s4CostCenter | String(10) | | S/4HANA Cost Center |
| isActive | Boolean | DEFAULT true | Active flag |
| createdAt | Timestamp | | Creation timestamp |
| modifiedAt | Timestamp | | Last modification timestamp |

**Indexes**: `fieldCode` (unique), `country_ID`

---

#### 4.1.3 CostCategories

Cost category hierarchy.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| categoryCode | String(10) | UK, NOT NULL | TAN, INT, SVC |
| categoryName | String(100) | NOT NULL | Category display name |
| categoryType | String(20) | NOT NULL | CAPEX, OPEX, Contingency |
| parent_ID | UUID | FK → CostCategories | Hierarchical parent |
| s4CostElement | String(10) | | S/4HANA Cost Element group |
| accountingTreatment | String(20) | | Capitalize, Expense |
| hierarchyLevel | Integer | | Level in hierarchy (1-5) |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `categoryCode` (unique), `parent_ID`

---

#### 4.1.4 CostElements

Detailed cost element master.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| elementCode | String(20) | UK, NOT NULL | Unique element code |
| elementName | String(100) | NOT NULL | Element display name |
| category_ID | UUID | FK → CostCategories | Parent category |
| uom_ID | UUID | FK → UnitsOfMeasure | Default UoM |
| s4GLAccount | String(10) | | S/4HANA GL Account |
| s4CostElement | String(10) | | S/4HANA Cost Element |
| taxCode | String(5) | | Tax treatment code |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `elementCode` (unique), `category_ID`

---

#### 4.1.5 WBSTemplates

Pre-configured WBS structures for standard well operations.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| templateCode | String(20) | UK, NOT NULL | Unique template code |
| templateName | String(100) | NOT NULL | Template display name |
| wellType | String(20) | NOT NULL | Exploration, Development, Workover |
| wellboreType | String(20) | | Vertical, Horizontal, Directional |
| region | String(50) | | Geographic region applicability |
| hierarchyLevels | Integer | DEFAULT 5 | Number of WBS levels |
| versionNumber | Integer | DEFAULT 1 | Template version |
| effectiveFromDate | Date | | Effective start date |
| effectiveToDate | Date | | Effective end date |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `templateCode` (unique), `(wellType, wellboreType)`

---

#### 4.1.6 Vendors

Vendor/supplier master data.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| vendorCode | String(20) | UK, NOT NULL | Unique vendor code |
| vendorName | String(100) | NOT NULL | Vendor display name |
| vendorType | String(20) | | Drilling, Completion, Services, Equipment |
| country_ID | UUID | FK → Countries | Country reference |
| currency_ID | UUID | FK → Currencies | Default currency |
| paymentTerms | String(20) | | Payment terms code |
| s4VendorNo | String(10) | | S/4HANA Vendor (LIFNR) |
| s4BusinessPartner | String(10) | | S/4HANA Business Partner |
| taxId | String(20) | | Tax identification number |
| contactName | String(100) | | Primary contact name |
| contactEmail | String(100) | | Contact email |
| contactPhone | String(20) | | Contact phone |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `vendorCode` (unique), `s4VendorNo`, `vendorType`

---

#### 4.1.7 Partners

JV partner master data.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| partnerCode | String(20) | UK, NOT NULL | Unique partner code |
| partnerName | String(100) | NOT NULL | Partner display name |
| partnerType | String(20) | NOT NULL | Operator, Non-Operator, Carried |
| country_ID | UUID | FK → Countries | Country reference |
| workingInterestDefault | Decimal(8,4) | | Default WI% |
| s4BusinessPartner | String(10) | | S/4HANA Business Partner |
| billingAddress | String(500) | | Billing address |
| contactName | String(100) | | Primary contact name |
| contactEmail | String(100) | | Contact email |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `partnerCode` (unique), `partnerType`

---

#### 4.1.8 Countries

Country reference data (synced from S/4HANA T005).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| countryCode | String(3) | UK, NOT NULL | ISO 3166-1 alpha-3 |
| countryCode2 | String(2) | UK, NOT NULL | ISO 3166-1 alpha-2 |
| countryName | String(100) | NOT NULL | Country name |
| region | String(50) | | Geographic region |
| isActive | Boolean | DEFAULT true | Active flag |

**System of Record**: S/4HANA (T005)

---

#### 4.1.9 Currencies

Currency reference data (synced from S/4HANA TCURC).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| currencyCode | String(3) | UK, NOT NULL | ISO 4217 currency code |
| currencyName | String(100) | NOT NULL | Currency name |
| decimalPlaces | Integer | DEFAULT 2 | Decimal precision |
| isActive | Boolean | DEFAULT true | Active flag |

**System of Record**: S/4HANA (TCURC)

---

#### 4.1.10 UnitsOfMeasure

Unit of measure reference data (synced from S/4HANA T006).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| uomCode | String(10) | UK, NOT NULL | Unit code |
| uomName | String(50) | NOT NULL | Unit name |
| uomType | String(20) | | Length, Time, Volume, Weight |
| s4UoM | String(3) | | S/4HANA unit code |
| isActive | Boolean | DEFAULT true | Active flag |

**System of Record**: S/4HANA (T006)

---

### 4.2 Transactional Entities

#### 4.2.1 AFEs (Authorization for Expenditure)

Core AFE document entity.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afeNumber | String(20) | UK, NOT NULL | Sequential AFE number (AFE-PERM-2025-001) |
| afeName | String(100) | NOT NULL | AFE display name |
| afeType | String(20) | NOT NULL | Original, Supplement, Revision |
| well_ID | UUID | FK → Wells, NOT NULL | Associated well |
| estimatedCost | Decimal(15,2) | NOT NULL, > 0 | Total estimated cost |
| currency_ID | UUID | FK → Currencies | AFE currency |
| contingencyAmount | Decimal(15,2) | | Contingency amount |
| contingencyPct | Decimal(5,2) | CHECK 0-50 | Contingency percentage |
| validFromDate | Date | NOT NULL | AFE effective start |
| validToDate | Date | NOT NULL | AFE effective end |
| parentAFE_ID | UUID | FK → AFEs | Parent AFE (for supplements) |
| versionNumber | Integer | DEFAULT 1 | AFE version |
| approvalStatus | String(20) | NOT NULL | Draft, Pending, Approved, Rejected |
| approvedDate | Timestamp | | Approval date |
| approvedBy | String(100) | | Approving user |
| s4ProjectNo | String(24) | | S/4HANA Project (PSPNR) |
| s4WBSElement | String(24) | | S/4HANA WBS Element (POSID) |
| status | String(20) | NOT NULL | Active, Closed, Cancelled |
| createdAt | Timestamp | | Creation timestamp |
| createdBy | String(100) | | Created by user |
| modifiedAt | Timestamp | | Last modification timestamp |
| modifiedBy | String(100) | | Modified by user |

**Constraints**:
- `validFromDate < validToDate`
- `afeType = 'Supplement'` requires `parentAFE_ID NOT NULL`

**Indexes**: `afeNumber` (unique), `(well_ID, approvalStatus)`, `createdAt DESC`

---

#### 4.2.2 AFELineItems

AFE line item details following WBS hierarchy.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| wbsElement_ID | UUID | FK → WBSElements | WBS element reference |
| costElement_ID | UUID | FK → CostElements | Cost element reference |
| vendor_ID | UUID | FK → Vendors | Vendor (optional) |
| lineNumber | Integer | NOT NULL | Line sequence number |
| description | String(200) | NOT NULL | Line item description |
| quantity | Decimal(15,4) | NOT NULL, > 0 | Quantity |
| uom_ID | UUID | FK → UnitsOfMeasure | Unit of measure |
| unitRate | Decimal(15,4) | NOT NULL | Unit rate |
| estimatedAmount | Decimal(15,2) | NOT NULL | Calculated: quantity × unitRate |
| currency_ID | UUID | FK → Currencies | Line currency |
| startDate | Date | | Planned start date |
| endDate | Date | | Planned end date |
| durationDays | Decimal(10,2) | | Duration in days |
| sourceType | String(20) | | Manual, Benchmark, Contract |

**Indexes**: `afe_ID`, `(afe_ID, lineNumber)`

---

#### 4.2.3 WBSElements

WBS hierarchy instances for AFEs.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| elementCode | String(24) | NOT NULL | WBS element code |
| elementName | String(100) | NOT NULL | Element description |
| parent_ID | UUID | FK → WBSElements | Parent element (hierarchical) |
| hierarchyLevel | Integer | NOT NULL | Level (1-5) |
| sortOrder | Integer | | Display sort order |
| s4WBSElement | String(24) | | S/4HANA WBS Element |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `(afe_ID, elementCode)` (unique), `parent_ID`

---

#### 4.2.4 CostEstimates

Cost estimation records linked to AFE.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| wbsElement_ID | UUID | FK → WBSElements | WBS element reference |
| costElement_ID | UUID | FK → CostElements | Cost element reference |
| vendor_ID | UUID | FK → Vendors | Vendor (optional) |
| description | String(200) | | Line item description |
| quantity | Decimal(15,4) | NOT NULL, > 0 | Estimated quantity |
| uom_ID | UUID | FK → UnitsOfMeasure | Unit of measure |
| unitRate | Decimal(15,4) | NOT NULL | Unit rate |
| estimatedAmount | Decimal(15,2) | NOT NULL | Total estimated amount |
| currency_ID | UUID | FK → Currencies | Estimate currency |
| startDate | Date | | Planned start date |
| endDate | Date | | Planned end date |
| durationDays | Decimal(10,2) | | Duration in days |
| sourceType | String(20) | | Manual, Benchmark, Contract |
| confidenceLevel | String(20) | | Low, Medium, High |

**Indexes**: `afe_ID`, `(afe_ID, costElement_ID)`

---

#### 4.2.5 CostActuals

Actual cost postings (synced from S/4HANA FI/CO).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| wbsElement_ID | UUID | FK → WBSElements | WBS element reference |
| costElement_ID | UUID | FK → CostElements | Cost element reference |
| vendor_ID | UUID | FK → Vendors | Vendor (optional) |
| postingDate | Date | NOT NULL | S/4HANA posting date |
| documentDate | Date | | Document date |
| quantity | Decimal(15,4) | | Quantity |
| uom_ID | UUID | FK → UnitsOfMeasure | Unit of measure |
| actualAmount | Decimal(15,2) | NOT NULL | Actual amount posted |
| currency_ID | UUID | FK → Currencies | Posting currency |
| s4DocumentNo | String(10) | | S/4HANA FI Document (BELNR) |
| s4PONumber | String(10) | | Purchase Order number |
| referenceText | String(100) | | Invoice/reference number |
| costType | String(20) | NOT NULL | Actual, Commitment, Accrual |

**System of Record**: Well Cost Management + S/4HANA
**Indexes**: `afe_ID`, `(afe_ID, postingDate)`, `s4DocumentNo`

---

#### 4.2.6 DailyReports

Daily drilling reports for real-time cost monitoring.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| well_ID | UUID | FK → Wells, NOT NULL | Well reference |
| afe_ID | UUID | FK → AFEs, NOT NULL | AFE reference |
| reportDate | Date | NOT NULL | Report date |
| dayNumber | Integer | NOT NULL | Days since spud |
| depthMD | Decimal(10,2) | | Current measured depth (m) |
| depthTVD | Decimal(10,2) | | Current true vertical depth (m) |
| footageDrilled | Decimal(10,2) | | Today's footage (m) |
| productiveHours | Decimal(5,2) | | Productive hours |
| nptHours | Decimal(5,2) | | Non-productive time hours |
| nptCategory | String(50) | | Weather, Equipment, Personnel |
| dailyCost | Decimal(15,2) | | Cost for today |
| cumulativeCost | Decimal(15,2) | | Cumulative cost to date |
| operationPhase | String(20) | | Drilling, Completion, Testing |
| remarks | String(1000) | | Daily remarks/notes |
| submittedBy | String(100) | | Report submitter |
| submittedAt | Timestamp | | Submission timestamp |

**Constraints**: `(well_ID, reportDate)` UNIQUE
**Indexes**: `(well_ID, reportDate)` (unique), `afe_ID`

---

#### 4.2.7 Approvals

AFE approval workflow tracking.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| approvalLevel | Integer | NOT NULL | Sequence (1, 2, 3...) |
| approverRole | String(50) | NOT NULL | Engineering, Finance, VP, etc. |
| approverUserId | String(100) | NOT NULL | Approver user ID |
| approverName | String(100) | | Approver display name |
| delegatedFrom | String(100) | | Original approver if delegated |
| assignedDate | Timestamp | NOT NULL | Assignment timestamp |
| dueDate | Timestamp | | Approval deadline |
| actionDate | Timestamp | | Action timestamp |
| actionStatus | String(20) | NOT NULL | Approved, Rejected, Returned, Pending |
| comments | String(1000) | | Approval comments |
| conditions | String(500) | | Approval conditions |

**Compliance**: SOX Section 404 audit trail, segregation of duties
**Indexes**: `afe_ID`, `(afe_ID, approvalLevel)`, `(approverUserId, actionStatus)`

---

#### 4.2.8 AFEDocuments

AFE attachment/document references.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| documentName | String(200) | NOT NULL | Document name |
| documentType | String(50) | | PDF, Excel, Image, etc. |
| documentCategory | String(50) | | Estimate, Approval, Supporting |
| fileSize | Integer | | File size in bytes |
| mimeType | String(100) | | MIME type |
| storageUrl | String(500) | | Object store URL |
| uploadedBy | String(100) | | Uploader user ID |
| uploadedAt | Timestamp | | Upload timestamp |

**Indexes**: `afe_ID`, `documentCategory`

---

### 4.3 Financial Entities

#### 4.3.1 Commitments

Purchase order commitments (synced from S/4HANA MM).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | Parent AFE |
| wbsElement_ID | UUID | FK → WBSElements | WBS element reference |
| costElement_ID | UUID | FK → CostElements | Cost element reference |
| vendor_ID | UUID | FK → Vendors | Vendor reference |
| s4PONumber | String(10) | NOT NULL | S/4HANA PO (EBELN) |
| s4POItem | String(5) | NOT NULL | S/4HANA PO Item (EBELP) |
| commitmentDate | Date | NOT NULL | Commitment date |
| commitmentAmount | Decimal(15,2) | NOT NULL | Original commitment |
| consumedAmount | Decimal(15,2) | DEFAULT 0 | Consumed amount |
| remainingAmount | Decimal(15,2) | | Remaining commitment |
| currency_ID | UUID | FK → Currencies | Commitment currency |
| status | String(20) | NOT NULL | Open, PartiallyConsumed, Closed |

**Constraints**: `(s4PONumber, s4POItem)` UNIQUE
**System of Record**: Well Cost Management + S/4HANA
**Indexes**: `afe_ID`, `(s4PONumber, s4POItem)` (unique), `status`

---

#### 4.3.2 PartnerInterests

JV working interest allocations.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| well_ID | UUID | FK → Wells, NOT NULL | Well reference |
| afe_ID | UUID | FK → AFEs | AFE (optional, for AFE-specific WI) |
| partner_ID | UUID | FK → Partners, NOT NULL | Partner reference |
| workingInterest | Decimal(8,4) | NOT NULL | WI% (e.g., 0.5000 = 50%) |
| netRevenueInterest | Decimal(8,4) | | NRI% |
| effectiveFromDate | Date | NOT NULL | Effective start date |
| effectiveToDate | Date | | Effective end date |
| consentStatus | String(20) | | Consent, Non-Consent, Pending |
| consentDate | Timestamp | | Consent timestamp |
| isOperator | Boolean | DEFAULT false | Operator flag |

**Constraint**: Sum of `workingInterest` per well must equal 1.0000 (100%)
**Indexes**: `(well_ID, partner_ID)`, `well_ID`, `partner_ID`

---

#### 4.3.3 JIBStatements

Joint Interest Billing statements.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| statementNumber | String(20) | UK, NOT NULL | Statement number |
| well_ID | UUID | FK → Wells, NOT NULL | Well reference |
| afe_ID | UUID | FK → AFEs | AFE reference |
| partner_ID | UUID | FK → Partners, NOT NULL | Partner reference |
| billingPeriodFrom | Date | NOT NULL | Billing period start |
| billingPeriodTo | Date | NOT NULL | Billing period end |
| workingInterest | Decimal(8,4) | NOT NULL | Applied WI% |
| grossAmount | Decimal(15,2) | NOT NULL | Total gross costs |
| partnerShare | Decimal(15,2) | NOT NULL | Partner's share |
| currency_ID | UUID | FK → Currencies | Statement currency |
| dueDate | Date | | Payment due date |
| status | String(20) | NOT NULL | Draft, Sent, Paid, Disputed |
| sentDate | Timestamp | | Date sent to partner |
| paidDate | Date | | Payment received date |

**Constraints**: `billingPeriodFrom < billingPeriodTo`
**Indexes**: `statementNumber` (unique), `(partner_ID, billingPeriodFrom)`, `status`

---

#### 4.3.4 Variances

Cost variance analysis records.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| afe_ID | UUID | FK → AFEs, NOT NULL | AFE reference |
| well_ID | UUID | FK → Wells | Well reference |
| wbsElement_ID | UUID | FK → WBSElements | WBS element |
| costElement_ID | UUID | FK → CostElements | Cost element |
| analysisDate | Date | NOT NULL | Analysis date |
| estimatedAmount | Decimal(15,2) | NOT NULL | Estimated cost |
| actualAmount | Decimal(15,2) | NOT NULL | Actual cost |
| varianceAmount | Decimal(15,2) | NOT NULL | Variance (actual - estimated) |
| variancePct | Decimal(8,4) | | Variance percentage |
| varianceCategory_ID | UUID | FK → VarianceCategories | Root cause category |
| explanation | String(500) | | Variance explanation |
| approvalRequired | Boolean | DEFAULT false | Requires approval if > 10% |
| approvedBy | String(100) | | Approving user |
| approvedAt | Timestamp | | Approval timestamp |

**Indexes**: `afe_ID`, `(well_ID, analysisDate)`, `varianceCategory_ID`

---

#### 4.3.5 VarianceCategories

Variance root cause categorization.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| categoryCode | String(20) | UK, NOT NULL | Category code |
| categoryName | String(100) | NOT NULL | Category name |
| categoryType | String(20) | | Favorable, Unfavorable |
| description | String(500) | | Category description |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `categoryCode` (unique)

---

### 4.4 Investment Economics Entities

#### 4.4.1 EconomicsAnalyses

Investment economics analysis header.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| analysisName | String(100) | NOT NULL | Analysis name |
| well_ID | UUID | FK → Wells | Well reference |
| afe_ID | UUID | FK → AFEs | AFE reference (optional) |
| analysisType | String(20) | NOT NULL | NEW_WELL, WORKOVER, ACQUISITION |
| discountRate | Decimal(8,4) | NOT NULL | Discount rate (e.g., 0.10 = 10%) |
| inflationRate | Decimal(8,4) | | Inflation rate |
| npv | Decimal(15,2) | | Calculated Net Present Value |
| irr | Decimal(8,4) | | Calculated Internal Rate of Return |
| mirr | Decimal(8,4) | | Modified IRR |
| paybackYears | Decimal(5,2) | | Simple payback period |
| discountedPayback | Decimal(5,2) | | Discounted payback period |
| profitabilityIndex | Decimal(8,4) | | PI (NPV / Investment) |
| recommendation | String(20) | | RECOMMEND, MARGINAL, DO_NOT_RECOMMEND |
| calculatedAt | Timestamp | | Calculation timestamp |
| status | String(20) | NOT NULL | Draft, Pending, Approved |
| createdBy | String(100) | | Created by user |
| createdAt | Timestamp | | Creation timestamp |

**Constraints**: `discountRate` between 0 and 0.50
**Indexes**: `well_ID`, `afe_ID`, `status`

---

#### 4.4.2 CashFlows

Year-by-year cash flow projections.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| analysis_ID | UUID | FK → EconomicsAnalyses, NOT NULL | Parent analysis |
| yearNumber | Integer | NOT NULL | Year (0, 1, 2, ... n) |
| capex | Decimal(15,2) | | Capital expenditure |
| opex | Decimal(15,2) | | Operating expenditure |
| revenue | Decimal(15,2) | | Revenue |
| royalty | Decimal(15,2) | | Royalty payments |
| taxes | Decimal(15,2) | | Tax payments |
| netCashFlow | Decimal(15,2) | | Net cash flow |
| discountedCashFlow | Decimal(15,2) | | Discounted cash flow |
| cumulativeCashFlow | Decimal(15,2) | | Cumulative cash flow |
| oilProduction | Decimal(15,2) | | Oil production (barrels) |
| gasProduction | Decimal(15,2) | | Gas production (MCF) |

**Indexes**: `analysis_ID`, `(analysis_ID, yearNumber)` (unique)

---

#### 4.4.3 HurdleRates

Investment hurdle rate configuration.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| rateType | String(20) | NOT NULL | CORPORATE, ASSET, PROJECT |
| field_ID | UUID | FK → Fields | Field (for asset-level rates) |
| rateName | String(50) | NOT NULL | Rate name |
| rateValue | Decimal(8,4) | NOT NULL | Hurdle rate value |
| riskPremium | Decimal(8,4) | | Risk premium |
| effectiveFromDate | Date | NOT NULL | Effective start date |
| effectiveToDate | Date | | Effective end date |
| approvedBy | String(100) | | Approving user |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `(rateType, field_ID)`, `effectiveFromDate`

---

#### 4.4.4 Scenarios

P10/P50/P90 scenario definitions.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| analysis_ID | UUID | FK → EconomicsAnalyses, NOT NULL | Parent analysis |
| scenarioType | String(20) | NOT NULL | P10, P50, P90, BASE |
| scenarioName | String(100) | | Scenario name |
| npv | Decimal(15,2) | | Scenario NPV |
| irr | Decimal(8,4) | | Scenario IRR |
| probability | Decimal(5,4) | | Probability weight |

**Indexes**: `analysis_ID`, `(analysis_ID, scenarioType)` (unique)

---

#### 4.4.5 SensitivityResults

Tornado chart sensitivity analysis data.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| analysis_ID | UUID | FK → EconomicsAnalyses, NOT NULL | Parent analysis |
| variableName | String(50) | NOT NULL | Variable name (Oil Price, CAPEX, etc.) |
| baseValue | Decimal(15,4) | | Base case value |
| lowValue | Decimal(15,4) | | Low case value |
| highValue | Decimal(15,4) | | High case value |
| npvLow | Decimal(15,2) | | NPV at low value |
| npvHigh | Decimal(15,2) | | NPV at high value |
| impactRange | Decimal(15,2) | | NPV impact range |
| sortOrder | Integer | | Display order (by impact) |

**Indexes**: `analysis_ID`

---

### 4.5 Integration Entities

#### 4.5.1 IntegrationLogs

Integration execution audit trail.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| integrationName | String(100) | NOT NULL | Integration name |
| sourceSystem | String(50) | NOT NULL | Source system |
| targetSystem | String(50) | NOT NULL | Target system |
| direction | String(20) | | Inbound, Outbound, Bidirectional |
| recordCount | Integer | | Total records processed |
| processingStartTime | Timestamp | NOT NULL | Start timestamp |
| processingEndTime | Timestamp | | End timestamp |
| status | String(20) | NOT NULL | Success, Failed, PartialSuccess |
| errorMessage | String(1000) | | Error details |
| recordsProcessed | Integer | | Successfully processed count |
| recordsFailed | Integer | | Failed record count |
| correlationId | UUID | | Tracing correlation ID |

**Indexes**: `integrationName`, `processingStartTime DESC`, `status`

---

#### 4.5.2 DataQualityRules

Data validation rule definitions.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| ruleName | String(100) | NOT NULL | Rule name |
| entityName | String(50) | NOT NULL | Target entity |
| fieldName | String(50) | | Target field |
| ruleType | String(20) | | Required, Range, Regex, Custom |
| ruleExpression | String(500) | | Validation expression |
| errorMessage | String(200) | | Error message |
| severity | String(20) | | Error, Warning, Info |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `(entityName, fieldName)`, `isActive`

---

#### 4.5.3 MappingConfigs

Field mapping configurations for integrations.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| mappingName | String(100) | NOT NULL | Mapping name |
| sourceSystem | String(50) | NOT NULL | Source system |
| targetSystem | String(50) | NOT NULL | Target system |
| sourceEntity | String(50) | NOT NULL | Source entity |
| targetEntity | String(50) | NOT NULL | Target entity |
| sourceField | String(50) | NOT NULL | Source field |
| targetField | String(50) | NOT NULL | Target field |
| transformationType | String(20) | | Direct, Lookup, Expression |
| transformationExpr | String(500) | | Transformation expression |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `(sourceSystem, sourceEntity)`, `(targetSystem, targetEntity)`

---

### 4.6 Security & Audit Entities

#### 4.6.1 AuditLogs

Comprehensive audit trail for compliance.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| eventCategory | String(50) | NOT NULL | Authentication, Authorization, DataChange, etc. |
| eventType | String(100) | NOT NULL | Specific event type |
| entityType | String(50) | | Entity type (AFE, CostActual, etc.) |
| entityId | UUID | | Entity ID |
| userId | String(100) | NOT NULL | User ID |
| userName | String(100) | | User display name |
| action | String(20) | NOT NULL | Create, Read, Update, Delete, Approve, Reject |
| beforeValue | Text | | JSON snapshot before change |
| afterValue | Text | | JSON snapshot after change |
| timestamp | Timestamp | NOT NULL | Event timestamp |
| ipAddress | String(45) | | Client IP address |
| sessionId | UUID | | Session ID |
| correlationId | UUID | | Request correlation ID |

**Retention**: 10 years for AFE transactions, 7 years for others
**Compliance**: SOX Section 404, GDPR, ISO 27001
**Indexes**: `(entityType, entityId)`, `timestamp DESC`, `userId`, `eventCategory`

---

#### 4.6.2 Users

System user profiles.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| userId | String(100) | UK, NOT NULL | User ID (from IdP) |
| userName | String(100) | NOT NULL | Display name |
| email | String(100) | NOT NULL | Email address |
| department | String(50) | | Department |
| title | String(50) | | Job title |
| manager_ID | UUID | FK → Users | Manager reference |
| status | String(20) | NOT NULL | Active, Inactive, Suspended |
| lastLoginAt | Timestamp | | Last login timestamp |
| createdAt | Timestamp | | Creation timestamp |

**Indexes**: `userId` (unique), `email`, `status`

---

#### 4.6.3 Roles

Role definitions.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| roleCode | String(50) | UK, NOT NULL | Role code |
| roleName | String(100) | NOT NULL | Role display name |
| roleType | String(20) | | Application, Business, Admin |
| description | String(500) | | Role description |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `roleCode` (unique)

---

#### 4.6.4 UserRoles

User-to-role assignments.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| user_ID | UUID | FK → Users, NOT NULL | User reference |
| role_ID | UUID | FK → Roles, NOT NULL | Role reference |
| scopeType | String(20) | | Global, Field, Well |
| scopeValue | String(50) | | Scope value (field code, well number) |
| effectiveFromDate | Date | NOT NULL | Assignment start date |
| effectiveToDate | Date | | Assignment end date |
| assignedBy | String(100) | | Assigned by user |
| assignedAt | Timestamp | | Assignment timestamp |

**Indexes**: `user_ID`, `role_ID`, `(user_ID, role_ID, scopeType, scopeValue)` (unique)

---

### 4.7 Configuration Entities

#### 4.7.1 ApprovalMatrix

Approval routing rules.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| matrixName | String(100) | NOT NULL | Matrix name |
| entityType | String(50) | NOT NULL | AFE, Variance, etc. |
| field_ID | UUID | FK → Fields | Field (optional) |
| wellType | String(20) | | Well type filter |
| amountFrom | Decimal(15,2) | | Amount range start |
| amountTo | Decimal(15,2) | | Amount range end |
| approvalLevel | Integer | NOT NULL | Approval level |
| approverRole | String(50) | NOT NULL | Required approver role |
| escalationDays | Integer | | Days before escalation |
| isActive | Boolean | DEFAULT true | Active flag |

**Indexes**: `(entityType, field_ID, amountFrom, amountTo)`

---

#### 4.7.2 SystemConfigurations

Global system settings.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| configKey | String(100) | UK, NOT NULL | Configuration key |
| configValue | String(1000) | | Configuration value |
| configType | String(20) | | String, Number, Boolean, JSON |
| description | String(500) | | Setting description |
| modifiedBy | String(100) | | Last modified by |
| modifiedAt | Timestamp | | Last modification timestamp |

**Indexes**: `configKey` (unique)

---

#### 4.7.3 UserPreferences

User-specific settings.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ID | UUID | PK | Primary key |
| user_ID | UUID | FK → Users, NOT NULL | User reference |
| preferenceKey | String(100) | NOT NULL | Preference key |
| preferenceValue | String(1000) | | Preference value |
| modifiedAt | Timestamp | | Last modification timestamp |

**Indexes**: `(user_ID, preferenceKey)` (unique)

---

## 5. S/4HANA Integration Mappings

### 5.1 Master Data Mappings

| WCM Entity | S/4HANA Table | API | Direction |
|------------|---------------|-----|-----------|
| Vendors | BUT000 / LFA1 | API_BUSINESS_PARTNER | Inbound |
| CostElements | CSKA / CSKB | API_COSTCENTER_SRV | Inbound |
| Countries | T005 | OData | Inbound |
| Currencies | TCURC | OData | Inbound |
| UnitsOfMeasure | T006 | OData | Inbound |
| WBSTemplates | PRPS | API_PROJECT_SRV | Bidirectional |

### 5.2 Transactional Mappings

| WCM Entity | S/4HANA Table | API | Direction | Purpose |
|------------|---------------|-----|-----------|---------|
| AFE (Budget) | FMPS / BPBK | API_PROJECT_SRV | Outbound | Budget reservation |
| AFE (WBS) | PRPS | API_PROJECT_SRV | Outbound | WBS element creation |
| CostActuals | BKPF / BSEG | API_JOURNALENTRY | Inbound | Cost posting |
| Commitments | EKKO / EKPO | API_PURCHASEORDER | Inbound | PO tracking |
| JIBStatements | BKPF / BSEG | API_JOURNALENTRY | Outbound | Partner billing |

### 5.3 Key Field Mappings

| WCM Field | S/4HANA Field | S/4HANA Table | Notes |
|-----------|---------------|---------------|-------|
| Vendor.s4VendorNo | LIFNR | LFA1 | 10-char vendor number |
| AFE.s4ProjectNo | PSPNR | PROJ | Internal project number |
| AFE.s4WBSElement | POSID | PRPS | 24-char WBS element |
| CostElement.s4GLAccount | SAKNR | SKA1 | 10-char GL account |
| CostActual.s4DocumentNo | BELNR | BKPF | 10-char FI document |
| Commitment.s4PONumber | EBELN | EKKO | 10-char PO number |
| Field.s4ProfitCenter | PRCTR | CEPC | 10-char profit center |
| Field.s4CostCenter | KOSTL | CSKS | 10-char cost center |

### 5.4 Communication Scenarios (S/4HANA Cloud)

| Scenario ID | Description | WCM Usage | Direction |
|-------------|-------------|-----------|-----------|
| SAP_COM_0008 | Business Partner | Vendor/Partner sync | Inbound |
| SAP_COM_0028 | Journal Entry | Cost posting | Outbound |
| SAP_COM_0053 | Purchase Contract | Contract data | Inbound |
| SAP_COM_0164 | Purchase Order | PO creation | Outbound |
| SAP_COM_0367 | Goods Receipt | GR posting | Inbound |
| SAP_COM_0073 | Cost Center | Cost center sync | Inbound |
| SAP_COM_0332 | WBS Element | WBS creation | Outbound |

---

## 6. Indexes and Performance

### 6.1 Primary Indexes

```sql
-- Well lookups
CREATE INDEX idx_well_number ON Wells(wellNumber);
CREATE INDEX idx_well_field ON Wells(field_ID, status);
CREATE INDEX idx_well_status ON Wells(status, isActive);

-- AFE lookups
CREATE INDEX idx_afe_number ON AFEs(afeNumber);
CREATE INDEX idx_afe_well ON AFEs(well_ID, approvalStatus);
CREATE INDEX idx_afe_date ON AFEs(createdAt DESC);
CREATE INDEX idx_afe_status ON AFEs(approvalStatus, status);

-- Cost tracking
CREATE INDEX idx_estimate_afe ON CostEstimates(afe_ID);
CREATE INDEX idx_estimate_element ON CostEstimates(afe_ID, costElement_ID);
CREATE INDEX idx_actual_afe_date ON CostActuals(afe_ID, postingDate);
CREATE INDEX idx_actual_document ON CostActuals(s4DocumentNo);
CREATE INDEX idx_daily_well_date ON DailyReports(well_ID, reportDate);

-- Approvals
CREATE INDEX idx_approval_afe ON Approvals(afe_ID, actionStatus);
CREATE INDEX idx_approval_user ON Approvals(approverUserId, dueDate);
CREATE INDEX idx_approval_pending ON Approvals(actionStatus, dueDate)
    WHERE actionStatus = 'Pending';

-- Financial
CREATE INDEX idx_commitment_afe ON Commitments(afe_ID, status);
CREATE INDEX idx_commitment_po ON Commitments(s4PONumber, s4POItem);
CREATE INDEX idx_jib_period ON JIBStatements(billingPeriodFrom, partner_ID);
CREATE INDEX idx_jib_partner ON JIBStatements(partner_ID, status);
CREATE INDEX idx_partner_interest_well ON PartnerInterests(well_ID, partner_ID);

-- Analytics
CREATE INDEX idx_variance_well ON Variances(well_ID, analysisDate);
CREATE INDEX idx_variance_afe ON Variances(afe_ID, varianceCategory_ID);
CREATE INDEX idx_audit_entity ON AuditLogs(entityType, entityId, timestamp);
CREATE INDEX idx_audit_user ON AuditLogs(userId, timestamp DESC);
CREATE INDEX idx_audit_time ON AuditLogs(timestamp DESC);

-- Economics
CREATE INDEX idx_economics_well ON EconomicsAnalyses(well_ID, status);
CREATE INDEX idx_cashflow_analysis ON CashFlows(analysis_ID, yearNumber);
```

### 6.2 Performance SLAs

| Metric | Target |
|--------|--------|
| API Response Time (P95) | < 2 seconds |
| Page Load Time | < 3 seconds |
| S/4HANA Integration Latency | < 1 second |
| Batch Processing | > 1000 records/minute |
| NPV/IRR Calculation | < 2 seconds |
| Monte Carlo (10K iterations) | < 30 seconds |

### 6.3 Availability

| Metric | Target |
|--------|--------|
| System Uptime | 99.5% SLA |
| Planned Maintenance | < 4 hours/month |
| RTO (Recovery Time Objective) | 4 hours |
| RPO (Recovery Point Objective) | 1 hour |

---

## 7. Data Validation Rules

### 7.1 Master Data Validation

| Rule ID | Entity | Field | Rule | Severity |
|---------|--------|-------|------|----------|
| WCM-MD-001 | Well | wellNumber | Must be unique | Error |
| WCM-MD-002 | Well | wellType | Must be in: Exploration, Development, Workover, Sidetrack | Error |
| WCM-MD-003 | Field | fieldCode | Must be unique | Error |
| WCM-MD-004 | Vendor | vendorCode | Must be unique | Error |
| WCM-MD-005 | Partner | partnerCode | Must be unique | Error |
| WCM-MD-006 | CostCategory | categoryCode | Must be unique | Error |
| WCM-MD-007 | CostElement | elementCode | Must be unique | Error |

### 7.2 AFE Validation

| Rule ID | Entity | Field | Rule | Severity |
|---------|--------|-------|------|----------|
| WCM-AFE-001 | AFE | afeNumber | Must be unique | Error |
| WCM-AFE-002 | AFE | validFromDate/validToDate | validFrom < validTo | Error |
| WCM-AFE-003 | AFE | parentAFE_ID | Required if afeType = 'Supplement' | Error |
| WCM-AFE-004 | AFE | estimatedCost | Must be > 0 | Error |
| WCM-AFE-005 | AFE | contingencyPct | Must be between 0 and 50 | Warning |
| WCM-AFE-006 | AFELineItem | quantity | Must be > 0 | Error |

### 7.3 Financial Validation

| Rule ID | Entity | Field | Rule | Severity |
|---------|--------|-------|------|----------|
| WCM-FIN-001 | CostEstimate | quantity | Must be > 0 | Error |
| WCM-FIN-002 | CostActual | actualAmount | Must not be 0 | Error |
| WCM-FIN-003 | PartnerInterest | workingInterest | Sum per well = 100% | Error |
| WCM-FIN-004 | JIBStatement | billingPeriod | From < To | Error |
| WCM-FIN-005 | Variance | variancePct | > 10% requires approval | Warning |

### 7.4 Economics Validation

| Rule ID | Entity | Field | Rule | Severity |
|---------|--------|-------|------|----------|
| WCM-ECO-001 | EconomicsAnalysis | discountRate | Must be between 0 and 50% | Error |
| WCM-ECO-002 | HurdleRate | rateValue | Must be between 0 and 50% | Error |
| WCM-ECO-003 | CashFlow | yearNumber | Must be >= 0 | Error |

---

## 8. Data Volume Projections

### 8.1 Annual Growth Estimates

| Entity | Annual Records | Peak Month | Peak Daily | 5-Year Total |
|--------|----------------|------------|------------|--------------|
| AFEs | 5,000 | 500 | 50 | 25,000 |
| AFELineItems | 100,000 | 20,000 | 1,000 | 500,000 |
| CostEstimates | 50,000 | 10,000 | 500 | 250,000 |
| CostActuals | 200,000 | 50,000 | 2,000 | 1,000,000 |
| DailyReports | 100,000 | 20,000 | 1,000 | 500,000 |
| Approvals | 50,000 | 10,000 | 500 | 250,000 |
| Commitments | 100,000 | 20,000 | 1,000 | 500,000 |
| CashFlows | 100,000 | 20,000 | 1,000 | 500,000 |
| PartnerInterests | 5,000 | 1,000 | 100 | 25,000 |
| JIBStatements | 20,000 | 5,000 | 250 | 100,000 |
| AuditLogs | 1,000,000 | 250,000 | 10,000 | 5,000,000 |
| IntegrationLogs | 50,000 | 10,000 | 500 | 250,000 |

### 8.2 Storage Estimates

| Category | Records (5-Year) | Avg Size | Total Storage |
|----------|------------------|----------|---------------|
| Master Data | 25,000 | 2 KB | 50 MB |
| Transactional | 2,500,000 | 1 KB | 2.5 GB |
| Financial | 625,000 | 1 KB | 625 MB |
| Economics | 600,000 | 0.5 KB | 300 MB |
| Audit Logs | 5,000,000 | 2 KB | 10 GB |
| **Total** | **8,750,000** | | **~15 GB** |

### 8.3 Data Retention Policy

| Data Category | Retention Period | Archive Policy |
|---------------|------------------|----------------|
| AFE Records | 10 years | Move to archive after 5 years |
| Cost Actuals | 10 years | Move to archive after 5 years |
| Audit Logs (AFE) | 10 years | SOX compliance |
| Audit Logs (Other) | 7 years | Standard retention |
| Integration Logs | 1 year | Purge after 1 year |
| Daily Reports | 10 years | Archive after 3 years |

---

## Appendix A: CAP CDS Schema Example

```cds
namespace wcm;

using { cuid, managed } from '@sap/cds/common';

entity Wells : cuid, managed {
    wellNumber      : String(20) not null @mandatory;
    wellName        : String(100) not null;
    wellType        : String(20) not null;
    field           : Association to Fields;
    spudDate        : Date;
    totalDepthMD    : Decimal(10,2);
    totalDepthTVD   : Decimal(10,2);
    wellboreType    : String(20);
    surfaceLatitude : Decimal(10,6);
    surfaceLongitude: Decimal(10,6);
    s4WBSElement    : String(24);
    status          : String(20) not null default 'Planned';
    isActive        : Boolean default true;

    // Associations
    afes            : Association to many AFEs on afes.well = $self;
    partnerInterests: Association to many PartnerInterests on partnerInterests.well = $self;
}

entity AFEs : cuid, managed {
    afeNumber       : String(20) not null @mandatory;
    afeName         : String(100) not null;
    afeType         : String(20) not null;
    well            : Association to Wells not null;
    estimatedCost   : Decimal(15,2) not null;
    currency        : Association to Currencies;
    contingencyAmount: Decimal(15,2);
    contingencyPct  : Decimal(5,2);
    validFromDate   : Date not null;
    validToDate     : Date not null;
    parentAFE       : Association to AFEs;
    versionNumber   : Integer default 1;
    approvalStatus  : String(20) not null default 'Draft';
    approvedDate    : Timestamp;
    approvedBy      : String(100);
    s4ProjectNo     : String(24);
    s4WBSElement    : String(24);
    status          : String(20) not null default 'Active';

    // Associations
    lineItems       : Composition of many AFELineItems on lineItems.afe = $self;
    approvals       : Composition of many Approvals on approvals.afe = $self;
    costEstimates   : Association to many CostEstimates on costEstimates.afe = $self;
    costActuals     : Association to many CostActuals on costActuals.afe = $self;
}
```

---

## Appendix B: Database Diagram Legend

```
┌─────────────────────────────────────────────┐
│  LEGEND                                      │
├─────────────────────────────────────────────┤
│  PK    = Primary Key                         │
│  FK    = Foreign Key                         │
│  UK    = Unique Key                          │
│  NOT NULL = Required field                   │
│                                              │
│  Relationship Notation:                      │
│  ───1:M───>  One-to-Many                    │
│  ───M:1───>  Many-to-One                    │
│  ───M:M───>  Many-to-Many                   │
│  ───1:1───>  One-to-One                     │
│                                              │
│  Data Types:                                 │
│  UUID       = Universally Unique Identifier  │
│  String(n)  = Variable length string, max n  │
│  Integer    = Whole number                   │
│  Decimal(p,s) = Decimal with precision p,    │
│               scale s                        │
│  Date       = Date only (no time)            │
│  Timestamp  = Date and time with timezone    │
│  Boolean    = True/False                     │
│  Text       = Large text field               │
└─────────────────────────────────────────────┘
```

---

*Document Version: 1.0*
*Last Updated: January 2026*
*Author: Well Cost Management Team*
