/**
 * Master Data Service Handler
 * Implements CRUD operations and custom actions for master data entities
 */
const cds = require('@sap/cds');

module.exports = class MasterDataService extends cds.ApplicationService {

  async init() {
    const { Fields, Wells, CostCategories, CostElements, Vendors, Partners,
            WBSTemplates, WBSTemplateElements, ExchangeRates } = this.entities;

    // ===========================================
    // FIELDS - CRUD Operations
    // ===========================================

    // Before CREATE - Validate and set defaults
    this.before('CREATE', Fields, async (req) => {
      const { fieldCode, fieldName, country_code, basin } = req.data;

      if (!fieldCode) {
        return req.error(400, 'Field code is required');
      }
      if (!fieldName) {
        return req.error(400, 'Field name is required');
      }

      // Check for duplicate field code
      const existing = await SELECT.one.from(Fields).where({ fieldCode });
      if (existing) {
        return req.error(409, `Field with code '${fieldCode}' already exists`);
      }

      // Set defaults
      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // Before UPDATE - Validate and audit
    this.before('UPDATE', Fields, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Before DELETE - Check for dependencies
    this.before('DELETE', Fields, async (req) => {
      const fieldId = req.data.ID;
      const wellCount = await SELECT.one.from(Wells).columns('count(*) as count').where({ field_ID: fieldId });

      if (wellCount && wellCount.count > 0) {
        return req.error(400, `Cannot delete field with ${wellCount.count} associated well(s). Deactivate instead.`);
      }
    });

    // After READ - Enrich with well count
    this.after('READ', Fields, async (data, req) => {
      if (!data) return;
      const fields = Array.isArray(data) ? data : [data];

      for (const field of fields) {
        if (field.ID) {
          const result = await SELECT.one.from(Wells)
            .columns('count(*) as count')
            .where({ field_ID: field.ID });
          field.wellCount = result?.count || 0;
        }
      }
    });

    // Action: activate
    this.on('activate', Fields, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Fields).set({ isActive: true, modifiedAt: new Date(), modifiedBy: req.user.id }).where({ ID });
      return SELECT.one.from(Fields).where({ ID });
    });

    // Action: deactivate
    this.on('deactivate', Fields, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Fields).set({ isActive: false, modifiedAt: new Date(), modifiedBy: req.user.id }).where({ ID });
      return SELECT.one.from(Fields).where({ ID });
    });

    // ===========================================
    // WELLS - CRUD Operations
    // ===========================================

    // Before CREATE - Validate and set defaults
    this.before('CREATE', Wells, async (req) => {
      const { wellName, uwi, field_ID, wellType } = req.data;

      if (!wellName) {
        return req.error(400, 'Well name is required');
      }
      if (!uwi) {
        return req.error(400, 'UWI (Unique Well Identifier) is required');
      }
      if (!field_ID) {
        return req.error(400, 'Field is required');
      }

      // Check for duplicate UWI
      const existing = await SELECT.one.from(Wells).where({ uwi });
      if (existing) {
        return req.error(409, `Well with UWI '${uwi}' already exists`);
      }

      // Validate field exists
      const field = await SELECT.one.from(Fields).where({ ID: field_ID });
      if (!field) {
        return req.error(400, 'Invalid field reference');
      }

      // Set defaults
      req.data.status = req.data.status || 'Planned';
      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // Before UPDATE - Validate and audit
    this.before('UPDATE', Wells, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Before DELETE - Check for dependencies
    this.before('DELETE', Wells, async (req) => {
      const wellId = req.data.ID;

      // Check for AFEs
      const db = await cds.connect.to('db');
      const { AFEs } = db.entities('wcm.afe');
      const afeCount = await SELECT.one.from(AFEs).columns('count(*) as count').where({ well_ID: wellId });

      if (afeCount && afeCount.count > 0) {
        return req.error(400, `Cannot delete well with ${afeCount.count} associated AFE(s). Deactivate instead.`);
      }
    });

    // Action: updateStatus
    this.on('updateStatus', Wells, async (req) => {
      const { ID } = req.params[0];
      const { newStatus } = req.data;

      const validStatuses = ['Planned', 'Drilling', 'Completion', 'Production', 'Suspended', 'P&A', 'Abandoned'];
      if (!validStatuses.includes(newStatus)) {
        return req.error(400, `Invalid status. Must be one of: ${validStatuses.join(', ')}`);
      }

      await UPDATE(Wells).set({
        status: newStatus,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Wells).where({ ID });
    });

    // Action: syncToS4HANA
    this.on('syncToS4HANA', Wells, async (req) => {
      const { ID } = req.params[0];
      const well = await SELECT.one.from(Wells).where({ ID });

      if (!well) {
        return req.error(404, 'Well not found');
      }

      // Mark as synced (actual S/4HANA integration would go here)
      await UPDATE(Wells).set({
        s4hanaWBSElement: well.s4hanaWBSElement || `WBS-${well.uwi}`,
        s4hanaSyncStatus: 'Synced',
        s4hanaLastSyncAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Wells).where({ ID });
    });

    // ===========================================
    // COST CATEGORIES - CRUD Operations
    // ===========================================

    this.before('CREATE', CostCategories, async (req) => {
      const { categoryCode, categoryName, costType } = req.data;

      if (!categoryCode) {
        return req.error(400, 'Category code is required');
      }
      if (!categoryName) {
        return req.error(400, 'Category name is required');
      }

      // Check for duplicate
      const existing = await SELECT.one.from(CostCategories).where({ categoryCode });
      if (existing) {
        return req.error(409, `Category with code '${categoryCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CostCategories, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.before('DELETE', CostCategories, async (req) => {
      const catId = req.data.ID;

      // Check for child categories
      const childCount = await SELECT.one.from(CostCategories).columns('count(*) as count').where({ parent_ID: catId });
      if (childCount && childCount.count > 0) {
        return req.error(400, `Cannot delete category with ${childCount.count} child category(ies)`);
      }

      // Check for cost elements
      const elementCount = await SELECT.one.from(CostElements).columns('count(*) as count').where({ category_ID: catId });
      if (elementCount && elementCount.count > 0) {
        return req.error(400, `Cannot delete category with ${elementCount.count} associated cost element(s)`);
      }
    });

    // ===========================================
    // COST ELEMENTS - CRUD Operations
    // ===========================================

    this.before('CREATE', CostElements, async (req) => {
      const { elementCode, elementName, category_ID } = req.data;

      if (!elementCode) {
        return req.error(400, 'Element code is required');
      }
      if (!elementName) {
        return req.error(400, 'Element name is required');
      }

      // Check for duplicate
      const existing = await SELECT.one.from(CostElements).where({ elementCode });
      if (existing) {
        return req.error(409, `Cost element with code '${elementCode}' already exists`);
      }

      // Validate category if provided
      if (category_ID) {
        const category = await SELECT.one.from(CostCategories).where({ ID: category_ID });
        if (!category) {
          return req.error(400, 'Invalid cost category reference');
        }
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CostElements, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Action: syncFromS4HANA
    this.on('syncFromS4HANA', CostElements, async (req) => {
      const { ID } = req.params[0];

      // Simulate S/4HANA sync
      await UPDATE(CostElements).set({
        s4hanaSyncStatus: 'Synced',
        s4hanaLastSyncAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(CostElements).where({ ID });
    });

    // ===========================================
    // VENDORS - CRUD Operations
    // ===========================================

    this.before('CREATE', Vendors, async (req) => {
      const { vendorCode, vendorName } = req.data;

      if (!vendorCode) {
        return req.error(400, 'Vendor code is required');
      }
      if (!vendorName) {
        return req.error(400, 'Vendor name is required');
      }

      const existing = await SELECT.one.from(Vendors).where({ vendorCode });
      if (existing) {
        return req.error(409, `Vendor with code '${vendorCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', Vendors, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('syncFromS4HANA', Vendors, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Vendors).set({
        s4hanaSyncStatus: 'Synced',
        s4hanaLastSyncAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Vendors).where({ ID });
    });

    // ===========================================
    // PARTNERS - CRUD Operations
    // ===========================================

    this.before('CREATE', Partners, async (req) => {
      const { partnerCode, partnerName } = req.data;

      if (!partnerCode) {
        return req.error(400, 'Partner code is required');
      }
      if (!partnerName) {
        return req.error(400, 'Partner name is required');
      }

      const existing = await SELECT.one.from(Partners).where({ partnerCode });
      if (existing) {
        return req.error(409, `Partner with code '${partnerCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', Partners, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // WBS TEMPLATES - CRUD Operations
    // ===========================================

    this.before('CREATE', WBSTemplates, async (req) => {
      const { templateCode, templateName } = req.data;

      if (!templateCode) {
        return req.error(400, 'Template code is required');
      }
      if (!templateName) {
        return req.error(400, 'Template name is required');
      }

      const existing = await SELECT.one.from(WBSTemplates).where({ templateCode });
      if (existing) {
        return req.error(409, `WBS Template with code '${templateCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', WBSTemplates, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // FUNCTIONS
    // ===========================================

    // getActiveWellsByField
    this.on('getActiveWellsByField', async (req) => {
      const { fieldId } = req.data;
      return SELECT.from(Wells).where({ field_ID: fieldId, isActive: true });
    });

    // getWellsByStatus
    this.on('getWellsByStatus', async (req) => {
      const { status } = req.data;
      return SELECT.from(Wells).where({ status, isActive: true });
    });

    // getCostElementHierarchy
    this.on('getCostElementHierarchy', async (req) => {
      const categories = await SELECT.from(CostCategories).where({ isActive: true });
      return categories;
    });

    // getExchangeRate
    this.on('getExchangeRate', async (req) => {
      const { fromCurrency, toCurrency, rateDate } = req.data;

      const rate = await SELECT.one.from(ExchangeRates)
        .where({
          fromCurrency_code: fromCurrency,
          toCurrency_code: toCurrency,
          validFrom: { '<=': rateDate }
        })
        .orderBy({ validFrom: 'desc' });

      return rate?.exchangeRate || null;
    });

    await super.init();
  }
};
