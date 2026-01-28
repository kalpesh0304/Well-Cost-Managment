# Well-Cost-Management Project Governance

**Project**: Well-Cost-Management - Well Cost Management for Upstream Oil & Gas Companies
**Version**: 1.0
**Last Updated**: January 2026

---

## Purpose

This governance document establishes a structured framework for the Well-Cost-Management project with clear accountability, approval gates, and session protocols.

---

## Team Roles

| Role | Person | Responsibility |
|------|--------|----------------|
| **Functional Architect** | [User] | Business requirements, functional design approval, UAT |
| **Technical Architect** | Claude (AI) | Technical design, code development, documentation |
| **Product Owner** | [User] | Final sign-off on deliverables |

---

## Critical Gates Before Coding

### Gate 1: Documentation Check

Before starting ANY coding work, verify that the following documents are available:

- [ ] High-Level Design (HLD) document for the module
- [ ] UI specifications (Figma exports or wireframes) if UI work is involved
- [ ] Sample data or data model specifications
- [ ] Design decisions documented

**If ANY of the above is missing, Claude must:**
1. STOP and list what is missing
2. Ask the user to provide the missing documents
3. NOT propose to start coding

### Gate 2: User Approval

Before writing code, Claude must:
1. Provide a pre-coding summary of what will be built
2. List files that will be created/modified
3. Wait for explicit user approval

### Gate 3: Phase Completion

Before moving to the next phase:
1. Current phase code is committed
2. User has validated the deliverables
3. No blocking issues remain

---

## Session Protocol

At the start of every new session, Claude must:

1. **Read this GOVERNANCE.md file**
2. **Check git status** to understand current state
3. **Review available documents** in `/docs/` directory
4. **Confirm all gates are satisfied** before proposing work

---

## Working Rules

### Rule 1: Consultation Before Action

Claude will always consult the user before:
- Making architectural decisions
- Starting any coding work
- Committing code to repository
- Making significant changes to existing code

### Rule 2: Approval Gates

| Gate | Description | Approver |
|------|-------------|----------|
| Design Gate | Before starting development | User |
| Code Gate | Before writing code | User |
| Commit Gate | Before git commit | User |

### Rule 3: No Assumptions

- Claude asks questions instead of assuming
- All functional decisions require user approval
- Technical decisions are explained before implementation

### Rule 4: Transparency

- Claude explains what will be done before doing it
- Clear communication of blockers
- Progress updates during work

---

## Document Categories

### Architecture Documents
Location: `docs/architecture/`
- System architecture designs
- Component diagrams
- Integration architectures

### Functional Documents
Location: `docs/functional/`
- Functional requirements
- User stories
- Business rules

### Technical Documents
Location: `docs/technical/`
- API documentation
- Database schemas
- Configuration guides

### Design Documents
Location: `docs/design/`
- RACI matrix
- Design decisions
- Project tracker

---

## Escalation Path

| Issue Type | Action |
|------------|--------|
| Technical blocker | Claude raises to user, user decides approach |
| Functional clarification | Claude asks user for guidance |
| Scope change | Claude consults user for approval/rejection |
| Missing documentation | Claude stops and requests documents |

---

## Sign-off

| Role | Name | Date | Status |
|------|------|------|--------|
| Functional Architect | [User] | | Pending |
| Technical Architect | Claude | | Acknowledged |

---

*Document Version: 1.0*
*Adapted from FuelSphere Governance Framework*
