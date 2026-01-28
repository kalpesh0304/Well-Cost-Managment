# SAP CAP Component Generation Prompts

Quick reference for AI prompts to generate each SAP CAP component. Copy and customize these prompts for your project.

---

## 1. Database Schema Prompt

```
Create a SAP CAP CDS database schema for [YOUR DOMAIN].

Requirements:
1. Domain: [Describe your business domain, e.g., "Well Cost Management for Oil & Gas"]
2. Main Entities: [List main entities, e.g., "Wells, AFEs, Cost Items, Vendors"]
3. Relationships: [Describe relationships, e.g., "AFE belongs to Well, Cost Items belong to AFE"]

Please include:
- Entity definitions with appropriate data types
- Use SAP CAP aspects: cuid (for UUIDs), managed (for audit fields), temporal (if needed)
- Associations and Compositions for relationships
- Enums for status fields and types
- Custom types for reusable fields (amounts, codes, etc.)
- Proper indexing hints for frequently queried fields
- Comments/documentation for each entity

Technical constraints:
- Use @sap/cds version 8.x compatible syntax
- Follow SAP naming conventions (PascalCase for entities, camelCase for fields)
- Include validation constraints where appropriate
- Organize into logical namespaces (e.g., namespace my.domain)

Output format: Complete .cds file(s) with all entity definitions.
```

---

## 2. Service Definition Prompt

```
Create SAP CAP CDS service definitions for [YOUR DOMAIN].

Requirements:
1. Services needed: [List services, e.g., "CatalogService for browsing, AdminService for management"]
2. Base schema namespace: [e.g., "my.bookshop"]
3. Entity projections: [Which entities each service should expose]
4. Authorization: [e.g., "Admin role for AdminService, authenticated for CatalogService"]

Please include:
- Service definitions with @path annotations
- Entity projections with appropriate field selections
- @readonly, @insertonly annotations where needed
- @odata.draft.enabled for entities requiring draft mode
- Custom actions with parameters and return types
- Custom functions for read operations
- @requires annotations for role-based access
- Redirected associations for proper navigation
- Bound actions on specific entities

Technical requirements:
- Use OData V4 conventions
- Follow RESTful naming (plural for collections)
- Include proper typing for action/function parameters
- Group related operations logically

Output format: Complete service .cds file(s).
```

---

## 3. Service Handler Prompt

```
Create SAP CAP JavaScript service handlers for [SERVICE NAME].

Requirements:
1. Service name: [e.g., "AdminService"]
2. Entities to handle: [List entities needing custom logic]
3. Business rules: [Describe validation rules, calculations, etc.]
4. Custom actions: [Describe what each action should do]

Please include:
- module.exports = cds.service.impl pattern
- before handlers for validation
- after handlers for calculations and enrichment
- on handlers for custom actions and functions
- Proper error handling with req.error() and req.reject()
- Transaction handling where needed
- Logging for debugging
- Comments explaining business logic

Handler types needed:
- CREATE: [validation rules, auto-generated fields]
- READ: [filtering, authorization]
- UPDATE: [validation, status transitions]
- DELETE: [soft delete, cascade rules]
- Actions: [specific action implementations]

Technical requirements:
- Use async/await pattern
- Use cds.log for logging
- Use req.user for authorization context
- Handle draft-enabled entities properly
- Include JSDoc comments

Output format: Complete .js handler file.
```

---

## 4. UI Annotations Prompt

```
Create SAP CAP UI annotations for SAP Fiori Elements for [SERVICE NAME].

Requirements:
1. Service: [Service name to annotate]
2. Entities: [List entities needing UI annotations]
3. List Report columns: [Which fields to show in table]
4. Filter fields: [Which fields for filtering]
5. Object page layout: [Sections and field groups]

Please include:
- @Capabilities annotations for CRUD operations
- @UI.HeaderInfo for page titles
- @UI.SelectionFields for filter bar
- @UI.LineItem for table columns
- @UI.Facets for object page structure
- @UI.FieldGroup for form sections
- @UI.Hidden for technical fields
- @title annotations for field labels
- Value helps where appropriate

UI requirements:
- List report: [columns, sorting, default filters]
- Object page: [header fields, sections, sub-tables]
- Actions: [which actions to show in toolbar]
- Draft support: [yes/no]

Output format: Complete UI annotation .cds file.
```

---

## 5. Fiori App Configuration Prompt

```
Create SAP Fiori Elements application configuration for [APP NAME].

Requirements:
1. App type: [List Report, Worklist, Overview Page, etc.]
2. Main entity: [Primary entity to display]
3. Navigation: [Target entities for drill-down]
4. Service path: [OData service URL]

Please include:
- manifest.json with all required configurations
- Component.js for UI5 component
- Routing configuration for navigation
- i18n placeholder files
- Index.html for standalone testing

Configuration details:
- Data source: [OData V4 service URL]
- Default filters: [Initial filter values]
- Table settings: [Selection mode, growing threshold]
- Object page: [Edit mode, sections]
- Custom actions: [Button configurations]

Output format: Complete app folder structure with all files.
```

---

## 6. Authentication & Authorization Prompt

```
Create SAP CAP authentication and authorization configuration for [YOUR APP].

Requirements:
1. Authentication type: [XSUAA, IAS, mock]
2. Roles needed: [List roles, e.g., "Admin, Manager, Viewer"]
3. Scopes: [What each role can do]
4. Entity restrictions: [Which entities/operations per role]

Please include:
- xs-security.json with scopes and role templates
- Package.json cds.requires configuration
- @requires annotations on services
- @restrict annotations on entities/actions
- Mock users for local development

Authorization patterns:
- Role-based access to services
- Instance-based authorization (row-level security)
- Attribute-based access control if needed

Output format: Complete auth configuration files.
```

---

## 7. HANA Deployment Prompt

```
Create SAP HANA Cloud deployment configuration for [YOUR CAP APP].

Requirements:
1. Database artifacts: [Tables, views, procedures needed]
2. HDI container name: [Container identifier]
3. Synonyms: [Cross-container access if needed]

Please include:
- mta.yaml for multi-target application
- db/src folder structure for HANA artifacts
- .hdinamespace and .hdiconfig files
- Calculation views if needed
- Stored procedures if needed
- User-defined functions if needed

Deployment specifics:
- Memory allocation
- Schema mapping
- Development vs production settings

Output format: Complete HANA deployment configuration.
```

---

## 8. Testing Prompt

```
Create test suite for SAP CAP service [SERVICE NAME].

Requirements:
1. Service to test: [Service name]
2. Entities to test: [List entities]
3. Test scenarios: [CRUD operations, custom actions, edge cases]

Please include:
- Jest configuration for CAP testing
- Unit tests for handlers
- Integration tests for OData endpoints
- Mock data for testing
- Test coverage for:
  - Successful CRUD operations
  - Validation error handling
  - Authorization checks
  - Custom action/function behavior

Technical requirements:
- Use @sap/cds testing utilities
- Proper test isolation
- Async/await patterns
- Clear test descriptions

Output format: Complete test files with Jest configuration.
```

---

## 9. Complete Project Prompt (All-in-One)

```
Create a complete SAP CAP application for [YOUR DOMAIN].

Project Overview:
1. Domain: [Describe business domain]
2. Main Features: [List key features]
3. User Roles: [List roles and permissions]
4. Integration needs: [External systems if any]

Required Components:
1. Database Schema (db/)
   - Entities: [List all entities with relationships]
   - Enums and types needed
   - Initial seed data

2. Services (srv/)
   - Service names and their purposes
   - Which entities each exposes
   - Custom actions/functions needed

3. Handlers (srv/*.js)
   - Validation rules
   - Business logic
   - Calculations

4. UI Annotations (srv/*-ui.cds)
   - List report configurations
   - Object page layouts
   - Action buttons

5. Configuration
   - Package.json with dependencies
   - Authentication setup
   - Deployment configuration

Technical Requirements:
- SAP CAP v8.x
- OData V4
- SQLite for development
- HANA for production
- XSUAA authentication

Output format: Complete project structure with all files.
```

---

## Usage Tips

1. **Be Specific** - The more detail you provide, the better the output
2. **Iterate** - Start with basic prompts, then refine
3. **Review Output** - Always validate generated code
4. **Customize** - Adapt templates to your naming conventions
5. **Test Incrementally** - Build and test each component before moving on

---

## Example: Well Cost Management

Here's how to customize the schema prompt for this project:

```
Create a SAP CAP CDS database schema for Well Cost Management.

Requirements:
1. Domain: Oil & Gas well cost tracking and management
2. Main Entities:
   - Fields (oil/gas fields)
   - Wells (individual wells within fields)
   - AFEs (Authorization for Expenditure)
   - Cost Categories and Elements
   - Vendors and Partners
   - Cost Actuals and Estimates
   - Daily Reports

3. Relationships:
   - Field has many Wells
   - Well has many AFEs
   - AFE has many Line Items (WBS structure)
   - Cost Actual references AFE Line Item
   - Partner Interest references Well

Please include:
- Currency handling with SAP Currency type
- Status enums: draft, submitted, approved, rejected, closed
- Audit trail with managed aspect
- Percentage fields for partner interests
- Amount calculations
- Date tracking for milestones

Output format: Organized into multiple .cds files by domain (master-data, afe, financial, operations)
```

---

*Quick Reference Version: 1.0*
*For full documentation, see: SAP-CAP-BUILD-GUIDE.md*
