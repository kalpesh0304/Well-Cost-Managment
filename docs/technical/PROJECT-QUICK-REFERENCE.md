# SAP CAP Project Quick Reference Card

A one-page summary of all phases, deliverables, and AI prompts.

---

## Phase Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SAP CAP PROJECT LIFECYCLE                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Phase 0          Phase 1          Phase 2          Phase 3                 │
│  ────────         ────────         ────────         ────────                │
│  INCEPTION   →    GOVERNANCE  →    ARCHITECTURE →   DATA MODEL              │
│  - Idea           - RACI           - Solution       - CDS Schemas           │
│  - Scope          - Governance     - Data           - Types                 │
│  - Folders        - Requirements   - API            - Relationships         │
│  - README         - User Stories   - Security       - Sample Data           │
│                                                                             │
│         ↓                                                                   │
│                                                                             │
│  Phase 4          Phase 5          Phase 6                                  │
│  ────────         ────────         ────────                                 │
│  IMPLEMENTATION   TESTING     →    DEPLOYMENT                               │
│  - Services       - Unit Tests     - mta.yaml                               │
│  - Handlers       - Integration    - xs-security                            │
│  - UI Annotations - UAT            - CI/CD                                  │
│  - CRUD + Actions - Coverage       - Monitoring                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase Deliverables Checklist

| Phase | Key Deliverables | Approval Gate |
|-------|------------------|---------------|
| **0** | README, Folder structure, Project brief | Scope sign-off |
| **1** | GOVERNANCE.md, RACI.md, Requirements | Stakeholder approval |
| **2** | Architecture docs (Solution, Data, API, Security) | Design review |
| **3** | CDS schemas, Types, Sample data | Schema compilation |
| **4** | Services, Handlers, UI annotations | `cds watch` works |
| **5** | Tests (80%+ coverage), UAT | QA sign-off |
| **6** | mta.yaml, Deployment, Documentation | Go-live approval |

---

## Folder Structure

```
my-project/
├── docs/
│   ├── architecture/        # Solution, Data, API, Security docs
│   ├── functional/          # Requirements, User stories
│   ├── technical/           # Technical specs, Guides
│   └── design/              # RACI, Decisions, Tracker
├── db/
│   ├── *.cds                # Data model schemas
│   └── data/*.csv           # Initial data
├── srv/
│   ├── *-service.cds        # Service definitions
│   ├── *-service.js         # Handlers
│   └── *-service-ui.cds     # UI annotations
├── app/                     # UI applications
├── test/                    # Test files
├── GOVERNANCE.md
├── CLAUDE.md
└── package.json
```

---

## Quick AI Prompts

### 1. Project Setup (Phase 0-1)

```
Create project governance and structure for [PROJECT NAME].

Domain: [describe domain]
Team: [describe team]
Purpose: [describe purpose]

Generate: GOVERNANCE.md, RACI.md, DESIGN_DECISIONS.md, PROJECT_TRACKER.md, folder structure.
```

### 2. Architecture (Phase 2)

```
Create architecture documents for [PROJECT NAME].

Requirements: [list key requirements]
Constraints: SAP BTP, CAP, HANA, Fiori Elements
Integrations: [list external systems]

Generate: Solution Architecture, Data Architecture, API Design, Security Spec.
```

### 3. Data Model (Phase 3)

```
Create SAP CAP CDS schemas for [PROJECT NAME].

Entities:
1. [Entity]: [fields and purpose]
2. [Entity]: [fields and purpose]

Relationships: [describe]
Requirements: Use cuid, managed, enums, proper types.

Generate: Complete .cds schema files with sample CSV data.
```

### 4. Services (Phase 4)

```
Create SAP CAP services for [PROJECT NAME].

Schema namespace: [namespace]
Services:
1. [Service]: [entities, auth, purpose]
2. [Service]: [entities, auth, purpose]

Generate: service.cds, service.js handlers, UI annotations.
Include: CRUD, custom actions, validation, draft support.
```

### 5. Testing (Phase 5)

```
Create test suite for [SERVICE NAME].

Test: [list entities and actions]
Rules: [list business rules to test]

Generate: Jest config, unit tests, integration tests, 80%+ coverage.
```

### 6. Deployment (Phase 6)

```
Create deployment config for [PROJECT NAME].

Platform: SAP BTP Cloud Foundry
Services: HANA, XSUAA, [others]

Generate: mta.yaml, xs-security.json, deployment scripts.
```

---

## Essential Commands

```bash
# Initialize project
cds init my-project

# Run locally
cds watch

# Add features
cds add hana
cds add xsuaa
cds add mta

# Build
cds build --production
mbt build

# Deploy
cf deploy mta_archives/*.mtar

# Test
npm test
```

---

## Key CDS Patterns

```cds
// Entity with aspects
entity Items : cuid, managed {
  name   : String(100) @mandatory;
  status : Status default 'DRAFT';
  parent : Association to Parents;
  items  : Composition of many SubItems on items.parent = $self;
}

// Enum type
type Status : String enum { DRAFT; ACTIVE; CLOSED; }

// Service with draft
@path: '/api/main'
@requires: 'authenticated-user'
service MainService {
  @odata.draft.enabled
  entity Items as projection on db.Items actions {
    action activate() returns Items;
  };
}

// UI annotations
annotate MainService.Items with @(
  Capabilities: { InsertRestrictions: { Insertable: true } },
  UI.LineItem: [{ Value: name }, { Value: status }]
);
```

---

## Key Handler Patterns

```javascript
module.exports = cds.service.impl(async function() {
  const { Items } = this.entities;

  // Validation
  this.before('CREATE', Items, async (req) => {
    if (!req.data.name) req.error(400, 'Name required', 'name');
  });

  // Enrichment
  this.after('READ', Items, (items) => {
    items.forEach(i => i.computed = calculate(i));
  });

  // Custom action
  this.on('activate', Items, async (req) => {
    const { ID } = req.params[0];
    await UPDATE(Items).set({ status: 'ACTIVE' }).where({ ID });
    return SELECT.one.from(Items).where({ ID });
  });
});
```

---

## Gate Checklist

Before each phase transition:

- [ ] All deliverables complete
- [ ] Documentation updated
- [ ] Code committed
- [ ] Tests passing
- [ ] Stakeholder approval obtained
- [ ] No blocking issues

---

*Quick Reference v1.0 | January 2026*
