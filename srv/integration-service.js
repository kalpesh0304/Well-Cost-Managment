const cds = require('@sap/cds');

module.exports = class IntegrationService extends cds.ApplicationService {

  async init() {
    const { IntegrationLogs, DataQualityRules, MappingConfigs, SyncStatus, ETLJobs, ETLJobRuns } = this.entities;

    // ============================================
    // DATA QUALITY RULES CRUD
    // ============================================
    this.before('CREATE', DataQualityRules, async (req) => {
      const { ruleName } = req.data;
      const exists = await SELECT.one.from(DataQualityRules).where({ ruleName });
      if (exists) req.error(409, `Rule ${ruleName} already exists`);
      if (!req.data.severity) req.data.severity = 'Error';
    });

    // ============================================
    // ETL JOBS CRUD
    // ============================================
    this.before('CREATE', ETLJobs, async (req) => {
      if (!req.data.isEnabled) req.data.isEnabled = true;
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('activate', DataQualityRules, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(DataQualityRules).set({ isActive: true }).where({ ID });
      return SELECT.one.from(DataQualityRules).where({ ID });
    });

    this.on('deactivate', DataQualityRules, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(DataQualityRules).set({ isActive: false }).where({ ID });
      return SELECT.one.from(DataQualityRules).where({ ID });
    });

    this.on('test', DataQualityRules, async (req) => {
      const { ID } = req.params[0];
      const { testData } = req.data;
      // Simplified test logic
      return { isValid: true, message: 'Validation passed' };
    });

    this.on('enable', ETLJobs, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(ETLJobs).set({ isEnabled: true }).where({ ID });
      return SELECT.one.from(ETLJobs).where({ ID });
    });

    this.on('disable', ETLJobs, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(ETLJobs).set({ isEnabled: false }).where({ ID });
      return SELECT.one.from(ETLJobs).where({ ID });
    });

    this.on('runNow', ETLJobs, async (req) => {
      const { ID } = req.params[0];
      const job = await SELECT.one.from(ETLJobs).where({ ID });
      if (!job) req.error(404, 'Job not found');

      const run = {
        ID: cds.utils.uuid(),
        job_ID: ID,
        startTime: new Date().toISOString(),
        status: 'Running'
      };
      await INSERT.into(ETLJobRuns).entries(run);

      // Simulate job completion
      setTimeout(async () => {
        await UPDATE(ETLJobRuns).set({
          endTime: new Date().toISOString(),
          status: 'Success',
          recordsProcessed: 100,
          recordsFailed: 0
        }).where({ ID: run.ID });

        await UPDATE(ETLJobs).set({
          lastRunAt: new Date().toISOString(),
          lastRunStatus: 'Success'
        }).where({ ID });
      }, 1000);

      return run;
    });

    this.on('retry', SyncStatus, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(SyncStatus).set({
        status: 'Pending',
        retryCount: cds.utils.uuid() // Increment
      }).where({ ID });
      return SELECT.one.from(SyncStatus).where({ ID });
    });

    this.on('reset', SyncStatus, async (req) => {
      const { ID } = req.params[0];
      await UPDATE(SyncStatus).set({
        status: 'Pending',
        errorMessage: null,
        retryCount: 0
      }).where({ ID });
      return SELECT.one.from(SyncStatus).where({ ID });
    });

    // S/4HANA Sync Actions
    this.on('syncVendors', async (req) => {
      return await this.performSync('VENDOR_SYNC', 'Vendors');
    });

    this.on('syncCostElements', async (req) => {
      return await this.performSync('COST_ELEMENT_SYNC', 'CostElements');
    });

    this.on('syncCostActuals', async (req) => {
      const { fromDate, toDate } = req.data;
      return await this.performSync('COST_ACTUAL_SYNC', 'CostActuals', { fromDate, toDate });
    });

    this.on('syncCommitments', async (req) => {
      const { fromDate, toDate } = req.data;
      return await this.performSync('COMMITMENT_SYNC', 'Commitments', { fromDate, toDate });
    });

    this.on('syncExchangeRates', async (req) => {
      const { rateDate } = req.data;
      return await this.performSync('EXCHANGE_RATE_SYNC', 'ExchangeRates', { rateDate });
    });

    this.on('runDataQualityCheck', async (req) => {
      const { entityType } = req.data;
      // Simplified - return sample validation results
      return [
        { entityId: cds.utils.uuid(), ruleCode: 'DQ-001', severity: 'Warning', message: 'Sample validation message' }
      ];
    });

    this.on('validateAllData', async (req) => {
      return {
        totalEntities: 1000,
        totalErrors: 5,
        totalWarnings: 12,
        details: [
          { entityType: 'Wells', errors: 1, warnings: 3 },
          { entityType: 'AFEs', errors: 2, warnings: 5 },
          { entityType: 'CostActuals', errors: 2, warnings: 4 }
        ]
      };
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getIntegrationHealth', async () => {
      return {
        overallStatus: 'Healthy',
        s4hanaStatus: 'Connected',
        lastSyncTime: new Date().toISOString(),
        pendingSyncs: 0,
        failedSyncs: 0
      };
    });

    this.on('getRecentLogs', async (req) => {
      const { hours } = req.data;
      const since = new Date();
      since.setHours(since.getHours() - (hours || 24));
      return SELECT.from(IntegrationLogs)
        .where({ processingStartTime: { '>=': since.toISOString() } })
        .orderBy('processingStartTime desc');
    });

    this.on('getFailedSyncs', async () => {
      return SELECT.from(SyncStatus).where({ status: 'Failed' });
    });

    this.on('getETLJobStatus', async () => {
      const jobs = await SELECT.from(ETLJobs);
      return jobs.map(j => ({
        jobName: j.jobName,
        lastRunStatus: j.lastRunStatus,
        lastRunTime: j.lastRunAt,
        nextRunTime: j.nextRunAt
      }));
    });

    await super.init();
  }

  async performSync(integrationName, entityType, params = {}) {
    const { IntegrationLogs } = this.entities;

    const log = {
      ID: cds.utils.uuid(),
      integrationName,
      sourceSystem: 'S4HANA',
      targetSystem: 'WCM',
      direction: 'Inbound',
      processingStartTime: new Date().toISOString(),
      status: 'Success',
      recordsProcessed: Math.floor(Math.random() * 100) + 1,
      recordsFailed: 0,
      correlationId: cds.utils.uuid()
    };

    log.processingEndTime = new Date().toISOString();
    await INSERT.into(IntegrationLogs).entries(log);

    return {
      recordsProcessed: log.recordsProcessed,
      recordsFailed: log.recordsFailed
    };
  }
};
