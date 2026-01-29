# Complete SAP CAP Project Template
## From Idea to Production - A Step-by-Step Guide

This document provides a complete template for building enterprise SAP CAP applications, starting from the very first idea all the way through production deployment.

---

## Table of Contents

1. [Phase 0: Project Inception](#phase-0-project-inception)
2. [Phase 1: Requirements & Governance](#phase-1-requirements--governance)
3. [Phase 2: Architecture & Design](#phase-2-architecture--design)
4. [Phase 3: Data Modeling](#phase-3-data-modeling)
5. [Phase 4: SAP CAP Implementation](#phase-4-sap-cap-implementation)
6. [Phase 5: Testing & Quality](#phase-5-testing--quality)
7. [Phase 6: Deployment & Operations](#phase-6-deployment--operations)
8. [Templates & Checklists](#templates--checklists)
9. [AI Prompts for Each Phase](#ai-prompts-for-each-phase)

---

# Phase 0: Project Inception

## 0.1 Project Idea Definition

Before writing any code, clearly define:

| Question | Answer Template |
|----------|-----------------|
| **What problem are we solving?** | [Describe the business problem] |
| **Who are the users?** | [List user types/personas] |
| **What is the scope?** | [Define boundaries] |
| **What is the expected outcome?** | [Define success criteria] |

### AI Prompt: Project Definition

```
I want to build an enterprise application for [DOMAIN].

Please help me define the project by answering:
1. What are the core business processes this should support?
2. Who are the primary users and their roles?
3. What are the key entities/data objects involved?
4. What integrations might be needed?
5. What are potential technical challenges?

Domain context:
[Describe your business domain in detail]

Expected users:
[List who will use this system]

Current pain points:
[What problems exist today]
```

## 0.2 Initial Folder Structure

Create the project folder structure:

```
my-project/
├── docs/                      # All documentation
│   ├── architecture/          # Architecture documents
│   ├── functional/            # Functional requirements
│   ├── technical/             # Technical specifications
│   ├── design/                # Design artifacts
│   │   ├── RACI.md
│   │   ├── DESIGN_DECISIONS.md
│   │   └── PROJECT_TRACKER.md
│   └── uploads/               # Source documents
├── templates/                 # Document templates
├── GOVERNANCE.md              # Project governance
├── CLAUDE.md                  # AI development guide
└── README.md                  # Project overview
```

### AI Prompt: Folder Structure Generation

```
Create a complete project folder structure for a [PROJECT TYPE] project.

Requirements:
- Documentation organized by category
- Clear separation of concerns
- Version control friendly
- Supports collaborative development

Include placeholder files with appropriate content for:
- README.md
- GOVERNANCE.md
- RACI.md
- DESIGN_DECISIONS.md
- PROJECT_TRACKER.md

Output: Shell commands to create the structure or a complete listing.
```

## 0.3 Project Checklist - Phase 0

- [ ] Business problem clearly defined
- [ ] Target users identified
- [ ] Project scope documented
- [ ] Success criteria established
- [ ] Folder structure created
- [ ] Git repository initialized

---

# Phase 1: Requirements & Governance

## 1.1 Governance Framework

### GOVERNANCE.md Template

```markdown
# [Project Name] Project Governance

**Project**: [Project Name]
**Version**: 1.0
**Last Updated**: [Date]

---

## Purpose

[Brief description of governance purpose]

---

## Team Roles

| Role | Person | Responsibility |
|------|--------|----------------|
| **Functional Architect** | [Name] | Business requirements, functional design approval |
| **Technical Architect** | [Name/AI] | Technical design, code development |
| **Product Owner** | [Name] | Final sign-off on deliverables |
| **QA Lead** | [Name] | Quality assurance |

---

## Critical Gates Before Coding

### Gate 1: Documentation Check

Before ANY coding work, verify:

- [ ] High-Level Design (HLD) document exists
- [ ] UI specifications available (if UI work)
- [ ] Data model specifications defined
- [ ] Design decisions documented

**If ANYTHING is missing: STOP and request documents**

### Gate 2: User Approval

Before writing code:
1. Provide pre-coding summary
2. List files to be created/modified
3. Wait for explicit approval

### Gate 3: Phase Completion

Before moving to next phase:
1. Current phase code is committed
2. User has validated deliverables
3. No blocking issues remain

---

## Session Protocol

At the start of every session:

1. Read GOVERNANCE.md
2. Check git status
3. Review available documents in /docs/
4. Confirm all gates are satisfied

---

## Working Rules

### Rule 1: Consultation Before Action
Always consult before:
- Architectural decisions
- Starting coding work
- Committing code
- Making significant changes

### Rule 2: No Assumptions
- Ask questions instead of assuming
- All functional decisions require approval
- Technical decisions are explained first

### Rule 3: Transparency
- Explain what will be done before doing it
- Clear communication of blockers
- Progress updates during work

---

## Escalation Path

| Issue Type | Action |
|------------|--------|
| Technical blocker | Raise to user, user decides |
| Functional clarification | Ask user for guidance |
| Scope change | Consult user for approval |
| Missing documentation | Stop and request documents |
```

## 1.2 RACI Matrix

### RACI.md Template

```markdown
# [Project Name] RACI Matrix

**Legend:**
- **R** = Responsible (does the work)
- **A** = Accountable (final decision maker)
- **C** = Consulted (provides input)
- **I** = Informed (notified after)

---

## Planning & Design Activities

| Activity | Business Owner | Technical Lead | Developer |
|----------|---------------|----------------|-----------|
| Define requirements | A, R | C | I |
| Approve design | A | R | C |
| Technical architecture | C | A, R | C |
| Data model design | C | A | R |
| UI/UX design | A, R | C | I |

---

## Development Activities

| Activity | Business Owner | Technical Lead | Developer |
|----------|---------------|----------------|-----------|
| Project setup | I | A | R |
| Code development | C | A | R |
| Code review | I | A, R | R |
| Documentation | C | A | R |
| Commit/Push | A | C | R |

---

## Testing & Deployment

| Activity | Business Owner | Technical Lead | Developer |
|----------|---------------|----------------|-----------|
| Unit testing | I | C | A, R |
| Integration testing | C | A | R |
| UAT | A, R | C | I |
| Deployment | A | R | C |
```

## 1.3 Requirements Gathering

### Functional Requirements Document Template

```markdown
# [Module Name] - Functional Requirements

## 1. Overview
[Brief description of the module]

## 2. Business Objectives
- [Objective 1]
- [Objective 2]

## 3. User Stories

### US-001: [Story Title]
**As a** [user type]
**I want to** [action]
**So that** [benefit]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## 4. Business Rules

| Rule ID | Rule Description | Validation |
|---------|------------------|------------|
| BR-001 | [Rule] | [How to validate] |

## 5. Data Requirements

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| [Field] | [Type] | Yes/No | [Rules] |

## 6. UI Requirements
[Attach wireframes or describe UI needs]

## 7. Integration Requirements
[External systems to integrate with]
```

### AI Prompt: Requirements Document Generation

```
Create a functional requirements document for [MODULE NAME] in [PROJECT CONTEXT].

Module purpose: [Describe what this module does]

Key functionality:
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

Users: [Who uses this module]

Please include:
- Detailed user stories with acceptance criteria
- Business rules with validation logic
- Data requirements with field specifications
- UI requirements overview
- Integration points

Format: Markdown document following enterprise documentation standards.
```

## 1.4 Project Checklist - Phase 1

- [ ] GOVERNANCE.md created and approved
- [ ] RACI.md defined with clear responsibilities
- [ ] PROJECT_TRACKER.md initialized
- [ ] DESIGN_DECISIONS.md started
- [ ] Functional requirements documented
- [ ] User stories defined with acceptance criteria
- [ ] Business rules documented
- [ ] Stakeholder sign-off obtained

---

# Phase 2: Architecture & Design

## 2.1 Solution Architecture Document

### Template Structure

```markdown
# [Project Name] - Solution Architecture Document

**Document ID**: [ID]
**Version**: 1.0
**Status**: Draft | Review | Approved

---

## 1. Executive Summary
[High-level overview of the solution]

## 2. Business Context

### 2.1 Business Drivers
- [Driver 1]
- [Driver 2]

### 2.2 Business Capabilities
[What business capabilities this enables]

## 3. Solution Overview

### 3.1 Solution Diagram
```
[ASCII diagram or reference to image]
```

### 3.2 Key Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| [Component] | [Purpose] | [Tech stack] |

## 4. Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Frontend | SAP Fiori Elements | 1.120+ |
| Backend | SAP CAP (Node.js) | 8.x |
| Database | SAP HANA Cloud | - |
| Auth | SAP XSUAA | - |

## 5. Integration Architecture

### 5.1 External Integrations

| System | Direction | Protocol | Purpose |
|--------|-----------|----------|---------|
| [System] | Inbound/Outbound | [Protocol] | [Purpose] |

## 6. Security Architecture

### 6.1 Authentication
[Authentication approach]

### 6.2 Authorization
[Role-based access control design]

## 7. Deployment Architecture
[Cloud deployment topology]

## 8. Non-Functional Requirements

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Availability | 99.9% | Uptime monitoring |
| Response Time | < 2s | APM metrics |
| Concurrent Users | 100 | Load testing |
```

### AI Prompt: Solution Architecture

```
Create a Solution Architecture Document for [PROJECT NAME].

Project context:
[Describe the project and its purpose]

Business requirements:
1. [Requirement 1]
2. [Requirement 2]

Technical constraints:
- Must run on SAP BTP
- Use SAP CAP as backend framework
- SAP Fiori Elements for UI
- SAP HANA Cloud for database

Integrations needed:
- [System 1]: [Purpose]
- [System 2]: [Purpose]

Please include:
- Solution overview with component diagram
- Technology stack recommendations
- Integration architecture
- Security design (authentication, authorization)
- Deployment topology
- Non-functional requirements

Format: Enterprise architecture document with diagrams.
```

## 2.2 Data Architecture Document

### Template Structure

```markdown
# [Project Name] - Data Architecture Document

## 1. Data Model Overview

### 1.1 Domain Model
[High-level domain entities and relationships]

### 1.2 Entity Relationship Diagram
```
[ERD diagram or reference]
```

## 2. Entity Definitions

### 2.1 [Entity Name]

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| ID | UUID | Primary key | PK, Auto-generated |
| [field] | [type] | [description] | [constraints] |

### 2.2 Relationships

| From | To | Type | Description |
|------|-----|------|-------------|
| [Entity] | [Entity] | 1:N | [Description] |

## 3. Data Governance

### 3.1 Data Ownership
[Who owns which data]

### 3.2 Data Quality Rules
[Validation and quality rules]

## 4. Data Security

### 4.1 Sensitive Data Classification
[PII, financial data, etc.]

### 4.2 Access Control
[Who can access what data]
```

### AI Prompt: Data Architecture

```
Create a Data Architecture Document for [PROJECT NAME] in [DOMAIN].

Key business entities:
1. [Entity 1]: [Description]
2. [Entity 2]: [Description]
3. [Entity 3]: [Description]

Relationships:
- [Entity 1] has many [Entity 2]
- [Entity 2] belongs to [Entity 3]

Please include:
- Complete entity definitions with all attributes
- Data types appropriate for SAP CAP/HANA
- Relationship mappings (1:1, 1:N, M:N)
- Primary and foreign keys
- Indexes for common queries
- Data validation rules
- Audit fields (created, modified)

Format: Data architecture document with entity tables.
```

## 2.3 API Architecture Document

### Template Structure

```markdown
# [Project Name] - API Architecture Design

## 1. API Strategy

### 1.1 API Style
OData V4 (SAP CAP standard)

### 1.2 Versioning Strategy
[How APIs are versioned]

## 2. Service Catalog

| Service | Path | Purpose | Auth |
|---------|------|---------|------|
| [Service] | /api/[path] | [Purpose] | [Role] |

## 3. API Specifications

### 3.1 [Service Name]

**Base Path**: `/api/[service]`
**Authentication**: Bearer token (XSUAA)

#### Entities

| Entity | Operations | Notes |
|--------|------------|-------|
| [Entity] | CRUD | [Notes] |

#### Custom Actions

| Action | Method | Path | Description |
|--------|--------|------|-------------|
| [Action] | POST | /[Entity]/{id}/[action] | [Description] |

#### Custom Functions

| Function | Method | Path | Description |
|----------|--------|------|-------------|
| [Function] | GET | /[function](...) | [Description] |

## 4. Error Handling

| Code | Meaning | When Used |
|------|---------|-----------|
| 400 | Bad Request | Validation errors |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Entity not found |
| 500 | Server Error | Unexpected errors |
```

## 2.4 Security Architecture Document

### Template Structure

```markdown
# [Project Name] - Security & Authorization Specification

## 1. Authentication

### 1.1 Identity Provider
SAP Identity Authentication Service (IAS) / XSUAA

### 1.2 Token Format
JWT tokens via OAuth 2.0

## 2. Authorization Model

### 2.1 Roles

| Role | Description | Permissions |
|------|-------------|-------------|
| Admin | System administrator | Full access |
| Manager | Department manager | Read/Write own department |
| User | Standard user | Read/Write own records |
| Viewer | Read-only access | Read only |

### 2.2 Scopes

| Scope | Description |
|-------|-------------|
| [scope].read | Read access |
| [scope].write | Write access |
| [scope].admin | Admin access |

## 3. Entity-Level Authorization

| Entity | Create | Read | Update | Delete |
|--------|--------|------|--------|--------|
| [Entity] | [Roles] | [Roles] | [Roles] | [Roles] |

## 4. Instance-Level Authorization

[Row-level security rules]

## 5. Audit Requirements

| Event | Logged Data | Retention |
|-------|-------------|-----------|
| Login | User, time, IP | 1 year |
| Data Change | User, before/after | 7 years |
```

## 2.5 Project Checklist - Phase 2

- [ ] Solution Architecture Document created
- [ ] Data Architecture Document created
- [ ] API Architecture Document created
- [ ] Security Specification created
- [ ] All documents reviewed and approved
- [ ] Design decisions logged in DESIGN_DECISIONS.md
- [ ] Architecture diagrams created
- [ ] Technical feasibility confirmed

---

# Phase 3: Data Modeling

## 3.1 Domain Analysis

Before creating CDS schemas:

1. **Identify Bounded Contexts**
   - Group related entities
   - Define service boundaries
   - Map to business domains

2. **Entity Identification**
   - List all entities from requirements
   - Define relationships
   - Identify master data vs transactional data

3. **Attribute Analysis**
   - List fields for each entity
   - Determine data types
   - Identify required vs optional
   - Define validation rules

### AI Prompt: Domain Analysis

```
Analyze the domain for [PROJECT NAME] and identify entities.

Business context:
[Describe the business domain]

Key processes:
1. [Process 1]
2. [Process 2]
3. [Process 3]

Please provide:
1. List of all entities with descriptions
2. Entity categorization (master data, transactional, configuration)
3. Relationships between entities
4. Attributes for each entity
5. Suggested bounded contexts/services

Format: Analysis document with entity tables and relationship diagrams.
```

## 3.2 CDS Schema Design

### Schema Organization

```
db/
├── common.cds            # Shared types, aspects
├── master-data.cds       # Master data entities
├── transactions.cds      # Transactional entities
├── configuration.cds     # Config entities
├── security.cds          # Security entities
└── data/                 # Initial data (CSV)
    ├── [namespace]-[Entity].csv
    └── ...
```

### AI Prompt: CDS Schema Generation

```
Create SAP CAP CDS database schemas for [PROJECT NAME].

Domain: [Business domain]

Entities needed:
1. [Entity 1]: [Description and key fields]
2. [Entity 2]: [Description and key fields]
3. [Entity 3]: [Description and key fields]

Relationships:
- [Describe all relationships]

Requirements:
- Use @sap/cds version 8.x syntax
- Apply cuid, managed aspects appropriately
- Create reusable types for common patterns
- Use enums for status fields
- Include appropriate indexes
- Add validation annotations
- Organize into logical namespaces
- Split into multiple files by domain

Output: Complete .cds schema files with comments.
```

## 3.3 Initial Data (CSV)

Create CSV files for master data:

```
db/data/my.domain-Statuses.csv
```

```csv
code;name;description
DRAFT;Draft;Initial state
ACTIVE;Active;Published and active
CLOSED;Closed;Archived
```

### AI Prompt: Sample Data Generation

```
Generate sample CSV data for SAP CAP entities.

Entities:
1. [Entity 1] with fields: [field list]
2. [Entity 2] with fields: [field list]

Requirements:
- 5-10 realistic sample records per entity
- Proper data relationships (matching foreign keys)
- Realistic values for the [DOMAIN] domain
- Date format: YYYY-MM-DD
- UUID format for IDs
- CSV with semicolon separator

Output: CSV file contents for each entity.
```

## 3.4 Project Checklist - Phase 3

- [ ] Domain analysis completed
- [ ] All entities identified
- [ ] Relationships defined
- [ ] CDS schema files created
- [ ] Common types/aspects defined
- [ ] Validation rules added
- [ ] Sample data CSV files created
- [ ] Schema compiles without errors

---

# Phase 4: SAP CAP Implementation

## 4.1 Project Initialization

```bash
# Create new CAP project
cds init my-project
cd my-project

# Add required dependencies
npm install

# Add HANA support
cds add hana

# Add authentication
cds add xsuaa

# Add MTA for deployment
cds add mta
```

## 4.2 Service Layer Implementation

### Service Organization

```
srv/
├── index.cds              # Main service index
├── master-data-service.cds
├── master-data-service.js
├── master-data-service-ui.cds
├── [domain]-service.cds
├── [domain]-service.js
├── [domain]-service-ui.cds
└── lib/                   # Shared utilities
    ├── validators.js
    └── helpers.js
```

### AI Prompt: Service Definition

```
Create SAP CAP service definitions for [PROJECT NAME].

Services needed:
1. [Service 1]: Exposes [entities] for [users/purpose]
2. [Service 2]: Exposes [entities] for [users/purpose]

For each service include:
- @path annotation
- @requires for authorization
- Entity projections with field selections
- @odata.draft.enabled where appropriate
- Custom actions (bound and unbound)
- Custom functions
- Redirected associations

Technical requirements:
- OData V4
- Proper role-based access
- Draft support for complex entities

Output: Complete .cds service definition files.
```

### AI Prompt: Service Handler

```
Create SAP CAP JavaScript handler for [SERVICE NAME].

Service entities:
1. [Entity 1]: [Business rules]
2. [Entity 2]: [Business rules]

Custom actions:
1. [Action 1]: [What it does]
2. [Action 2]: [What it does]

Validation rules:
- [Rule 1]
- [Rule 2]

Please include:
- before/after hooks for CRUD operations
- Validation logic
- Business rule implementation
- Error handling with proper messages
- Logging
- Transaction handling

Output: Complete .js handler file with JSDoc comments.
```

## 4.3 UI Annotations

### AI Prompt: UI Annotations

```
Create SAP Fiori Elements UI annotations for [SERVICE NAME].

Entities to annotate:
1. [Entity 1]:
   - List columns: [fields]
   - Filters: [fields]
   - Object page sections: [sections]

2. [Entity 2]:
   - List columns: [fields]
   - Filters: [fields]

Requirements:
- Enable Create/Edit/Delete buttons
- Configure proper headers
- Set up value helps
- Define field groups for forms
- Configure sub-object tables

Output: Complete *-ui.cds annotation file.
```

## 4.4 Project Checklist - Phase 4

- [ ] CAP project initialized
- [ ] Database schemas imported
- [ ] Services defined
- [ ] Handlers implemented
- [ ] UI annotations added
- [ ] `cds watch` runs without errors
- [ ] CRUD operations work
- [ ] Custom actions work
- [ ] Authorization works

---

# Phase 5: Testing & Quality

## 5.1 Testing Strategy

| Test Type | Tool | Coverage Target |
|-----------|------|-----------------|
| Unit Tests | Jest | 80% handlers |
| Integration | CAP Test Utils | All endpoints |
| E2E | Playwright/Cypress | Critical paths |
| Performance | k6/JMeter | Load scenarios |

### AI Prompt: Test Suite Generation

```
Create a test suite for SAP CAP service [SERVICE NAME].

Test scenarios needed:
1. CRUD operations for [Entity]
2. Custom action: [Action name]
3. Validation: [Validation rules]
4. Authorization: [Role-based tests]

Please include:
- Jest configuration
- Test fixtures/mock data
- Unit tests for handlers
- Integration tests for OData endpoints
- Error case testing
- Authorization testing

Output: Complete test file structure with tests.
```

## 5.2 Code Quality

```bash
# ESLint for JavaScript
npm install --save-dev eslint

# Prettier for formatting
npm install --save-dev prettier
```

## 5.3 Project Checklist - Phase 5

- [ ] Unit tests written and passing
- [ ] Integration tests passing
- [ ] Code coverage meets target
- [ ] ESLint passes
- [ ] No security vulnerabilities
- [ ] Performance benchmarks met
- [ ] UAT completed and signed off

---

# Phase 6: Deployment & Operations

## 6.1 Build Configuration

### mta.yaml Structure

```yaml
_schema-version: "3.2"
ID: my-project
version: 1.0.0

modules:
  - name: my-project-srv
    type: nodejs
    path: gen/srv
    requires:
      - name: my-project-db
      - name: my-project-auth
    provides:
      - name: srv-api
        properties:
          srv-url: ${default-url}

  - name: my-project-db-deployer
    type: hdb
    path: gen/db
    requires:
      - name: my-project-db

resources:
  - name: my-project-db
    type: com.sap.xs.hdi-container

  - name: my-project-auth
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
```

## 6.2 Deployment

```bash
# Build for production
cds build --production

# Build MTA archive
mbt build

# Deploy to Cloud Foundry
cf deploy mta_archives/my-project_1.0.0.mtar
```

## 6.3 Monitoring & Operations

- SAP Application Logging
- SAP Alert Notification Service
- SAP Cloud ALM

## 6.4 Project Checklist - Phase 6

- [ ] mta.yaml configured
- [ ] xs-security.json configured
- [ ] Build succeeds
- [ ] Dev deployment tested
- [ ] Production deployment done
- [ ] Monitoring configured
- [ ] Runbook created
- [ ] Handover completed

---

# Templates & Checklists

## Complete Phase Checklist

### Pre-Development (Phases 0-2)
- [ ] Project idea defined
- [ ] Stakeholders identified
- [ ] Governance framework established
- [ ] RACI matrix defined
- [ ] Requirements gathered
- [ ] User stories documented
- [ ] Solution architecture approved
- [ ] Data architecture approved
- [ ] API design approved
- [ ] Security design approved

### Development (Phases 3-4)
- [ ] CDS schemas created
- [ ] Services defined
- [ ] Handlers implemented
- [ ] UI annotations added
- [ ] Local testing complete

### Deployment (Phases 5-6)
- [ ] All tests passing
- [ ] UAT signed off
- [ ] Production deployed
- [ ] Documentation complete
- [ ] Team trained

---

# AI Prompts for Each Phase

## Phase 0: Project Inception

```
I'm starting a new enterprise application project.

Project idea: [Describe your idea]
Business problem: [What problem does it solve]
Target users: [Who will use it]

Please help me:
1. Refine the project scope
2. Identify key stakeholders
3. List potential risks
4. Suggest initial folder structure
5. Create a project brief document

Format: Structured project brief document.
```

## Phase 1: Governance Setup

```
Create project governance documents for [PROJECT NAME].

Project type: SAP CAP enterprise application
Team structure: [Describe team]
Development approach: [Agile/Waterfall/Hybrid]

Generate the following documents:
1. GOVERNANCE.md - Project governance framework
2. RACI.md - Roles and responsibilities matrix
3. DESIGN_DECISIONS.md - Decision log template
4. PROJECT_TRACKER.md - Progress tracking template

Include:
- Approval gates
- Session protocols
- Escalation paths
- Communication guidelines

Format: Complete markdown documents.
```

## Phase 2: Architecture Design

```
Create architecture documentation for [PROJECT NAME].

Business context: [Describe business]
Key requirements: [List requirements]
Technical constraints: [List constraints]

Generate:
1. Solution Architecture Document
2. Data Architecture Document
3. API Design Document
4. Security Specification

Technology stack:
- SAP BTP
- SAP CAP (Node.js)
- SAP HANA Cloud
- SAP Fiori Elements

Format: Enterprise architecture documents.
```

## Phase 3: Data Modeling

```
Create SAP CAP data model for [PROJECT NAME].

Domain: [Business domain]
Key entities: [List entities with descriptions]
Relationships: [Describe relationships]

Generate:
1. CDS schema files organized by domain
2. Common types and aspects
3. Sample data CSV files
4. Data dictionary documentation

Requirements:
- Use SAP CAP best practices
- Include validation annotations
- Add proper indexes
- Use appropriate aspects (cuid, managed)

Format: Complete CDS files and CSV data.
```

## Phase 4: Implementation

```
Implement SAP CAP services for [PROJECT NAME].

Based on the data model with entities:
[List entities]

Generate:
1. Service definitions (.cds)
2. Service handlers (.js)
3. UI annotations for Fiori Elements
4. index.cds to import all

Requirements:
- Enable CRUD operations
- Implement custom actions: [list actions]
- Add proper authorization
- Enable draft for: [list entities]

Format: Complete service implementation files.
```

## Phase 5: Testing

```
Create test suite for [SERVICE NAME].

Entities: [List entities]
Custom actions: [List actions]
Business rules: [List rules]

Generate:
1. Jest configuration
2. Unit tests for handlers
3. Integration tests for OData
4. Mock data fixtures
5. Test coverage report setup

Requirements:
- Minimum 80% coverage
- Test all CRUD operations
- Test authorization
- Test error cases

Format: Complete test files with configuration.
```

## Phase 6: Deployment

```
Create deployment configuration for [PROJECT NAME].

Target platform: SAP BTP Cloud Foundry
Services needed:
- HANA Cloud database
- XSUAA authentication
- [Other services]

Generate:
1. mta.yaml configuration
2. xs-security.json
3. .cdsrc.json for production
4. Deployment scripts
5. CI/CD pipeline configuration

Format: Complete deployment configuration files.
```

---

*Template Version: 1.0*
*Last Updated: January 2026*
*Covers: SAP CAP 8.x, SAP BTP*
