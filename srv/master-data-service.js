const cds = require('@sap/cds');

module.exports = class MasterDataService extends cds.ApplicationService {

  async init() {
    const { Fields, Wells, Vendors, Partners, CostCategories, CostElements, Countries, Currencies, UnitsOfMeasure } = this.entities;

    // ============================================
    // FIELDS CRUD
    // ============================================
    this.before('CREATE', Fields, async (req) => {
      const { fieldCode } = req.data;
      const exists = await SELECT.one.from(Fields).where({ fieldCode });
      if (exists) req.error(409, `Field with code ${fieldCode} already exists`);
    });

    this.after('READ', Fields, (data) => {
      if (Array.isArray(data)) data.forEach(enrichField);
      else if (data) enrichField(data);
    });

    // ============================================
    // WELLS CRUD
    // ============================================
    this.before('CREATE', Wells, async (req) => {
      const { wellNumber } = req.data;
      const exists = await SELECT.one.from(Wells).where({ wellNumber });
      if (exists) req.error(409, `Well with number ${wellNumber} already exists`);
      if (!req.data.status) req.data.status = 'Planned';
    });

    this.before('UPDATE', Wells, async (req) => {
      const { ID, status } = req.data;
      if (status) {
        const well = await SELECT.one.from(Wells).where({ ID });
        if (well && !isValidStatusTransition(well.status, status)) {
          req.error(400, `Invalid status transition from ${well.status} to ${status}`);
        }
      }
    });

    this.after('READ', Wells, (data) => {
      if (Array.isArray(data)) data.forEach(enrichWell);
      else if (data) enrichWell(data);
    });

    // ============================================
    // VENDORS CRUD
    // ============================================
    this.before('CREATE', Vendors, async (req) => {
      const { vendorCode } = req.data;
      const exists = await SELECT.one.from(Vendors).where({ vendorCode });
      if (exists) req.error(409, `Vendor with code ${vendorCode} already exists`);
    });

    // ============================================
    // PARTNERS CRUD
    // ============================================
    this.before('CREATE', Partners, async (req) => {
      const { partnerCode } = req.data;
      const exists = await SELECT.one.from(Partners).where({ partnerCode });
      if (exists) req.error(409, `Partner with code ${partnerCode} already exists`);
    });

    // ============================================
    // COST CATEGORIES CRUD
    // ============================================
    this.before('CREATE', CostCategories, async (req) => {
      const { categoryCode } = req.data;
      const exists = await SELECT.one.from(CostCategories).where({ categoryCode });
      if (exists) req.error(409, `Cost Category with code ${categoryCode} already exists`);
    });

    // ============================================
    // COST ELEMENTS CRUD
    // ============================================
    this.before('CREATE', CostElements, async (req) => {
      const { elementCode } = req.data;
      const exists = await SELECT.one.from(CostElements).where({ elementCode });
      if (exists) req.error(409, `Cost Element with code ${elementCode} already exists`);
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('activateWell', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Wells).set({ status: 'Drilling' }).where({ ID });
      return SELECT.one.from(Wells).where({ ID });
    });

    this.on('suspendWell', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Wells).set({ status: 'Suspended' }).where({ ID });
      return SELECT.one.from(Wells).where({ ID });
    });

    this.on('completeWell', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Wells).set({ status: 'Completed' }).where({ ID });
      return SELECT.one.from(Wells).where({ ID });
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getWellsByField', async (req) => {
      const { fieldId } = req.data;
      return SELECT.from(Wells).where({ field_ID: fieldId });
    });

    this.on('getActiveWells', async () => {
      return SELECT.from(Wells).where({ status: { '!=': 'PandA' }, isActive: true });
    });

    this.on('getVendorsByType', async (req) => {
      const { vendorType } = req.data;
      return SELECT.from(Vendors).where({ vendorType, isActive: true });
    });

    await super.init();
  }
};

// Helper functions
function enrichField(field) {
  if (field) field.displayName = `${field.fieldCode} - ${field.fieldName}`;
}

function enrichWell(well) {
  if (well) well.displayName = `${well.wellNumber} - ${well.wellName}`;
}

function isValidStatusTransition(from, to) {
  const transitions = {
    'Planned': ['Drilling', 'Cancelled'],
    'Drilling': ['Completed', 'Suspended'],
    'Suspended': ['Drilling', 'PandA'],
    'Completed': ['PandA'],
    'PandA': []
  };
  return transitions[from]?.includes(to) ?? false;
}
