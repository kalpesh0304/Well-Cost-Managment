---
title: "WCM-HLD-003_AFE_Lifecycle_Management_v1_0"
category: "functional"
type: "Functional Document"
created_date: "2026-01-28"
source_file: "WCM-HLD-003_AFE_Lifecycle_Management_v1_0.docx"
---



> **Document Type**: Functional Document
>
> This document describes the functional requirements, features, and user stories.

---


**Well Cost Management**

Oil & Gas Drilling Cost Lifecycle Management Solution

**AFE Lifecycle Management Module**

High-Level Design Document

Document ID: WCM-HLD-003

Version 1.0

Prepared by:

**Well Cost Management Development Team**

*SAP Business Technology Platform*

# Table of Contents

# 1. Document Semantics

## 1.1. Document Properties

**Owner and Contact Information**



| Property | Value |
| --- | --- |
| Document ID | WCM-HLD-003 |
| Document Title | Well Cost Management AFE Lifecycle Management Module - High-Level Design |
| Document Prepared by | Solution Architect (AI-Assisted) |
| Business Process Owner | [AFE Operations Manager] |
| Contact Information | [Contact Email] |
| Responsible Team | WCM Development Team - @afe-manager Agent |
| Reviewer | [Solution Architect / Business Analyst] |
| Approver | [Project Sponsor] |



## 1.2. Amendment History



| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 1.0 | January 2025 | Solution Architect | Initial document creation |



## 1.3. Related Documents



| Document ID | Document Title | Version |
| --- | --- | --- |
| IBU-ARCH-001 | Well Cost Management Solution Architecture Specification | 1.0 |
| PFD-WCM-2025-001 | Product Feature Document - Well Cost Management | 1.0 |
| FSD-WCM-BC-001 | Functional Specification - Investment Economics Engine | 1.0 |
| WCM-RACI-001 | Well Cost Management RACI Matrix | 1.0 |
| WCM-ONBOARD-001 | Agent Onboarding Plan | 1.0 |
| WCM-HLD-001 | Business Case Management Module HLD | 1.0 |
| WCM-HLD-002 | Cost Estimation Module HLD | 1.0 |



# 2. Executive Summary

## 2.1. Purpose

This High-Level Design (HLD) document defines the functional and technical design for the Well Cost Management AFE Lifecycle Management module (WCM-03). It serves as the primary reference for development, testing, and deployment of Authorization for Expenditure (AFE) management capabilities within the Well Cost Management solution.

The document provides comprehensive specifications for:

- AFE document creation, numbering, and version control

- Multi-level approval workflow orchestration

- Supplement processing and revision tracking

- Partner notification and consent management

- S/4HANA integration for budget reservation and WBS element creation

- Mobile approval support for field operations

## 2.2. Solution Overview

The AFE Lifecycle Management module enables oil and gas operations teams to manage the complete AFE process from initial document creation through approval, execution, and closeout. The module serves as the central control point for well investment authorization, ensuring proper governance, partner consent, and financial controls throughout the well drilling lifecycle.

The @afe-manager agent is Accountable for 5 core processes and integrates closely with the @cost-estimator agent (for estimate data), @workflow-agent (for approval orchestration), @partner-jib agent (for joint venture operations), and @s4-integrator agent (for SAP S/4HANA budget and WBS integration).

This module implements SAP Clean Core principles, maintaining all extensions on SAP BTP while leveraging stable S/4HANA APIs for Project System (PS) integration.

## 2.3. Key Features



| Feature | Description |
| --- | --- |
| AFE Document Generator | One-click generation of AFE documents from cost estimates with configurable company templates |
| AFE Numbering | Automatic sequential AFE numbering with configurable prefixes by asset/region |
| Supplement Processing | Create AFE supplements/revisions with automatic variance calculation from original |
| Version History | Complete audit trail of all AFE versions with comparison view and change highlighting |
| Approval Workflow | Configurable multi-level approval routing with parallel/sequential approval paths |
| Partner Distribution | Automated distribution to JV partners based on working interest percentages |
| Mobile Approval | Native iOS/Android apps for reviewing and approving AFEs on the go |
| S/4HANA Integration | Budget reservation and WBS element creation in SAP Project System upon approval |



## 2.4. Business Benefits

- Reduced AFE cycle time through automated workflow and mobile approvals

- Improved accuracy with integrated cost estimate data and automatic calculations

- Enhanced governance with complete audit trails and SOX-compliant controls

- Streamlined partner operations with automated consent tracking

- Real-time visibility into AFE status across the portfolio

- Reduced manual data entry through S/4HANA integration

# 3. Functional Specification Review

## 3.1. Overview

The AFE Lifecycle Management module manages the complete Authorization for Expenditure process within the Well Cost Management solution. An AFE is the formal document that authorizes capital expenditure for well drilling, completion, or workover operations. The module serves as the bridge between technical well planning (cost estimation) and financial execution (budget commitment in S/4HANA).

## 3.2. Business Owners and Key Users



| Role | Department | Responsibilities |
| --- | --- | --- |
| Drilling Manager | Operations | AFE initiation, cost estimate validation, operational approval |
| AFE Coordinator | Finance | AFE document management, workflow monitoring, partner coordination |
| Asset Manager | Asset Management | Investment approval, portfolio prioritization, final authorization |
| Finance Controller | Finance | Budget validation, cost center assignment, financial approval |
| JV Partner Representative | External Partners | Partner consent, non-consent elections, audit review |



## 3.3. Background / Context

Oil and gas operators face unique challenges in AFE management that differ from standard capital approval processes:

- Joint venture operations require partner consent with defined response timeframes

- AFE amounts may change significantly during drilling due to operational conditions

- Supplements (revisions) must track variance from original authorization

- Approval hierarchies vary by AFE amount, well type, and organizational structure

- Regulatory requirements mandate detailed cost breakdowns by WBS category

- Historical AFE data is critical for future cost estimation and benchmarking

The Well Cost Management AFE module addresses these challenges through a comprehensive digital workflow integrated with SAP S/4HANA Project System.

## 3.4. Scope Description

### 3.4.1. In Scope

- AFE document creation with cost estimate integration (AFE-F001)

- Automatic AFE numbering with configurable prefixes (AFE-F002)

- Supplement/revision processing with variance tracking (AFE-F003)

- Version history and audit trail (AFE-F004)

- Document attachments (maps, designs, quotes) (AFE-F005)

- PDF export with digital signatures (AFE-F006)

- Configurable approval matrix (AFE-F007)

- Multi-level approval routing (AFE-F008)

- Delegation management (AFE-F009)

- Deadline management with escalation (AFE-F010)

- Mobile approval support (AFE-F011)

- Approval comments and conditions (AFE-F012)

- Partner AFE distribution (AFE-F013)

- Partner consent tracking (AFE-F014)

- Budget reservation in S/4HANA (AFE-F017)

- WBS element creation in S/4HANA (AFE-F018)

### 3.4.2. Out of Scope (Release 1.0)

- Non-consent penalty/premium calculations (AFE-F015 - Phase 4)

- Partner self-service portal (AFE-F016 - Phase 4)

- Automated AFE generation from drilling program (future enhancement)

- AI-powered approval recommendations (future enhancement)

## 3.5. Business Units Impacted



| Business Unit | Impact |
| --- | --- |
| Drilling Operations | Primary users for AFE creation, supplement requests, and operational approvals |
| Finance | Budget commitment, cost center management, financial approvals |
| Asset Management | Investment authorization, portfolio optimization, strategic decisions |
| Joint Venture Partners | Consent management, working interest calculations, audit support |
| IT | S/4HANA integration, workflow configuration, user management |



## 3.6. Data Entities



| Entity | System of Record | Volume/Year | Description |
| --- | --- | --- | --- |
| AFEDocuments | Well Cost Mgmt | ~5,000 | Core AFE header records |
| AFELineItems | Well Cost Mgmt | ~100,000 | WBS cost breakdown items |
| AFEVersions | Well Cost Mgmt | ~15,000 | Version history (original + supplements) |
| AFEApprovals | Well Cost Mgmt | ~25,000 | Approval workflow records |
| PartnerConsents | Well Cost Mgmt | ~20,000 | JV partner consent records |
| ProjectDefinitions | S/4HANA | ~5,000 | PS project headers |
| WBSElements | S/4HANA | ~100,000 | Project WBS structure |



## 3.7. Legal Requirements

- SOX Section 404: Financial controls for AFE authorization require segregation of duties, approval workflows, and complete audit trails

- JOA Compliance: Joint Operating Agreement terms governing partner consent timeframes and notification requirements

- SEC Reporting: AFE data supports capital expenditure disclosures in regulatory filings

- Data Retention: 7-year retention for all AFE documents and approval records

## 3.8. Volume of Data



| Metric | Volume | Peak Period |
| --- | --- | --- |
| New AFEs per Month | ~400-500 | Q1, Q4 (budget cycles) |
| Supplements per Month | ~200-300 | Mid-year operations |
| Approval Decisions per Day | ~100-150 | Month-end close |
| Concurrent Approvers | 50-100 | Business hours |
| Mobile Approvals per Day | ~50-75 | Field operations |



## 3.9. Business Controls



| Control ID | Control Description | Control Type |
| --- | --- | --- |
| BC-AFE-001 | AFE amount must match approved cost estimate total | Preventive |
| BC-AFE-002 | Approval routing must follow configured approval matrix | Preventive |
| BC-AFE-003 | Supplement variance from original requires additional approval level | Preventive |
| BC-AFE-004 | Partner notification must occur within JOA-defined timeframes | Preventive |
| BC-AFE-005 | Budget reservation requires valid cost center and WBS element | Preventive |
| BC-AFE-006 | All status changes logged with timestamp and user ID | Detective |
| BC-AFE-007 | AFE cannot be modified after final approval without supplement | Preventive |



## 3.10. Security

Security is implemented through SAP BTP XSUAA with role-based access control. Key security aspects:

- Role-based access control with asset-level data segregation

- Approval actions require authenticated user context

- Digital signatures captured and stored securely in SAP Object Store

- All API calls authenticated via OAuth 2.0

- Partner access restricted to their working interest data only

Refer to IBU-ARCH-001 Security Architecture section for detailed security design.

## 3.11. Error Handling / Recovery / Restart



| Error Code | Description | Recovery Action |
| --- | --- | --- |
| AFE401 | Cost estimate not approved - cannot create AFE | Approve cost estimate first |
| AFE402 | Invalid approval matrix configuration | Contact system administrator |
| AFE403 | Partner working interests do not sum to 100% | Correct partner data in master |
| AFE404 | S/4HANA budget reservation failed | Retry via exception queue |
| AFE405 | S/4HANA WBS creation failed | Check PS configuration in S/4 |
| AFE406 | Duplicate AFE number detected | System regenerates number |
| AFE407 | Approval deadline exceeded | Escalate to next level |



## 3.12. Assumptions

- Cost estimates are created and approved in the Cost Estimation module before AFE creation

- Approval matrix is configured by system administrators before go-live

- Partner working interests are maintained in the Master Data module

- S/4HANA Project System is configured with standard project profiles and WBS templates

- Mobile approvers have network connectivity (offline sync not in scope for v1.0)

- Digital signature capture requires device with touch/stylus capability

# 4. Functional Solution

## 4.1. Overview

The AFE Lifecycle Management module provides a unified interface for managing well investment authorization. The solution implements a hybrid workflow where Well Cost Management handles AFE document management and approval orchestration while SAP S/4HANA serves as the system of record for budget commitments and project structures.

Solution Components:

- AFE Overview - List Report for managing all AFE documents

- AFE Detail - Object Page for viewing/editing individual AFEs

- Create AFE - AFE creation with cost estimate integration

- AFE Approval Inbox - Workflow task management

- Partner Consent Dashboard - JV partner tracking

- S/4HANA Integration Layer - Budget and WBS APIs

AFE ID Generation Logic:



| Field | Format | Example |
| --- | --- | --- |
| AFE Number | AFE-{ASSET}-{YYYY}-{SEQ} | AFE-PERM-2025-001 |
| Supplement Number | AFE-{ASSET}-{YYYY}-{SEQ}-S{N} | AFE-PERM-2025-001-S1 |
| Version ID | {AFENO}-V{N} | AFE-PERM-2025-001-V3 |



## 4.2. AFE Lifecycle

AFE documents follow a defined state machine with controlled transitions:



| Status | Description | Allowed Transitions |
| --- | --- | --- |
| Draft | AFE created but not submitted for approval | Submitted, Cancelled |
| Submitted | AFE submitted for internal approval | InApproval, Cancelled |
| InApproval | AFE in approval workflow | Approved, Rejected, Cancelled |
| PendingPartner | Awaiting JV partner consent | Approved, PartialConsent |
| Approved | Fully approved, budget committed | InExecution, Closed |
| InExecution | Well drilling/operations in progress | Closed, Supplement |
| Closed | Well complete, AFE closed out | Terminal state |
| Rejected | AFE rejected during approval | Draft (resubmit) |
| Cancelled | AFE cancelled | Terminal state |



## 4.3. Approval Workflow

The approval workflow supports complex routing scenarios:

- AFE Coordinator submits AFE for approval

- System determines approval path based on configured matrix (amount, type, asset)

- Sequential or parallel approvers are notified via email and mobile push

- Approvers review AFE details and attachments

- Approver takes action: Approve, Reject, or Request Changes (with comments)

- If deadline exceeded, automatic escalation to next approver or manager

- Upon final approval, system creates budget reservation and WBS in S/4HANA

- AFE status transitions to Approved (or PendingPartner if JV)

## 4.4. Business Rules



| Rule ID | Rule Description | Error Code |
| --- | --- | --- |
| BR-AFE-001 | AFE total must equal sum of all line items | AFE408 |
| BR-AFE-002 | Cost estimate must be approved before AFE submission | AFE401 |
| BR-AFE-003 | Supplement variance > 10% requires additional VP approval | AFE409 |
| BR-AFE-004 | Partner consent timeout defaults to 30 days per JOA | AFE410 |
| BR-AFE-005 | Approved AFE cannot be edited (supplement required) | AFE411 |
| BR-AFE-006 | Delegation requires valid date range and approver absence | AFE412 |
| BR-AFE-007 | WBS structure must match approved cost estimate hierarchy | AFE413 |



## 4.5. Impact of Change

AFE changes impact the following downstream processes:

- AFE Approval: Triggers budget reservation in S/4HANA PS, creates WBS elements

- Supplement Creation: Updates budget commitment, requires re-approval

- AFE Cancellation: May require budget reversal if already committed

- Partner Consent: Affects working interest allocation and JIB calculations

- Status Changes: Published to Event Mesh for downstream consumer notifications

# 5. Data Model

## 5.1. Entity Overview

The AFE Lifecycle Management module manages 5 core entities with associations to Master Data and S/4HANA entities:



| Entity | System of Record | Volume/Year | Description |
| --- | --- | --- | --- |
| AFEDocuments | Well Cost Mgmt | ~5,000 | Core AFE header |
| AFELineItems | Well Cost Mgmt | ~100,000 | WBS cost items |
| AFEApprovals | Well Cost Mgmt | ~25,000 | Approval records |
| PartnerConsents | Well Cost Mgmt | ~20,000 | JV consent records |
| AFEAttachments | Well Cost Mgmt | ~50,000 | Document files |



## 5.2. AFEDocuments Entity



| Field | Type | Req | Key | Description |
| --- | --- | --- | --- | --- |
| ID | UUID | Yes | PK | System-generated UUID |
| afeNumber | String(20) | Yes | UK | AFE document number |
| well | Association | Yes | FK | Link to Wells master |
| asset | Association | Yes | FK | Link to Assets |
| costEstimate | Association | Yes | FK | Link to CostEstimates |
| afeType | String(20) | Yes | - | Original, Supplement |
| wellType | String(20) | Yes | - | Exploration, Development, Workover |
| totalAmount | Decimal(15,2) | Yes | - | Total AFE amount |
| currency | String(3) | Yes | - | ISO currency code |
| status | String(20) | Yes | - | AFE status |
| s4ProjectNo | String(24) | No | - | S/4HANA Project number |
| s4WBSElement | String(24) | No | - | S/4HANA WBS element |



## 5.3. AFEApprovals Entity



| Field | Type | Req | Description |
| --- | --- | --- | --- |
| ID | UUID | Yes | System-generated UUID |
| afeDocument | Association | Yes | Link to AFEDocuments |
| approver | Association | Yes | Link to Users |
| approvalLevel | Integer | Yes | Approval sequence level |
| decision | String(20) | No | Approved, Rejected, Pending |
| decisionDate | Timestamp | No | Decision timestamp |
| comments | String(1000) | No | Approver comments |
| deadline | Date | Yes | Approval deadline |
| delegatedTo | Association | No | Delegation target user |



## 5.4. S/4HANA Field Mapping



| WCM Field | S/4HANA Field | Table | Notes |
| --- | --- | --- | --- |
| well.s4ProjectNo | PSPNR | PROJ | Project Definition |
| afeNumber | POST1 | PROJ | Project description |
| s4WBSElement | POSID | PRPS | WBS Element ID |
| totalAmount | WTGES | PRPS | Total plan costs |
| currency | WAERS | PRPS | Currency |
| asset.s4CompanyCode | BUKRS | PROJ | Company Code |
| costCenter | KOSTL | PRPS | Responsible cost center |



# 6. Integration Specifications

## 6.1. Integration Overview

The AFE Lifecycle Management module integrates with multiple systems through SAP Integration Suite (CPI):



| System | Purpose | Protocol | Direction |
| --- | --- | --- | --- |
| S/4HANA | Budget reservation, WBS creation | OData V2/V4 | Outbound |
| SAP Build Process Automation | Approval workflow orchestration | REST API | Bidirectional |
| SAP Event Mesh | Event publishing | AMQP | Outbound |
| SAP Document Management | Attachment storage | REST API | Bidirectional |
| Email/Mobile | Approval notifications | SMTP/Push | Outbound |



## 6.2. S/4HANA APIs

### 6.2.1. Project Definition Creation



| Property | Value |
| --- | --- |
| API | API_PROJECT_V2 |
| Method | POST |
| Entity | A_Project |
| Trigger | AFE final approval |
| Authentication | OAuth2ClientCredentials |



### 6.2.2. WBS Element Creation



| Property | Value |
| --- | --- |
| API | API_PROJECT_V2 |
| Method | POST |
| Entity | A_WBSElement |
| Trigger | After Project creation |
| Authentication | OAuth2ClientCredentials |



## 6.3. Event Schema

Events published to SAP Event Mesh for downstream consumers:



| Event | Topic Pattern |
| --- | --- |
| AFE Created | sap/wellcost/prod/afe/{afeID}/created |
| AFE Submitted | sap/wellcost/prod/afe/{afeID}/submitted |
| AFE Approved | sap/wellcost/prod/afe/{afeID}/approved |
| AFE Rejected | sap/wellcost/prod/afe/{afeID}/rejected |
| Partner Consent Received | sap/wellcost/prod/afe/{afeID}/partnerconsent |
| S/4 Project Created | sap/wellcost/prod/afe/{afeID}/projectcreated |



# 7. User Interface Specifications

## 7.1. Screen Inventory



| Screen ID | Screen Name | Floorplan | Priority |
| --- | --- | --- | --- |
| AFE-001 | AFE Overview | List Report | P1 |
| AFE-002 | AFE Detail (Display) | Object Page | P1 |
| AFE-003 | Create AFE | Object Page | P1 |
| AFE-004 | AFE Edit | Object Page | P1 |
| AFE-005 | Approval Inbox | List Report + Object Page | P1 |
| AFE-006 | Partner Consent Dashboard | Overview Page | P2 |
| AFE-007 | AFE Status Dashboard | Overview Page | P1 |



## 7.2. AFE Overview (AFE-001)

Floorplan: List Report

Purpose: Central dashboard for viewing and managing all AFE documents with filtering, search, and navigation capabilities.

### 7.2.1. Filter Fields



| Field | Control Type | Default | Validation |
| --- | --- | --- | --- |
| Asset | Multi-Select ComboBox | User's assets | Active assets only |
| Status | Multi-Select ComboBox | All except Cancelled | Valid statuses |
| AFE Type | Multi-Select ComboBox | All | Original, Supplement |
| Creation Date | Date Range Picker | Last 90 days | Max 12 months |
| Well Type | Multi-Select ComboBox | All | Valid well types |



### 7.2.2. Table Columns



| Column | Type | Sortable | Width | Default |
| --- | --- | --- | --- | --- |
| AFE Number | Link | Yes | 150px | Asc |
| Well Name | Text | Yes | 200px | - |
| Asset | Text | Yes | 100px | - |
| AFE Type | Text | Yes | 100px | - |
| Total Amount | Currency | Yes | 120px | - |
| Status | ObjectStatus | Yes | 100px | - |
| Created Date | Date | Yes | 100px | Desc |



# 8. Security Specifications

## 8.1. Authorization Model

Security is implemented through SAP BTP XSUAA with role-based access control. Refer to IBU-ARCH-001 for complete security architecture.

## 8.2. Role-Permission Matrix



| Role | Create | Read | Update | Approve |
| --- | --- | --- | --- | --- |
| AFE Coordinator | Yes | Yes (own assets) | Yes (Draft) | No |
| Drilling Manager | Yes | Yes (own assets) | Yes (Draft) | L1 |
| Asset Manager | No | Yes (all) | No | L2 |
| Finance Controller | No | Yes (all) | No | L2 |
| VP Operations | No | Yes (all) | No | L3 |
| Partner User | No | Yes (WI only) | No | Consent |



## 8.3. Scope Definitions



| Scope | Description |
| --- | --- |
| AFECreate | Create and submit AFE documents |
| AFEApprove | Approve or reject AFE documents |
| AFECancel | Cancel non-approved AFE documents |
| PartnerConsent | Provide JV partner consent response |
| ApprovalMatrixAdmin | Configure approval matrix rules |



## 8.4. Segregation of Duties



| Function A | Function B | Risk | Mitigation |
| --- | --- | --- | --- |
| Create AFE | Approve AFE | High | Workflow enforcement |
| Create Cost Estimate | Approve AFE | Medium | Role separation |
| Configure Matrix | Approve AFE | Critical | Admin role separation |



# 9. Testing Requirements

## 9.1. Test Scenarios



| Test ID | Description | Type | Priority |
| --- | --- | --- | --- |
| TC-AFE-001 | Create AFE with valid cost estimate | Functional | P1 |
| TC-AFE-002 | Create AFE without approved estimate (negative) | Negative | P1 |
| TC-AFE-003 | Submit AFE - transition Draft to Submitted | Functional | P1 |
| TC-AFE-004 | Multi-level approval workflow execution | Workflow | P1 |
| TC-AFE-005 | AFE rejection with comments | Functional | P1 |
| TC-AFE-006 | Supplement creation with variance calculation | Functional | P1 |
| TC-AFE-007 | Partner consent tracking | Functional | P2 |
| TC-AFE-008 | S/4HANA project creation on approval | Integration | P1 |
| TC-AFE-009 | S/4HANA WBS element creation | Integration | P1 |
| TC-AFE-010 | Mobile approval functionality | UI | P2 |
| TC-AFE-011 | Asset-level row security | Security | P1 |
| TC-AFE-012 | Delegation management | Workflow | P2 |



## 9.2. Performance Requirements



| Operation | Target | Measurement |
| --- | --- | --- |
| AFE List Load (1000 records) | < 3 seconds | Page load time |
| AFE Creation Save | < 2 seconds | API response time |
| S/4HANA Project Creation | < 5 seconds | Integration response |
| Approval Action Processing | < 2 seconds | Workflow response |
| Concurrent Approvers | 100 users | System capacity |



# 10. Technical Specification

## 10.1. Technical Architecture

The technical architecture includes:

- SAP BTP Cloud Foundry runtime environment

- SAP HANA Cloud database layer

- CAP (Node.js) backend services

- SAP Fiori Elements frontend applications

- SAP Build Process Automation for approval workflows

- S/4HANA OData API integrations for PS

- SAP Event Mesh for event-driven updates

## 10.2. Service Definition

CDS Service definition for AFE Lifecycle Management:

`service AFEService @(requires: 'authenticated-user') {
  @odata.draft.enabled entity AFEDocuments as projection on db.AFEDocuments
    actions {
      action submit() returns AFEDocuments;
      action approve(comments: String) returns AFEDocuments;
      action reject(comments: String) returns AFEDocuments;
      action createSupplement() returns AFEDocuments;
    };
  entity AFELineItems as projection on db.AFELineItems;
  entity AFEApprovals as projection on db.AFEApprovals;
  entity PartnerConsents as projection on db.PartnerConsents;
  @readonly entity S4Projects as projection on db.S4Projects;
}`

## 10.3. API Endpoints



| Method | Endpoint | Description |
| --- | --- | --- |
| GET | /odata/v4/afe/AFEDocuments | List AFE documents with filters |
| GET | /odata/v4/afe/AFEDocuments({ID}) | Get single AFE document |
| POST | /odata/v4/afe/AFEDocuments | Create AFE document |
| PATCH | /odata/v4/afe/AFEDocuments({ID}) | Update AFE document |
| POST | /odata/v4/afe/AFEDocuments({ID})/submit | Submit AFE for approval |
| POST | /odata/v4/afe/AFEDocuments({ID})/approve | Approve AFE action |
| POST | /odata/v4/afe/AFEDocuments({ID})/reject | Reject AFE action |



# 11. Appendices

## 11.1. Glossary



| Term | Definition |
| --- | --- |
| AFE | Authorization for Expenditure - formal approval document for well costs |
| WBS | Work Breakdown Structure - hierarchical cost structure |
| JOA | Joint Operating Agreement - contract governing JV operations |
| JV | Joint Venture - partnership for well operations |
| Working Interest | Ownership percentage in a well/lease |
| Supplement | Revision to original AFE to increase/decrease authorization |
| CAP | SAP Cloud Application Programming Model |
| PS | SAP Project System module in S/4HANA |
| XSUAA | SAP Authorization and Trust Management Service |



## 11.2. Error Code Reference



| Code | Description |
| --- | --- |
| AFE401 | Cost estimate not approved - cannot create AFE |
| AFE402 | Invalid approval matrix configuration |
| AFE403 | Partner working interests do not sum to 100% |
| AFE404 | S/4HANA budget reservation failed |
| AFE405 | S/4HANA WBS creation failed |
| AFE406 | Duplicate AFE number detected |
| AFE407 | Approval deadline exceeded |
| AFE408 | AFE total does not match line item sum |
| AFE409 | Supplement variance exceeds threshold - additional approval required |
| AFE410 | Partner consent timeout - default action applied |
| AFE411 | Approved AFE cannot be modified - create supplement |
| AFE412 | Invalid delegation - check date range and approver status |
| AFE413 | WBS structure mismatch with cost estimate hierarchy |



## 11.3. References

- IBU-ARCH-001: Well Cost Management Solution Architecture Specification

- PFD-WCM-2025-001: Product Feature Document - Well Cost Management

- FSD-WCM-BC-001: Functional Specification - Investment Economics Engine

- WCM-RACI-001: Well Cost Management RACI Matrix

- SAP CAP Documentation: https://cap.cloud.sap/docs/

- SAP API Business Hub: https://api.sap.com

- SAP Build Process Automation: https://help.sap.com/bpa

*--- End of Document ---*
