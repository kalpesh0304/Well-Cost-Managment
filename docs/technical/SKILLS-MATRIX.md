# SAP CAP Project Skills Matrix

A comprehensive skills reference documenting the competencies required for building enterprise SAP CAP applications.

---

## Table of Contents

1. [Technical Skills](#1-technical-skills)
2. [Tools & Technologies](#2-tools--technologies)
3. [Process Skills](#3-process-skills)
4. [AI & Automation Skills](#4-ai--automation-skills)
5. [Skills by Project Phase](#5-skills-by-project-phase)
6. [Learning Path](#6-learning-path)
7. [Skills Assessment Checklist](#7-skills-assessment-checklist)

---

## 1. Technical Skills

### 1.1 Core Development Skills

| Skill | Level Required | Description |
|-------|----------------|-------------|
| **CDS (Core Data Services)** | Advanced | Data modeling, service definitions, annotations |
| **JavaScript/Node.js** | Intermediate | Service handlers, async programming, ES6+ |
| **SQL** | Intermediate | Query optimization, joins, aggregations |
| **OData V4** | Intermediate | Protocol understanding, query options |
| **JSON** | Basic | Configuration, data exchange |
| **YAML** | Basic | MTA configuration, CI/CD pipelines |

### 1.2 CDS Specific Skills

```
CDS Skills Breakdown:
├── Data Modeling
│   ├── Entity definitions
│   ├── Types and enums
│   ├── Aspects (cuid, managed, temporal)
│   ├── Associations (1:1, 1:N, M:N)
│   ├── Compositions (parent-child)
│   └── Virtual elements
│
├── Service Definitions
│   ├── Entity projections
│   ├── Field selections/exclusions
│   ├── Custom actions (bound/unbound)
│   ├── Custom functions
│   ├── Redirected associations
│   └── Authorization annotations
│
└── UI Annotations
    ├── Capabilities (CRUD restrictions)
    ├── UI.HeaderInfo
    ├── UI.LineItem
    ├── UI.Facets
    ├── UI.FieldGroup
    ├── UI.SelectionFields
    └── Common.ValueList
```

### 1.3 JavaScript Handler Skills

| Skill | Description | Example Use |
|-------|-------------|-------------|
| Event Hooks | before/on/after handlers | Validation, enrichment |
| Async/Await | Asynchronous programming | Database operations |
| CDS Query Builder | SELECT, INSERT, UPDATE, DELETE | Data manipulation |
| Error Handling | req.error(), req.reject() | User feedback |
| Transaction Management | cds.tx() | Multi-step operations |
| Logging | cds.log() | Debugging, audit |

### 1.4 Database Skills

| Skill | SAP HANA | SQLite (Dev) |
|-------|----------|--------------|
| Table Design | ✓ | ✓ |
| Indexes | ✓ | ✓ |
| Views | ✓ | ✓ |
| Stored Procedures | ✓ | - |
| Calculation Views | ✓ | - |
| Full-text Search | ✓ | - |

### 1.5 Frontend Skills

| Skill | Level | Description |
|-------|-------|-------------|
| SAP Fiori Elements | Intermediate | Annotation-driven UI |
| SAP UI5 | Basic | Custom extensions |
| XML Views | Basic | UI structure |
| OData Model Binding | Basic | Data binding |

---

## 2. Tools & Technologies

### 2.1 Development Tools

| Tool | Purpose | Proficiency Required |
|------|---------|---------------------|
| **VS Code** | IDE | Intermediate |
| **SAP Business Application Studio** | Cloud IDE | Intermediate |
| **CDS CLI** | Development commands | Advanced |
| **npm** | Package management | Intermediate |
| **Git** | Version control | Intermediate |

### 2.2 SAP BTP Services

| Service | Purpose | Skills Needed |
|---------|---------|---------------|
| **SAP HANA Cloud** | Database | SQL, HDI containers |
| **XSUAA** | Authentication | OAuth, JWT, roles |
| **SAP Destination** | Connectivity | Configuration |
| **SAP Event Mesh** | Messaging | Pub/Sub patterns |
| **SAP Work Zone** | Launchpad | App integration |

### 2.3 DevOps Tools

| Tool | Purpose |
|------|---------|
| **Cloud Foundry CLI** | Deployment |
| **MBT (MTA Build Tool)** | Build artifacts |
| **SAP CI/CD** | Pipeline automation |
| **Jest** | Unit testing |
| **Postman/Insomnia** | API testing |

### 2.4 Technology Stack Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  SAP Fiori Elements │ SAP UI5 │ Custom Web Apps             │
├─────────────────────────────────────────────────────────────┤
│                      SERVICE LAYER                           │
│  SAP CAP (Node.js) │ OData V4 │ REST APIs                   │
├─────────────────────────────────────────────────────────────┤
│                     PERSISTENCE LAYER                        │
│  SAP HANA Cloud │ SQLite (Dev) │ PostgreSQL                 │
├─────────────────────────────────────────────────────────────┤
│                     PLATFORM LAYER                           │
│  SAP BTP │ Cloud Foundry │ Kubernetes                       │
├─────────────────────────────────────────────────────────────┤
│                     SECURITY LAYER                           │
│  XSUAA │ SAP IAS │ OAuth 2.0 │ JWT                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Process Skills

### 3.1 Project Management

| Skill | Application |
|-------|-------------|
| **Requirements Gathering** | User stories, acceptance criteria |
| **Agile/Scrum** | Sprint planning, backlog management |
| **Documentation** | Architecture docs, technical specs |
| **Stakeholder Management** | Communication, approvals |
| **Risk Management** | Identification, mitigation |

### 3.2 Architecture Skills

| Skill | Deliverable |
|-------|-------------|
| **Solution Architecture** | High-level system design |
| **Data Architecture** | Entity relationships, data flow |
| **API Design** | Service contracts, OData design |
| **Security Architecture** | Auth/authz design |
| **Integration Architecture** | System connectivity |

### 3.3 Documentation Skills

| Document Type | Skills Required |
|---------------|-----------------|
| Architecture Documents | Technical writing, diagramming |
| Functional Specs | Business analysis, UML |
| Technical Specs | API documentation, code comments |
| User Guides | Clear communication, screenshots |
| Runbooks | Operational procedures |

---

## 4. AI & Automation Skills

### 4.1 AI-Assisted Development

| Skill | Application |
|-------|-------------|
| **Prompt Engineering** | Crafting effective AI prompts |
| **Code Generation** | Using AI to generate boilerplate |
| **Documentation Generation** | AI-assisted doc creation |
| **Code Review** | AI-assisted code analysis |
| **Testing** | AI-generated test cases |

### 4.2 Effective Prompting Techniques

```
Prompt Structure for Code Generation:
┌─────────────────────────────────────────────────────────────┐
│ 1. CONTEXT                                                  │
│    - Project type and technology stack                      │
│    - Current state of the codebase                         │
│                                                             │
│ 2. REQUIREMENTS                                             │
│    - Specific functionality needed                          │
│    - Business rules and constraints                        │
│                                                             │
│ 3. TECHNICAL SPECIFICATIONS                                 │
│    - Frameworks and versions                                │
│    - Coding standards and patterns                         │
│                                                             │
│ 4. OUTPUT FORMAT                                            │
│    - File structure expected                                │
│    - Code style preferences                                │
│                                                             │
│ 5. EXAMPLES (Optional)                                      │
│    - Similar code patterns                                  │
│    - Expected output samples                               │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 AI Prompt Categories

| Category | Use Case | Example Prompt Start |
|----------|----------|---------------------|
| **Schema Design** | Data modeling | "Create SAP CAP CDS schema for..." |
| **Service Definition** | API design | "Create service definitions exposing..." |
| **Handler Implementation** | Business logic | "Implement handlers for... with validation..." |
| **UI Annotations** | Fiori configuration | "Create UI annotations for Fiori Elements..." |
| **Testing** | Test generation | "Create Jest tests for..." |
| **Documentation** | Doc generation | "Create architecture document for..." |

---

## 5. Skills by Project Phase

### Phase 0: Project Inception

| Skill | Level | Application |
|-------|-------|-------------|
| Business Analysis | Basic | Problem definition |
| Scope Definition | Intermediate | Boundary setting |
| Project Setup | Basic | Folder structure, Git |

### Phase 1: Requirements & Governance

| Skill | Level | Application |
|-------|-------|-------------|
| Requirements Engineering | Intermediate | User stories |
| Process Design | Basic | RACI, governance |
| Documentation | Intermediate | Requirement docs |

### Phase 2: Architecture & Design

| Skill | Level | Application |
|-------|-------|-------------|
| Solution Architecture | Advanced | System design |
| Data Modeling | Advanced | Entity design |
| API Design | Intermediate | Service contracts |
| Security Design | Intermediate | Auth/Authz |

### Phase 3: Data Modeling

| Skill | Level | Application |
|-------|-------|-------------|
| CDS Modeling | Advanced | Schema creation |
| Database Design | Intermediate | Normalization |
| Data Validation | Intermediate | Constraints |

### Phase 4: Implementation

| Skill | Level | Application |
|-------|-------|-------------|
| CDS Services | Advanced | Service definitions |
| JavaScript | Intermediate | Handlers |
| UI Annotations | Intermediate | Fiori config |
| OData | Intermediate | Protocol usage |

### Phase 5: Testing

| Skill | Level | Application |
|-------|-------|-------------|
| Unit Testing | Intermediate | Jest tests |
| Integration Testing | Intermediate | OData tests |
| API Testing | Basic | Postman |

### Phase 6: Deployment

| Skill | Level | Application |
|-------|-------|-------------|
| MTA Configuration | Intermediate | mta.yaml |
| Cloud Foundry | Intermediate | cf commands |
| CI/CD | Basic | Pipeline setup |

---

## 6. Learning Path

### 6.1 Beginner Path (0-3 months)

```
Week 1-2: Fundamentals
├── JavaScript basics
├── Node.js fundamentals
├── SQL basics
└── Git essentials

Week 3-4: SAP CAP Basics
├── CDS language basics
├── Simple data models
├── Basic services
└── cds watch workflow

Week 5-8: Intermediate CAP
├── Complex data models
├── Service handlers
├── UI annotations basics
└── Local testing

Week 9-12: Integration
├── HANA deployment
├── Authentication basics
├── Simple Fiori apps
└── First deployment
```

### 6.2 Intermediate Path (3-6 months)

```
Month 4: Advanced Data Modeling
├── Complex associations
├── Compositions
├── Calculated elements
└── Full-text search

Month 5: Advanced Services
├── Custom actions/functions
├── Event handling
├── Transaction management
└── Error handling

Month 6: Production Readiness
├── Security hardening
├── Performance optimization
├── CI/CD pipelines
└── Monitoring setup
```

### 6.3 Advanced Path (6-12 months)

```
Months 7-9: Enterprise Patterns
├── Multi-tenancy
├── Extensibility
├── Event-driven architecture
└── Microservices patterns

Months 10-12: Mastery
├── Custom HANA artifacts
├── Complex integrations
├── Performance tuning
└── Architecture leadership
```

### 6.4 Recommended Resources

| Resource | Type | Topic |
|----------|------|-------|
| SAP CAP Documentation | Official Docs | All CAP topics |
| SAP Learning Journey | Course | CAP fundamentals |
| SAP Community | Forum | Q&A, best practices |
| GitHub SAP Samples | Code | Reference implementations |
| openSAP | Course | Free online courses |

---

## 7. Skills Assessment Checklist

### 7.1 Self-Assessment Matrix

Rate yourself: 1 (None) | 2 (Basic) | 3 (Intermediate) | 4 (Advanced) | 5 (Expert)

#### Core Technical Skills

| Skill | Self Rating | Target | Gap |
|-------|-------------|--------|-----|
| CDS Data Modeling | [ ] | 4 | |
| CDS Services | [ ] | 4 | |
| JavaScript/Node.js | [ ] | 3 | |
| OData V4 | [ ] | 3 | |
| SQL | [ ] | 3 | |
| UI Annotations | [ ] | 3 | |
| SAP Fiori Elements | [ ] | 3 | |

#### Platform Skills

| Skill | Self Rating | Target | Gap |
|-------|-------------|--------|-----|
| SAP HANA Cloud | [ ] | 3 | |
| XSUAA/Auth | [ ] | 3 | |
| Cloud Foundry | [ ] | 2 | |
| MTA/Deployment | [ ] | 3 | |
| SAP BTP | [ ] | 2 | |

#### Process Skills

| Skill | Self Rating | Target | Gap |
|-------|-------------|--------|-----|
| Requirements Analysis | [ ] | 3 | |
| Architecture Design | [ ] | 3 | |
| Documentation | [ ] | 3 | |
| Testing | [ ] | 3 | |
| DevOps | [ ] | 2 | |

### 7.2 Practical Assessment Tasks

#### Task 1: Data Modeling (CDS)
- [ ] Create entity with all data types
- [ ] Define associations and compositions
- [ ] Use aspects (cuid, managed)
- [ ] Create custom types and enums
- [ ] Add validation annotations

#### Task 2: Service Implementation
- [ ] Define service with projections
- [ ] Implement CRUD handlers
- [ ] Create custom action
- [ ] Create custom function
- [ ] Add authorization

#### Task 3: UI Configuration
- [ ] Add Capabilities annotations
- [ ] Configure LineItem
- [ ] Configure HeaderInfo
- [ ] Setup Facets
- [ ] Add value helps

#### Task 4: Deployment
- [ ] Configure mta.yaml
- [ ] Setup xs-security.json
- [ ] Build MTA archive
- [ ] Deploy to Cloud Foundry
- [ ] Verify application

### 7.3 Certification Path

| Certification | Level | Covers |
|---------------|-------|--------|
| SAP Certified Development Associate - SAP Extension Suite | Associate | CAP basics, BTP fundamentals |
| SAP Certified Development Professional - SAP Extension Suite | Professional | Advanced CAP, architecture |

---

## Quick Reference: Skills by Task

| Task | Primary Skills | Secondary Skills |
|------|----------------|------------------|
| Create data model | CDS, SQL, Data modeling | Domain knowledge |
| Build service | CDS, JavaScript | OData, REST |
| Add business logic | JavaScript, CDS | Async programming |
| Configure UI | CDS annotations | Fiori Elements |
| Setup auth | XSUAA, CDS | Security concepts |
| Deploy app | MTA, CF | DevOps, YAML |
| Write tests | Jest, JavaScript | OData, mocking |
| Debug issues | JavaScript, CDS | SQL, logging |

---

*Skills Matrix Version: 1.0*
*Last Updated: January 2026*
*Based on: SAP CAP 8.x, SAP BTP*
