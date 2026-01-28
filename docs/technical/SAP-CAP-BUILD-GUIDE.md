# SAP CAP (Cloud Application Programming Model) - Complete Build Guide

This guide provides a step-by-step process for building SAP CAP projects, including detailed component descriptions and AI prompts for generating each component.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Structure](#2-project-structure)
3. [Step-by-Step Build Process](#3-step-by-step-build-process)
4. [Component Details & Prompts](#4-component-details--prompts)
5. [Best Practices](#5-best-practices)
6. [Common Patterns](#6-common-patterns)

---

## 1. Project Overview

### What is SAP CAP?

SAP Cloud Application Programming Model (CAP) is a framework for building enterprise-grade services and applications. It provides:

- **CDS (Core Data Services)** - A declarative language for defining data models and services
- **Node.js or Java runtime** - For implementing business logic
- **OData V4 protocol** - For RESTful API exposure
- **SAP Fiori Elements** - For automatic UI generation

### Key Benefits

| Feature | Description |
|---------|-------------|
| Declarative | Define what, not how |
| Open Standards | OData, SQL, REST |
| Full Stack | Database to UI |
| Enterprise Ready | Authentication, authorization, multi-tenancy |

---

## 2. Project Structure

```
my-cap-project/
├── app/                    # UI applications (Fiori Elements, custom UIs)
│   ├── webapp/            # Custom UI5 application
│   └── fiori.cds          # Fiori annotations
├── db/                     # Database layer (data models)
│   ├── schema.cds         # Main data model definitions
│   ├── data/              # CSV files for initial data
│   └── src/               # HANA artifacts (if using HANA)
├── srv/                    # Service layer
│   ├── service.cds        # Service definitions
│   ├── service.js         # Service handlers (business logic)
│   └── *-ui.cds           # UI annotations
├── test/                   # Test files
├── package.json           # Node.js dependencies and CDS config
├── .cdsrc.json            # CDS configuration
└── README.md              # Project documentation
```

---

## 3. Step-by-Step Build Process

### Phase 1: Project Initialization

```bash
# Step 1: Install CAP CLI globally
npm install -g @sap/cds-dk

# Step 2: Create new project
cds init my-project

# Step 3: Navigate to project
cd my-project

# Step 4: Install dependencies
npm install
```

### Phase 2: Database Layer (db/)

1. Define domain entities in CDS files
2. Create relationships between entities
3. Add common aspects (managed, cuid, temporal)
4. Prepare initial data (CSV files)

### Phase 3: Service Layer (srv/)

1. Create service definitions exposing entities
2. Implement custom handlers for business logic
3. Add actions and functions
4. Configure authorization

### Phase 4: UI Layer (app/)

1. Add UI annotations for Fiori Elements
2. Configure list reports and object pages
3. Add custom actions and extensions
4. Configure navigation

### Phase 5: Testing & Deployment

1. Run locally with `cds watch`
2. Write unit and integration tests
3. Build for production
4. Deploy to SAP BTP

---

## 4. Component Details & Prompts

### 4.1 Database Schema (db/schema.cds)

#### Description
The database schema defines your data model using CDS (Core Data Services). It includes entities, types, enums, associations, and compositions.

#### Key Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| Entity | A table/collection | `entity Products { ... }` |
| Type | Reusable data type | `type Amount : Decimal(15,2)` |
| Enum | Enumeration values | `type Status : String enum { ... }` |
| Association | Foreign key relationship | `vendor : Association to Vendors` |
| Composition | Parent-child ownership | `items : Composition of many Items` |
| Aspect | Reusable field sets | `aspect managed { ... }` |

#### AI Prompt for Database Schema

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

#### Example Schema

```cds
namespace my.bookshop;

using { cuid, managed } from '@sap/cds/common';

type Status : String enum { draft; active; closed }
type Amount : Decimal(15, 2);

entity Books : cuid, managed {
  title       : String(255) @mandatory;
  description : String(1000);
  price       : Amount;
  currency    : Currency;
  stock       : Integer default 0;
  status      : Status default 'draft';
  author      : Association to Authors;
  genres      : Composition of many BookGenres on genres.book = $self;
}

entity Authors : cuid, managed {
  name    : String(255) @mandatory;
  country : Country;
  books   : Association to many Books on books.author = $self;
}

entity BookGenres : cuid {
  book  : Association to Books;
  genre : Association to Genres;
}

entity Genres : cuid {
  name : String(100) @mandatory;
}
```

---

### 4.2 Service Definitions (srv/service.cds)

#### Description
Service definitions expose your data model as OData services. They define which entities are accessible, with what restrictions, and what custom operations are available.

#### Key Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| Service | OData service container | `service CatalogService { }` |
| Entity Projection | Expose entity with fields | `entity Books as projection on db.Books` |
| @readonly | Read-only entity | `@readonly entity Reports` |
| @insertonly | Create-only entity | `@insertonly entity Logs` |
| Action | Modifying operation | `action approve() returns Boolean` |
| Function | Read-only operation | `function getStats() returns Stats` |

#### AI Prompt for Service Definitions

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

#### Example Service Definition

```cds
using { my.bookshop as db } from '../db/schema';

@path: '/api/catalog'
@requires: 'authenticated-user'
service CatalogService {

  @readonly
  entity Books as projection on db.Books {
    *,
    author.name as authorName
  } excluding { createdBy, modifiedBy };

  @readonly
  entity Authors as projection on db.Authors;

  // Custom function
  function getBooksByGenre(genreId: UUID) returns array of Books;

  // Custom action
  action orderBook(bookId: UUID, quantity: Integer) returns {
    orderId: UUID;
    total: Decimal;
  };
}

@path: '/api/admin'
@requires: 'Admin'
service AdminService {

  @odata.draft.enabled
  entity Books as projection on db.Books {
    *,
    author : redirected to Authors
  } actions {
    action publish() returns Books;
    action archive() returns Books;
  };

  @odata.draft.enabled
  entity Authors as projection on db.Authors {
    *,
    books : redirected to Books
  };

  // Audit logs - read only
  @readonly
  entity AuditLogs as projection on db.AuditLogs;
}
```

---

### 4.3 Service Handlers (srv/service.js)

#### Description
Service handlers implement custom business logic in JavaScript (or Java). They intercept CRUD operations and custom actions/functions.

#### Key Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| before | Pre-processing hook | Validation, enrichment |
| on | Replace default handler | Custom read/write logic |
| after | Post-processing hook | Calculations, notifications |
| srv.emit | Emit events | Messaging, async processing |
| cds.tx | Transaction handling | Database operations |

#### Handler Event Phases

```
Request → before → on → after → Response
              ↓
         Validation    Default    Post-process
         Enrichment    CRUD       Calculations
         Auth checks   Custom     Notifications
```

#### AI Prompt for Service Handlers

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

#### Example Handler

```javascript
const cds = require('@sap/cds');
const LOG = cds.log('admin-service');

module.exports = cds.service.impl(async function() {
  const { Books, Authors } = this.entities;

  // ============================================
  // BOOKS HANDLERS
  // ============================================

  /**
   * Before CREATE - Validate and enrich book data
   */
  this.before('CREATE', Books, async (req) => {
    const { title, price, author_ID } = req.data;

    // Validation
    if (!title || title.trim().length < 3) {
      req.error(400, 'Title must be at least 3 characters', 'title');
    }

    if (price && price < 0) {
      req.error(400, 'Price cannot be negative', 'price');
    }

    // Verify author exists
    if (author_ID) {
      const author = await SELECT.one.from(Authors).where({ ID: author_ID });
      if (!author) {
        req.error(400, `Author with ID ${author_ID} not found`, 'author_ID');
      }
    }

    // Auto-generate fields
    req.data.status = 'draft';

    LOG.info('Creating book:', title);
  });

  /**
   * After READ - Calculate derived fields
   */
  this.after('READ', Books, (books, req) => {
    for (const book of Array.isArray(books) ? books : [books]) {
      if (book) {
        // Calculate availability status
        book.isAvailable = book.stock > 0;

        // Format display price
        if (book.price && book.currency_code) {
          book.displayPrice = `${book.price} ${book.currency_code}`;
        }
      }
    }
  });

  /**
   * Before UPDATE - Validate status transitions
   */
  this.before('UPDATE', Books, async (req) => {
    if (req.data.status) {
      const current = await SELECT.one.from(Books)
        .columns('status')
        .where({ ID: req.data.ID });

      const validTransitions = {
        'draft': ['active'],
        'active': ['closed'],
        'closed': []
      };

      if (!validTransitions[current.status]?.includes(req.data.status)) {
        req.error(400, `Cannot transition from ${current.status} to ${req.data.status}`);
      }
    }
  });

  /**
   * Before DELETE - Check if deletable
   */
  this.before('DELETE', Books, async (req) => {
    const book = await SELECT.one.from(Books)
      .columns('status')
      .where({ ID: req.data.ID });

    if (book.status === 'active') {
      req.error(400, 'Cannot delete active books. Archive them first.');
    }
  });

  // ============================================
  // CUSTOM ACTIONS
  // ============================================

  /**
   * Publish action - Make book active
   */
  this.on('publish', Books, async (req) => {
    const { ID } = req.params[0];

    const book = await SELECT.one.from(Books).where({ ID });

    if (!book) {
      return req.error(404, 'Book not found');
    }

    if (book.status !== 'draft') {
      return req.error(400, 'Only draft books can be published');
    }

    // Validate completeness
    if (!book.price || !book.author_ID) {
      return req.error(400, 'Book must have price and author before publishing');
    }

    await UPDATE(Books).set({ status: 'active' }).where({ ID });

    LOG.info('Published book:', ID);

    return SELECT.one.from(Books).where({ ID });
  });

  /**
   * Archive action - Close book
   */
  this.on('archive', Books, async (req) => {
    const { ID } = req.params[0];

    await UPDATE(Books).set({
      status: 'closed',
      stock: 0
    }).where({ ID });

    LOG.info('Archived book:', ID);

    return SELECT.one.from(Books).where({ ID });
  });

  // ============================================
  // CUSTOM FUNCTIONS
  // ============================================

  /**
   * Get books by genre
   */
  this.on('getBooksByGenre', async (req) => {
    const { genreId } = req.data;

    return SELECT.from(Books)
      .where({ 'genres.genre_ID': genreId })
      .orderBy('title');
  });
});
```

---

### 4.4 UI Annotations (srv/*-ui.cds)

#### Description
UI annotations configure how SAP Fiori Elements renders your data. They define list views, object pages, forms, and CRUD capabilities.

#### Key Annotations

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@UI.HeaderInfo` | Page header configuration | Title, description, icon |
| `@UI.LineItem` | Table columns in list view | Column order, labels |
| `@UI.Facets` | Object page sections | Groups, references |
| `@UI.FieldGroup` | Form field groupings | Related fields together |
| `@UI.SelectionFields` | Filter bar fields | Filterable columns |
| `@Capabilities` | CRUD permissions | Insert, Update, Delete |

#### AI Prompt for UI Annotations

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

#### Example UI Annotations

```cds
using AdminService from './admin-service';

// ============================================
// BOOKS UI ANNOTATIONS
// ============================================
annotate AdminService.Books with @(
  // Enable CRUD in Fiori Elements
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  // Page header configuration
  UI.HeaderInfo: {
    TypeName: 'Book',
    TypeNamePlural: 'Books',
    Title: { Value: title },
    Description: { Value: author.name },
    ImageUrl: coverImageUrl
  },

  // Filter bar fields
  UI.SelectionFields: [
    status,
    author_ID,
    currency_code
  ],

  // Table columns for list report
  UI.LineItem: [
    { Value: title, Label: 'Title' },
    { Value: author.name, Label: 'Author' },
    { Value: price, Label: 'Price' },
    { Value: currency_code, Label: 'Currency' },
    { Value: stock, Label: 'Stock' },
    {
      Value: status,
      Label: 'Status',
      Criticality: statusCriticality
    }
  ],

  // Object page sections
  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralFacet',
      Label: 'General Information',
      Target: '@UI.FieldGroup#General'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'PricingFacet',
      Label: 'Pricing & Stock',
      Target: '@UI.FieldGroup#Pricing'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GenresFacet',
      Label: 'Genres',
      Target: 'genres/@UI.LineItem'
    }
  ],

  // Field groups for forms
  UI.FieldGroup#General: {
    Label: 'General Information',
    Data: [
      { Value: title, Label: 'Title' },
      { Value: description, Label: 'Description' },
      { Value: author_ID, Label: 'Author' },
      { Value: status, Label: 'Status' }
    ]
  },

  UI.FieldGroup#Pricing: {
    Label: 'Pricing & Stock',
    Data: [
      { Value: price, Label: 'Price' },
      { Value: currency_code, Label: 'Currency' },
      { Value: stock, Label: 'Stock' }
    ]
  }
);

// Field-level annotations
annotate AdminService.Books with {
  ID          @UI.Hidden;
  createdAt   @UI.Hidden;
  modifiedAt  @UI.Hidden;
  createdBy   @UI.Hidden;
  modifiedBy  @UI.Hidden;

  title       @title: 'Title'  @mandatory;
  description @title: 'Description'  @UI.MultiLineText;
  price       @title: 'Price'  @Measures.ISOCurrency: currency_code;
  stock       @title: 'Stock';
  status      @title: 'Status';

  author      @title: 'Author' @Common.ValueList: {
    CollectionPath: 'Authors',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: author_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
    ]
  };
}

// ============================================
// BOOK GENRES (Sub-table)
// ============================================
annotate AdminService.BookGenres with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.LineItem: [
    { Value: genre.name, Label: 'Genre' }
  ]
);

annotate AdminService.BookGenres with {
  ID   @UI.Hidden;
  book @UI.Hidden;
}

// ============================================
// AUTHORS UI ANNOTATIONS
// ============================================
annotate AdminService.Authors with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Author',
    TypeNamePlural: 'Authors',
    Title: { Value: name }
  },

  UI.SelectionFields: [
    country_code
  ],

  UI.LineItem: [
    { Value: name, Label: 'Name' },
    { Value: country.name, Label: 'Country' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'BooksFacet',
      Label: 'Books by Author',
      Target: 'books/@UI.LineItem'
    }
  ]
);

annotate AdminService.Authors with {
  ID   @UI.Hidden;
  name @title: 'Name'  @mandatory;
}
```

---

### 4.5 Fiori Elements App Configuration (app/)

#### Description
The app folder contains UI5 application configuration, custom extensions, and Fiori launchpad integration.

#### File Structure

```
app/
├── books/                      # App for Books entity
│   ├── webapp/
│   │   ├── manifest.json       # UI5 app descriptor
│   │   ├── Component.js        # UI5 component
│   │   ├── index.html          # Standalone entry
│   │   └── ext/                # Custom extensions
│   └── package.json
├── common.cds                  # Shared annotations
└── index.cds                   # App index
```

#### AI Prompt for Fiori App Configuration

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

#### Example manifest.json

```json
{
  "_version": "1.65.0",
  "sap.app": {
    "id": "my.bookshop.books",
    "type": "application",
    "title": "{{appTitle}}",
    "description": "{{appDescription}}",
    "applicationVersion": {
      "version": "1.0.0"
    },
    "dataSources": {
      "mainService": {
        "uri": "/api/admin/",
        "type": "OData",
        "settings": {
          "odataVersion": "4.0",
          "localUri": "localService/metadata.xml"
        }
      }
    }
  },
  "sap.ui5": {
    "flexEnabled": true,
    "dependencies": {
      "minUI5Version": "1.120.0",
      "libs": {
        "sap.m": {},
        "sap.ui.core": {},
        "sap.fe.templates": {}
      }
    },
    "models": {
      "": {
        "dataSource": "mainService",
        "preload": true,
        "settings": {
          "operationMode": "Server",
          "autoExpandSelect": true,
          "earlyRequests": true
        }
      },
      "i18n": {
        "type": "sap.ui.model.resource.ResourceModel",
        "settings": {
          "bundleName": "my.bookshop.books.i18n.i18n"
        }
      }
    },
    "routing": {
      "config": {
        "routerClass": "sap.f.routing.Router",
        "flexibleColumnLayout": {
          "defaultTwoColumnLayoutType": "TwoColumnsBeginExpanded",
          "defaultThreeColumnLayoutType": "ThreeColumnsMidExpanded"
        }
      },
      "routes": [
        {
          "name": "BooksList",
          "pattern": ":?query:",
          "target": "BooksList"
        },
        {
          "name": "BooksObjectPage",
          "pattern": "Books({key}):?query:",
          "target": ["BooksList", "BooksObjectPage"]
        }
      ],
      "targets": {
        "BooksList": {
          "type": "Component",
          "id": "BooksList",
          "name": "sap.fe.templates.ListReport",
          "options": {
            "settings": {
              "contextPath": "/Books",
              "variantManagement": "Page",
              "navigation": {
                "Books": {
                  "detail": {
                    "route": "BooksObjectPage"
                  }
                }
              }
            }
          }
        },
        "BooksObjectPage": {
          "type": "Component",
          "id": "BooksObjectPage",
          "name": "sap.fe.templates.ObjectPage",
          "options": {
            "settings": {
              "contextPath": "/Books",
              "editableHeaderContent": false
            }
          }
        }
      }
    }
  }
}
```

---

### 4.6 Configuration Files

#### package.json

```json
{
  "name": "my-bookshop",
  "version": "1.0.0",
  "description": "SAP CAP Bookshop Application",
  "repository": "<your-repo>",
  "license": "UNLICENSED",
  "private": true,
  "dependencies": {
    "@sap/cds": "^8",
    "express": "^4"
  },
  "devDependencies": {
    "@cap-js/sqlite": "^1",
    "@sap/cds-dk": "^8",
    "@sap/ux-specification": "latest"
  },
  "scripts": {
    "start": "cds-serve",
    "watch": "cds watch",
    "test": "cds bind --exec jest",
    "build": "cds build --production"
  },
  "cds": {
    "requires": {
      "db": {
        "kind": "sqlite",
        "credentials": {
          "url": "db.sqlite"
        }
      },
      "[production]": {
        "db": {
          "kind": "hana"
        },
        "auth": {
          "kind": "xsuaa"
        }
      }
    }
  }
}
```

#### .cdsrc.json

```json
{
  "build": {
    "target": "."
  },
  "odata": {
    "version": "v4"
  },
  "features": {
    "fiori_preview": true
  },
  "i18n": {
    "default_language": "en"
  },
  "log": {
    "levels": {
      "cds": "info",
      "db": "info"
    }
  }
}
```

---

## 5. Best Practices

### Database Design

1. **Use Aspects** - Leverage `cuid`, `managed`, `temporal` for consistency
2. **Namespace Everything** - Use clear namespace hierarchy
3. **Normalize Wisely** - Balance normalization with query performance
4. **Index Strategically** - Add `@cds.search` for full-text search

### Service Design

1. **Single Responsibility** - One service per bounded context
2. **Least Privilege** - Expose only necessary fields
3. **Draft for Complex Forms** - Enable drafts for multi-step editing
4. **Pagination** - Always use server-side pagination

### Handler Implementation

1. **Validate Early** - Use `before` handlers for validation
2. **Enrich Late** - Use `after` handlers for derived data
3. **Log Everything** - Use `cds.log` for debugging
4. **Handle Errors Gracefully** - Use `req.error()` for user-facing errors

### UI Annotations

1. **Start Simple** - Begin with basic annotations, add complexity as needed
2. **Use Value Helps** - Guide users with dropdown selections
3. **Group Related Fields** - Use FieldGroups for logical groupings
4. **Show Status with Criticality** - Color-code statuses

---

## 6. Common Patterns

### Soft Delete

```cds
// schema.cds
entity Items : cuid, managed {
  // ... fields ...
  isDeleted : Boolean default false;
  deletedAt : Timestamp;
  deletedBy : String;
}
```

```javascript
// handler.js
this.before('DELETE', Items, async (req) => {
  await UPDATE(Items).set({
    isDeleted: true,
    deletedAt: new Date(),
    deletedBy: req.user.id
  }).where({ ID: req.data.ID });

  req.reply(); // Prevent actual deletion
});

this.before('READ', Items, (req) => {
  req.query.where({ isDeleted: false });
});
```

### Status Machine

```javascript
const STATUS_TRANSITIONS = {
  draft:     ['submitted'],
  submitted: ['approved', 'rejected'],
  approved:  ['closed'],
  rejected:  ['draft'],
  closed:    []
};

this.before('UPDATE', Items, async (req) => {
  if (req.data.status) {
    const { status: currentStatus } = await SELECT.one
      .from(Items).columns('status').where({ ID: req.data.ID });

    const allowedNext = STATUS_TRANSITIONS[currentStatus] || [];

    if (!allowedNext.includes(req.data.status)) {
      req.error(400, `Invalid status transition: ${currentStatus} → ${req.data.status}`);
    }
  }
});
```

### Calculated Fields

```cds
// service.cds
entity Orders as projection on db.Orders {
  *,
  // Calculated in handler
  null as totalAmount : Decimal(15,2),
  null as itemCount   : Integer
}
```

```javascript
// handler.js
this.after('READ', Orders, async (orders, req) => {
  const orderIds = orders.map(o => o.ID);

  const totals = await SELECT
    .from(OrderItems)
    .columns('order_ID',
      { func: 'SUM', args: [{ ref: ['amount'] }], as: 'total' },
      { func: 'COUNT', args: ['*'], as: 'count' })
    .where({ order_ID: { in: orderIds } })
    .groupBy('order_ID');

  const totalMap = new Map(totals.map(t => [t.order_ID, t]));

  for (const order of orders) {
    const calc = totalMap.get(order.ID) || { total: 0, count: 0 };
    order.totalAmount = calc.total;
    order.itemCount = calc.count;
  }
});
```

### Multi-Tenancy

```json
// package.json cds section
{
  "cds": {
    "requires": {
      "multitenancy": true,
      "toggles": true,
      "extensibility": true
    }
  }
}
```

---

## Quick Reference Card

| Task | Command/Location |
|------|------------------|
| Create project | `cds init <name>` |
| Run locally | `cds watch` |
| Add entity | `db/schema.cds` |
| Add service | `srv/<name>.cds` |
| Add handler | `srv/<name>.js` |
| Add UI | `srv/<name>-ui.cds` |
| Build | `cds build --production` |
| Deploy | `cf deploy` |
| Add HANA | `cds add hana` |
| Add Auth | `cds add xsuaa` |

---

*Document Version: 1.0*
*Last Updated: January 2026*
*Compatible with: @sap/cds ^8.x*
