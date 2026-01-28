---
title: "IBU-SEC-001_Security_Authorization_Specification"
category: "architecture"
type: "Architecture Document"
created_date: "2026-01-28"
source_file: "IBU-SEC-001_Security_Authorization_Specification.docx"
---



> **Document Type**: Architecture Document
>
> This document describes the system architecture, components, and design decisions.

---


**Well Cost Management**

*Oil & Gas Drilling Cost Lifecycle Management Solution*

**Security & Authorization Specification**

Foundation Document

*Supports: S/4HANA Public Cloud | S/4HANA RISE | S/4HANA On-Premise*



| Property | Value |
| --- | --- |
| Document ID | IBU-SEC-001 |
| Version | 1.0 |
| Date | January 2025 |
| Author | Security Architect (AI-Assisted) |
| Status | Draft |
| Classification | Confidential |
| Accountable Agent | @security-agent |



*Prepared by Industry Business Unit*

# 1. Document Control

## 1.1 Version History



| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 1.0 | 2025-01-28 | Security Architect | Initial release - Complete security architecture for Well Cost Management with multi-agent RACI framework, 27 scopes, 12 role templates |



## 1.2 Related Documents



| Document ID | Document Title | Version |
| --- | --- | --- |
| IBU-ARCH-001 | Solution Architecture Specification | 1.0 |
| PFD-WCM-2025-001 | Product Feature Document - Well Cost Management | 1.0 |
| FSD-WCM-BC-001 | Functional Specification - Investment Economics Engine | 1.0 |
| WCM-RACI-001 | Well Cost Management RACI Matrix | 1.0 |



# 2. Executive Summary

## 2.1 Purpose

This document defines the comprehensive security architecture and authorization model for the Well Cost Management solution built on SAP Business Technology Platform (BTP). The solution manages the complete drilling cost lifecycle including business case development, AFE management, cost tracking, variance analysis, and reporting.

The security architecture is designed around a multi-agent system consisting of 20 specialized agents organized into four categories: Business Domain, Technical Development, Integration & Data, and Platform Operations. The @security-agent is Accountable for all security-related processes following the RACI framework.

The security architecture ensures enterprise-grade protection for sensitive drilling cost data, AFE financial information, and partner/JV data while meeting regulatory compliance requirements including SOX Section 404, GDPR, and ISO 27001.

## 2.2 Security Architecture by Deployment Model



| Security Aspect | S/4HANA Public Cloud | S/4HANA RISE | On-Premise |
| --- | --- | --- | --- |
| S/4 Authentication | OAuth 2.0 only | OAuth 2.0 / Principal Prop | OAuth / Basic / Cert |
| S/4 Authorization | Business Catalogs | Business Catalogs | Authorization Objects |
| Network Security | Direct HTTPS + IP Allow | Private Link | Cloud Connector |
| Infrastructure | SAP Managed | SAP Managed | Customer Managed |
| Patching | SAP (Quarterly) | SAP Managed | Customer Managed |



## 2.3 Security Architecture Summary



| Component | Technology / Standard |
| --- | --- |
| Identity Provider | SAP Identity Authentication Service (IAS) |
| Authorization Service | SAP XSUAA (OAuth 2.0, JWT) |
| S/4HANA Cloud Auth | OAuth 2.0 via Communication Arrangements |
| Encryption at Rest | SAP HANA Cloud Native (AES-256) |
| Encryption in Transit | TLS 1.3 |
| Compliance Frameworks | SOX Section 404, GDPR, ISO 27001 |
| Total Scopes | 27 (covering all Well Cost Management modules) |
| Total Role Templates | 12 (aligned with oil & gas drilling operations) |
| Accountable Agent | @security-agent (6 Accountable, 10 Consulted, 11 Informed) |



# 3. Authentication Architecture

## 3.1 Well Cost Management Application Authentication



| Component | Auth Method | Identity Provider |
| --- | --- | --- |
| Fiori Launchpad | SAML 2.0 SSO | SAP IAS (federated to Corporate IdP) |
| CAP OData Services | OAuth 2.0 Bearer Token | SAP XSUAA |
| Mobile Application | OAuth 2.0 + Refresh Token | SAP XSUAA via Mobile Services |
| External API Access | OAuth 2.0 Client Credentials | SAP XSUAA |



## 3.2 S/4HANA Integration Authentication

### 3.2.1 S/4HANA Public Cloud & RISE



| Scenario | OAuth Flow | Use Case |
| --- | --- | --- |
| User Context (Posting) | SAML Bearer Assertion | Journal entries, AFE approvals - maintains user identity for audit |
| Technical Integration | Client Credentials | Master data sync, cost actuals retrieval, scheduled processes |
| Event Subscription | Client Credentials | S/4HANA business event consumption |



### 3.2.2 S/4HANA On-Premise



| Scenario | Auth Method | Use Case |
| --- | --- | --- |
| User Context | Principal Propagation (SCC) | User identity maintained via Cloud Connector |
| Technical Integration | Technical User + OAuth/Basic | Background processes, batch sync |



## 3.3 Communication Arrangements (S/4HANA Cloud)

S/4HANA Cloud requires Communication Arrangements to expose APIs. Each arrangement creates a Communication User with OAuth credentials:



| Scenario ID | Description | Communication User |
| --- | --- | --- |
| SAP_COM_0008 | Business Partner Integration | WELLCOST_BP_USER |
| SAP_COM_0028 | Journal Entry Integration | WELLCOST_FI_USER |
| SAP_COM_0053 | Purchase Contract Integration | WELLCOST_MM_USER |
| SAP_COM_0164 | Purchase Order Integration | WELLCOST_PO_USER |
| SAP_COM_0367 | Goods Receipt Integration | WELLCOST_GR_USER |



## 3.4 Session Management



| Parameter | Web Application | Mobile Application |
| --- | --- | --- |
| Access Token Lifetime | 12 hours | 1 hour |
| Refresh Token Lifetime | 7 days | 30 days |
| Session Timeout (Idle) | 30 minutes | 15 minutes |



# 4. Authorization Model

## 4.1 Well Cost Management RBAC (BTP)

Well Cost Management implements Role-Based Access Control using SAP XSUAA scopes, role templates, and role collections. The @security-agent is Accountable for RBAC implementation.

### 4.1.1 Scope Definitions



| Scope Name | Description | Module |
| --- | --- | --- |
| MasterDataRead | Read access to wells, cost elements, vendors, WBS templates | WCM-08 |
| MasterDataWrite | Create/Update master data records | WCM-08 |
| MasterDataAdmin | Full master data administration including delete | WCM-08 |
| CostEstimateCreate | Create new cost estimates and WBS buildups | WCM-02 |
| CostEstimateApprove | Approve cost estimates for AFE generation | WCM-02 |
| AFECreate | Create and submit AFE documents | WCM-03 |
| AFEApprove | Approve or reject AFE documents | WCM-03 |
| AFESupplement | Create AFE supplements and revisions | WCM-03 |
| BusinessCaseCreate | Create investment business cases | WCM-01 |
| BusinessCaseApprove | Approve investment recommendations | WCM-01 |
| EconomicsCalculate | Execute NPV/IRR/ROI calculations | WCM-01 |
| VarianceView | View cost variance analysis (AvE) | WCM-04 |
| VarianceEdit | Edit variance categorization and comments | WCM-04 |
| FinancePost | Post journal entries to S/4HANA | WCM-06 |
| PartnerView | View partner/JV cost allocations | WCM-09 |
| PartnerManage | Manage working interests and JIB statements | WCM-09 |
| ReportView | View reports, dashboards, and analytics | WCM-05 |
| ReportExport | Export reports to Excel/PDF | WCM-05 |
| DocumentRead | Read AFE documents and attachments | WCM-10 |
| DocumentWrite | Upload and manage documents | WCM-10 |
| IntegrationMonitor | Monitor S/4HANA integration status and errors | WCM-06 |
| AIMLExecute | Execute AI/ML predictions and anomaly detection | WCM-04 |
| WorkflowAdmin | Configure approval workflows and escalations | WCM-03 |
| SecurityAdmin | Manage roles, scopes, and access control | WCM-11 |
| AuditRead | Read audit logs and compliance reports | WCM-11 |
| ConfigAdmin | System configuration and settings | WCM-11 |
| AdminAccess | Full system administration access | WCM-11 |



### 4.1.2 Role Templates



| Role Template | Key Scopes | Org Filter |
| --- | --- | --- |
| DrillingEngineer | MasterDataRead, CostEstimateCreate, BusinessCaseCreate, EconomicsCalculate, DocumentRead, ReportView | Asset, Well |
| PetroleumEconomist | MasterDataRead, BusinessCaseCreate, BusinessCaseApprove, EconomicsCalculate, CostEstimateApprove, ReportView, ReportExport | Asset |
| AFECoordinator | MasterDataRead, AFECreate, AFESupplement, DocumentWrite, PartnerView, WorkflowAdmin | Asset, Well |
| AssetManager | MasterDataRead, AFEApprove, BusinessCaseApprove, VarianceView, ReportView, ReportExport, PartnerView | Asset |
| FinanceController | MasterDataRead, FinancePost, VarianceView, VarianceEdit, ReportView, ReportExport, AuditRead | Company Code |
| OperationsManager | MasterDataRead, VarianceView, AFEApprove, ReportView, AIMLExecute | Asset, Well |
| PartnerAccountant | MasterDataRead, PartnerView, PartnerManage, ReportView, ReportExport | JV, Asset |
| CostAnalyst | MasterDataRead, CostEstimateCreate, VarianceView, VarianceEdit, AIMLExecute, ReportView | Asset |
| IntegrationAdmin | MasterDataRead, IntegrationMonitor, AuditRead, ReportView | None (Global) |
| ComplianceOfficer | MasterDataRead, AuditRead, ReportView, ReportExport | Company Code |
| SystemAdministrator | AdminAccess (All scopes) | None (Global) |
| Viewer | MasterDataRead, ReportView, DocumentRead, VarianceView | Asset, Well |



## 4.2 S/4HANA Cloud Authorization

For S/4HANA Public Cloud and RISE, authorization uses Business Catalogs and Business Roles instead of traditional Authorization Objects.

### 4.2.1 Business Catalogs



| Business Catalog | Description | WCM Module |
| --- | --- | --- |
| SAP_FI_BC_GL_JE | Journal Entry Management | WCM-06 Finance |
| SAP_PS_BC_PRJ_MGMT | Project System Management | WCM-03 AFE |
| SAP_MM_BC_PO_MGMT | Purchase Order Management | WCM-02 Estimation |
| SAP_CO_BC_COST_CTR | Cost Center Accounting | WCM-04 Variance |
| SAP_MM_BC_BP_MAINT | Business Partner Maintenance | WCM-08 Master Data |



### 4.2.2 Business Roles Mapping



| S/4HANA Business Role | SAP Delivered Template | WCM Role |
| --- | --- | --- |
| Project Manager | SAP_BR_PROJECT_MANAGER | AFE Coordinator |
| Cost Accountant | SAP_BR_COST_ACCOUNTANT | Finance Controller |
| Purchaser | SAP_BR_PURCHASER | Cost Analyst |
| GL Accountant | SAP_BR_GL_ACCOUNTANT | Finance Controller |



# 5. Role-Permission Matrix

*Legend: C=Create, R=Read, U=Update, D=Delete, -=No Access*



| Role | Master Data | Cost Est. | AFE | Variance | Finance | Partner |
| --- | --- | --- | --- | --- | --- | --- |
| Drilling Engineer | R | CR | R | R | - | - |
| Petroleum Economist | R | CRU | R | R | R | - |
| AFE Coordinator | R | R | CRU | R | - | R |
| Asset Manager | R | RU | RU | R | R | R |
| Finance Controller | R | R | R | CRUD | CRU | R |
| Operations Manager | R | R | RU | RU | R | - |
| Partner Accountant | R | - | R | R | R | CRUD |
| Cost Analyst | R | CRU | R | RU | - | - |
| System Administrator | CRUD | CRUD | CRUD | CRUD | CRUD | CRUD |
| Viewer | R | R | R | R | R | R |



# 6. Segregation of Duties (SoD)

## 6.1 SoD Conflict Matrix



| Function A | Function B | Risk | Mitigation |
| --- | --- | --- | --- |
| Create Cost Estimate | Approve Cost Estimate | High | Workflow - different approver required |
| Create AFE | Approve AFE | Critical | Multi-level approval workflow |
| Create Business Case | Approve Investment | High | Economist vs Manager separation |
| Post Actuals | Approve Variance | High | Finance vs Operations separation |
| Maintain Vendor | Create PO | Critical | SoD enforcement in role design |
| Edit Working Interest | Generate JIB | High | Partner accountant dual control |
| Configure Workflow | Approve AFE | Critical | Admin vs Approver separation |
| Manage Security Roles | Access Financial Data | Critical | Security admin isolated from operations |



## 6.2 AFE-Specific SOX Controls

The AFE lifecycle introduces specific SOX Section 404 controls managed by @compliance-agent with support from @security-agent:



| Control ID | Requirement | Implementation | Evidence |
| --- | --- | --- | --- |
| AFE-001 | AFE Segregation | AFE creator cannot be approver | Workflow audit log showing different users |
| AFE-002 | Multi-level Approval | Amount-based approval matrix | Approval workflow configuration |
| AFE-003 | AFE Audit Trail | All versions retained, no deletion | AFE version history, no DELETE scope |
| AFE-004 | Budget Verification | S/4HANA budget check before approval | PS integration audit log |
| WCM-001 | Cost Estimate Review | Estimate requires economist approval | Approval workflow audit trail |
| WCM-002 | Variance Documentation | Root cause required for >10% variance | Variance commentary audit log |



# 7. Network Security

## 7.1 Connectivity by Deployment Model

### 7.1.1 S/4HANA Public Cloud

- Direct HTTPS connectivity over public internet

- No SAP Cloud Connector required

- IP allowlisting configurable in Communication Arrangement

- TLS 1.2+ mandatory (TLS 1.3 recommended)

### 7.1.2 S/4HANA RISE (Private Link)

- SAP Private Link Service (Azure Private Link / AWS PrivateLink)

- Traffic stays within cloud provider backbone - no public internet

- Requires Private Link service instance in BTP subaccount

- BTP Destination Proxy Type: PrivateLink

### 7.1.3 S/4HANA On-Premise (Cloud Connector)

- SAP Cloud Connector installed in customer DMZ

- Reverse proxy - outbound connection only from on-premise

- BTP Destination Proxy Type: OnPremise

- Supports Principal Propagation for user context

## 7.2 Encryption Standards



| Security Control | Implementation |
| --- | --- |
| Data Encryption at Rest | SAP HANA Cloud native encryption (AES-256) |
| Data Encryption in Transit | TLS 1.3 for all communications |
| Certificate Management | SAP-managed with auto-renewal (customer BYOC option) |
| Key Management | SAP Data Custodian (BYOK option available) |



# 8. Shared Responsibility Model

For S/4HANA Cloud deployments, security responsibilities are shared between SAP and the customer:



| Security Domain | S/4HANA Cloud/RISE | Well Cost (BTP) |
| --- | --- | --- |
| Physical Infrastructure | SAP Managed | SAP Managed |
| Network Perimeter | SAP Managed | SAP Managed |
| OS Patching | SAP Managed | SAP Managed |
| Database Security | SAP Managed | SAP Managed |
| Application Patching | SAP (quarterly) | Customer Managed |
| Identity Management | Customer Managed | Customer Managed |
| User Access Control | Customer Managed | Customer Managed |
| Business Role Assignment | Customer Managed | Customer Managed |
| Data Classification | Customer Managed | Customer Managed |
| Audit Log Review | Customer Managed | Customer Managed |



## 8.1 SAP Security Certifications

S/4HANA Cloud and SAP BTP maintain certifications supporting Well Cost Management compliance:

- SOC 1 Type II and SOC 2 Type II

- ISO 27001, ISO 27017, ISO 27018

- CSA STAR Level 2

- GDPR compliance attestation

# 9. Compliance Controls

## 9.1 SOX Section 404



| Control | Requirement | Implementation | Evidence (Cloud) |
| --- | --- | --- | --- |
| SOX-001 | Access Control | RBAC via XSUAA + Business Roles | Maintain Business Users app |
| SOX-002 | Segregation of Duties | SoD matrix, workflow approvals | IAM Apps SoD checks |
| SOX-003 | Audit Trail | All transactions logged | Security Audit Log app |
| SOX-004 | Change Management | SAP-managed updates | SAP release notes |
| SOX-005 | Data Integrity | Validation rules, checksums | Validation reports |
| AFE-001 | AFE Segregation | Creator ≠ Approver workflow | AFE audit trail |
| AFE-003 | AFE Versioning | No delete, version tracking | AFE version history |
| WCM-001 | Cost Estimate Review | Economist approval required | Estimate approval log |



## 9.2 GDPR Compliance



| Right | Implementation | Technical Control |
| --- | --- | --- |
| Right to Access | Data export API | Self-service download |
| Right to Rectification | Edit with audit trail | Profile update logging |
| Right to Erasure | Anonymization procedures | Data anonymization service |
| Data Minimization | Only required data collected | Field requirements analysis |



# 10. Data Classification

Well Cost Management data classification ensures appropriate security controls for drilling cost and financial data:



| Entity | Classification | Sensitivity | Access Control |
| --- | --- | --- | --- |
| WellMaster | Internal | Medium | Read: All roles; Write: Master Data roles |
| CostEstimate | Confidential | High | Asset-level restriction; Estimate creators and approvers |
| AFEDocument | Confidential | High | Contains financial commitments - restricted to AFE roles |
| InvestmentAnalysis | Confidential | High | NPV/IRR data - Economist and Manager roles only |
| PartnerAllocation | Restricted | Critical | JV-level segregation; Partner-specific visibility |
| CostActuals | Confidential | High | Financial data - Finance and authorized roles |
| VarianceAnalysis | Confidential | High | Contains cost performance data |
| VendorRates | Restricted | Critical | Commercially sensitive - limited access |
| AuditLog | Internal | Medium | Read-only except system; Compliance roles |



# 11. Audit Logging

## 11.1 Well Cost Management Audit Log

The @security-agent is Accountable for audit logging with @compliance-agent Responsible for audit trail maintenance:



| Event Category | Events Logged | Retention |
| --- | --- | --- |
| Authentication | Login success/failure, logout, timeout | 90 days |
| Authorization | Access granted/denied, role changes | 7 years |
| Data Changes | Create, update, delete with before/after values | 7 years |
| AFE Transactions | AFE creation, approval, rejection, supplements | 10 years |
| Financial Transactions | Cost postings, budget reservations, JIB generation | 10 years |
| Security Events | Privilege escalation, SoD violations | 7 years |
| Integration Events | S/4HANA sync, data pipeline executions | 90 days |



## 11.2 S/4HANA Cloud Audit Access



| Audit Capability | S/4HANA Cloud App | Access Method |
| --- | --- | --- |
| Security Audit Log | Security Audit Log App | Fiori app (admin role) |
| Read Access Logging | RAL Configuration & Monitor | Fiori app + API |
| Change Documents | Display Change Documents | Fiori app + OData API |
| API Call Logging | Communication Management | Comm. Arrangement monitor |



# 12. Security Monitoring

## 12.1 Security Metrics

The @monitor-agent is Accountable for security monitoring with @security-agent Consulted:



| Metric | Target | Alert Threshold | Frequency |
| --- | --- | --- | --- |
| Failed login attempts per user | < 5/day | > 3 consecutive | Real-time |
| Privilege escalation attempts | 0 | Any occurrence | Real-time |
| SoD violations detected | 0 | Any occurrence | Daily |
| Unauthorized access attempts | 0 | Any occurrence | Real-time |
| Certificate expiration | > 30 days | < 30 days | Daily |
| AFE approval without review | 0 | Any occurrence | Real-time |
| Unusual cost variance patterns | 0 | > 25% deviation | Real-time |



## 12.2 Incident Response SLAs



| Severity | Initial Response | Containment | Resolution |
| --- | --- | --- | --- |
| Critical | 15 minutes | 1 hour | 4 hours |
| High | 1 hour | 4 hours | 24 hours |
| Medium | 4 hours | 24 hours | 72 hours |
| Low | 24 hours | 72 hours | 1 week |



# 13. Agent Security RACI

Security-related processes and their RACI assignments across the 20-agent architecture:



| Process | @security-agent | @devops-agent | @compliance-agent | @monitor-agent |
| --- | --- | --- | --- | --- |
| Role-based Access Control | A | C | I | - |
| Data Segregation (Asset/JV) | A | - | I | - |
| OAuth/SAML Integration | A | C | - | - |
| Audit Logging | A | I | R | C |
| Sensitive Data Masking | A | - | C | - |
| Security Testing | A | C | I | - |
| SOX Compliance Support | C | - | A | - |
| Access Review Reports | R | - | A | I |
| Incident Management | C | C | - | A |



*Legend: A=Accountable, R=Responsible, C=Consulted, I=Informed*

# 14. Appendices

## 14.1 Appendix A: xs-security.json

Complete XSUAA configuration file with all 27 scopes, 12 role templates, and role collections for Well Cost Management.

*See accompanying file: IBU-SEC-001-A_xs-security.json*

## 14.2 Appendix B: CDS Authorization Annotations

CDS authorization annotations for all Well Cost Management services including cost estimation, AFE, and variance analysis entities.

*See accompanying file: IBU-SEC-001-B_authorization.cds*

## 14.3 Appendix C: Communication Arrangement Setup Guide

Step-by-step guide for configuring S/4HANA Cloud Communication Arrangements for Project System, Cost Center, and Finance integration.

*See accompanying file: IBU-SEC-001-C_Communication_Setup.docx*

## 14.4 Appendix D: Business Role Configuration

S/4HANA Cloud Business Role templates and restriction type configuration for asset-level and JV-level data segregation.

*See accompanying file: IBU-SEC-001-D_Business_Roles.xlsx*

*--- End of Document ---*

IBU-SEC-001 | Well Cost Management | Version 1.0
