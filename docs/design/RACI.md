# Well-Cost-Management RACI Matrix

**Project**: Well-Cost-Management - Well Cost Management for Upstream Oil & Gas Companies
**Document Version**: 1.0
**Last Updated**: January 2026

---

## Team Roles

| Role | Person | Responsibility |
|------|--------|----------------|
| **Functional Architect** | [User] | Business requirements, functional design approval, UAT, stakeholder management |
| **Technical Architect** | Claude (AI) | Technical design, code development, documentation |
| **Product Owner** | [User] | Final sign-off on deliverables |

---

## RACI Legend

| Code | Meaning | Description |
|------|---------|-------------|
| **R** | Responsible | Does the work |
| **A** | Accountable | Final decision maker, sign-off authority |
| **C** | Consulted | Provides input before decision |
| **I** | Informed | Notified after decision |

---

## 1. Planning & Design Activities

| Activity | User (Functional) | Claude (Technical) |
|----------|-------------------|-------------------|
| Define business requirements | **A, R** | C |
| Approve functional design | **A** | R, C |
| Create HLD documents | **A, R** | C |
| Review HLD documents | **A** | R |
| Technical architecture decisions | C, **A** | R |
| Data model design | C, **A** | R |
| UI/UX design | **A, R** | C |
| API design | C, **A** | R |

---

## 2. Development Activities

| Activity | User (Functional) | Claude (Technical) |
|----------|-------------------|-------------------|
| Project setup | I | **A, R** |
| Code development | C | **A, R** |
| Unit testing | I | **A, R** |
| Code review | C | **R** |
| Code commit & push | **A** | R |
| Documentation | C | **A, R** |

---

## 3. Testing & Deployment

| Activity | User (Functional) | Claude (Technical) |
|----------|-------------------|-------------------|
| Test environment setup | **A** | R |
| Integration testing | **A** | R |
| UAT execution | **A, R** | C |
| Bug fixes | C | **A, R** |
| Deployment | **A** | R |

---

## Working Rules

### Rule 1: Consultation Before Action

Claude will always consult User before:
- Making architectural decisions
- Starting any coding work
- Committing code to repository
- Deploying to any environment

### Rule 2: Approval Gates

| Gate | Description | Approver |
|------|-------------|----------|
| Design Gate | Before starting development | User |
| Code Gate | Before writing code | User |
| Commit Gate | Before git commit | User |

### Rule 3: No Assumptions

- Claude asks questions instead of assuming
- All functional decisions require User's approval
- Technical decisions are explained and approved

### Rule 4: Transparency

- Claude explains what will be done before doing it
- Clear communication of blockers
- Progress updates provided

---

## Escalation Path

| Issue Type | First Contact | Resolution |
|------------|---------------|------------|
| Technical blocker | Claude raises to User | User decides approach |
| Functional clarification | Claude asks User | User provides guidance |
| Scope change | Claude consults User | User approves/rejects |
| Missing documentation | Claude stops work | User provides documents |

---

## Sign-off

| Role | Name | Date | Status |
|------|------|------|--------|
| Functional Architect | [User] | | Pending |
| Technical Architect | Claude | | Acknowledged |

---

*Document Version: 1.0*
*Adapted from FuelSphere RACI Matrix*
