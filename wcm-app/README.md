# Well Cost Management - CAP Backend Application

SAP Cloud Application Programming Model (CAP) backend for the Well Cost Management system.

## Project Structure

```
wcm-app/
├── db/                          # Database layer (CDS schemas)
│   ├── common.cds              # Common types and aspects
│   ├── master-data.cds         # Master data entities
│   ├── afe.cds                 # AFE entities
│   ├── financial.cds           # Financial entities
│   ├── economics.cds           # Investment economics
│   ├── operations.cds          # Daily operations
│   ├── integration.cds         # Integration entities
│   ├── security.cds            # Security & audit
│   ├── configuration.cds       # Configuration entities
│   └── index.cds               # Schema index
├── srv/                         # Service layer
│   ├── master-data-service.cds # Master data service
│   ├── afe-service.cds         # AFE service
│   ├── financial-service.cds   # Financial service
│   ├── economics-service.cds   # Economics service
│   ├── operations-service.cds  # Operations service
│   ├── integration-service.cds # Integration service
│   ├── admin-service.cds       # Admin service
│   └── index.cds               # Service index
├── app/                         # App Router
│   ├── package.json
│   └── xs-app.json
├── package.json                 # Project dependencies
├── mta.yaml                     # MTA deployment descriptor
├── xs-security.json            # XSUAA security config
└── .cdsrc.json                 # CDS configuration
```

## Services

| Service | Path | Description |
|---------|------|-------------|
| MasterDataService | /api/master | Wells, Fields, Vendors, Partners |
| AFEService | /api/afe | AFE lifecycle management |
| FinancialService | /api/financial | Cost actuals, JIB, variances |
| EconomicsService | /api/economics | NPV, IRR, cash flows |
| OperationsService | /api/operations | Daily reports, alerts |
| IntegrationService | /api/integration | S/4HANA sync, data quality |
| AdminService | /api/admin | Users, roles, configuration |

## Development

### Prerequisites

- Node.js >= 18
- SAP CDS CLI (`npm i -g @sap/cds-dk`)
- Cloud Foundry CLI (for deployment)

### Local Development

```bash
# Install dependencies
npm install

# Start local server with SQLite
cds watch

# Run with specific profile
cds watch --profile development
```

### Build

```bash
# Build for production
cds build --production
```

### Deploy to SAP BTP

```bash
# Build MTA archive
mbt build

# Deploy to Cloud Foundry
cf deploy mta_archives/wcm-app_1.0.0.mtar
```

## Database

The application uses SAP HANA Cloud in production and SQLite for local development.

### Entity Counts

| Layer | Entities |
|-------|----------|
| Master Data | 10 |
| AFE | 5 |
| Financial | 6 |
| Economics | 6 |
| Operations | 7 |
| Integration | 8 |
| Security | 6 |
| Configuration | 10 |
| **Total** | **58** |

## Security

Authentication via SAP XSUAA with the following role templates:

- DrillingEngineer
- AFECoordinator
- CostManager
- FinanceController
- Economist
- AssetManager
- PartnerRepresentative
- Administrator

## API Documentation

Access OData metadata at:
- `/api/master/$metadata`
- `/api/afe/$metadata`
- `/api/financial/$metadata`
- `/api/economics/$metadata`
- `/api/operations/$metadata`
- `/api/integration/$metadata`
- `/api/admin/$metadata`
