/**
 * Integration Service Handler
 * Implements CRUD operations for S/4HANA integration, data quality, and ETL management
 */
const cds = require('@sap/cds');

module.exports = class IntegrationService extends cds.ApplicationService {

  async init() {
    const { IntegrationLogs, IntegrationLogDetails, DataQualityRules, MappingConfigs,
            FieldMappings, SyncStatus, CommunicationScenarios, ETLJobs, ETLJobRuns } = this.entities;

    // ===========================================
    // DATA QUALITY RULES - CRUD Operations
    // ===========================================

    this.before('CREATE', DataQualityRules, async (req) => {
      const { ruleCode, ruleName, entityType, ruleType } = req.data;

      if (!ruleCode) {
        return req.error(400, 'Rule code is required');
      }
      if (!ruleName) {
        return req.error(400, 'Rule name is required');
      }
      if (!entityType) {
        return req.error(400, 'Entity type is required');
      }

      // Check for duplicate
      const existing = await SELECT.one.from(DataQualityRules).where({ ruleCode });
      if (existing) {
        return req.error(409, `Rule with code '${ruleCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', DataQualityRules, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('activate', DataQualityRules, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(DataQualityRules).set({
        isActive: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(DataQualityRules).where({ ID });
    });

    this.on('deactivate', DataQualityRules, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(DataQualityRules).set({
        isActive: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(DataQualityRules).where({ ID });
    });

    this.on('test', DataQualityRules, async (req) => {
      const { ID } = req.params[0];
      const { testData } = req.data;

      const rule = await SELECT.one.from(DataQualityRules).where({ ID });
      if (!rule) {
        return req.error(404, 'Rule not found');
      }

      // Simulate rule testing
      let isValid = true;
      let message = 'Validation passed';

      try {
        const data = JSON.parse(testData);

        switch (rule.ruleType) {
          case 'Required':
            isValid = data[rule.fieldName] !== undefined && data[rule.fieldName] !== null && data[rule.fieldName] !== '';
            message = isValid ? 'Required field is present' : `Field '${rule.fieldName}' is required`;
            break;
          case 'Range':
            const value = parseFloat(data[rule.fieldName]);
            const min = parseFloat(rule.minValue);
            const max = parseFloat(rule.maxValue);
            isValid = !isNaN(value) && value >= min && value <= max;
            message = isValid ? 'Value is within range' : `Value must be between ${min} and ${max}`;
            break;
          case 'Regex':
            const regex = new RegExp(rule.pattern);
            isValid = regex.test(data[rule.fieldName]);
            message = isValid ? 'Pattern matched' : `Value does not match pattern '${rule.pattern}'`;
            break;
          default:
            message = 'Rule type not supported for testing';
        }
      } catch (e) {
        isValid = false;
        message = `Error parsing test data: ${e.message}`;
      }

      return { isValid, message };
    });

    // ===========================================
    // MAPPING CONFIGS - CRUD Operations
    // ===========================================

    this.before('CREATE', MappingConfigs, async (req) => {
      const { mappingCode, mappingName, sourceSystem, targetSystem } = req.data;

      if (!mappingCode) {
        return req.error(400, 'Mapping code is required');
      }
      if (!mappingName) {
        return req.error(400, 'Mapping name is required');
      }

      const existing = await SELECT.one.from(MappingConfigs).where({ mappingCode });
      if (existing) {
        return req.error(409, `Mapping with code '${mappingCode}' already exists`);
      }

      req.data.isActive = req.data.isActive ?? true;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', MappingConfigs, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('validate', MappingConfigs, async (req) => {
      const { ID } = req.params[0];
      const mapping = await SELECT.one.from(MappingConfigs).where({ ID });

      if (!mapping) {
        return req.error(404, 'Mapping config not found');
      }

      // Get field mappings
      const fieldMappings = await SELECT.from(FieldMappings).where({ config_ID: ID });
      const errors = [];

      if (fieldMappings.length === 0) {
        errors.push('No field mappings defined');
      }

      // Check for required mappings
      const requiredFields = ['ID', 'createdAt', 'modifiedAt'];
      for (const field of requiredFields) {
        const hasMapping = fieldMappings.some(m => m.targetField === field);
        if (!hasMapping) {
          errors.push(`Missing mapping for required field: ${field}`);
        }
      }

      return {
        isValid: errors.length === 0,
        errors: errors
      };
    });

    this.on('test', MappingConfigs, async (req) => {
      const { ID } = req.params[0];
      const { sourceData } = req.data;

      const mapping = await SELECT.one.from(MappingConfigs).where({ ID });
      if (!mapping) {
        return req.error(404, 'Mapping config not found');
      }

      const fieldMappings = await SELECT.from(FieldMappings).where({ config_ID: ID });

      try {
        const source = JSON.parse(sourceData);
        const target = {};

        for (const fm of fieldMappings) {
          let value = source[fm.sourceField];

          // Apply transformation if specified
          if (fm.transformationType && value !== undefined) {
            switch (fm.transformationType) {
              case 'Uppercase':
                value = String(value).toUpperCase();
                break;
              case 'Lowercase':
                value = String(value).toLowerCase();
                break;
              case 'Trim':
                value = String(value).trim();
                break;
              case 'ParseNumber':
                value = parseFloat(value);
                break;
              case 'ParseDate':
                value = new Date(value).toISOString();
                break;
            }
          }

          target[fm.targetField] = value;
        }

        return JSON.stringify(target, null, 2);
      } catch (e) {
        return `Error: ${e.message}`;
      }
    });

    // ===========================================
    // FIELD MAPPINGS - CRUD Operations
    // ===========================================

    this.before('CREATE', FieldMappings, async (req) => {
      const { config_ID, sourceField, targetField } = req.data;

      if (!config_ID) {
        return req.error(400, 'Mapping config reference is required');
      }
      if (!sourceField) {
        return req.error(400, 'Source field is required');
      }
      if (!targetField) {
        return req.error(400, 'Target field is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', FieldMappings, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // ===========================================
    // SYNC STATUS - CRUD Operations
    // ===========================================

    this.before('CREATE', SyncStatus, async (req) => {
      req.data.status = 'Pending';
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.on('retry', SyncStatus, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(SyncStatus).set({
        status: 'Pending',
        retryCount: cds.parse.expr('retryCount + 1'),
        lastRetryAt: new Date(),
        errorMessage: null,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(SyncStatus).where({ ID });
    });

    this.on('reset', SyncStatus, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(SyncStatus).set({
        status: 'Pending',
        retryCount: 0,
        errorMessage: null,
        lastSyncAt: null,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(SyncStatus).where({ ID });
    });

    // ===========================================
    // COMMUNICATION SCENARIOS - CRUD Operations
    // ===========================================

    this.before('CREATE', CommunicationScenarios, async (req) => {
      const { scenarioCode, scenarioName, endpoint } = req.data;

      if (!scenarioCode) {
        return req.error(400, 'Scenario code is required');
      }
      if (!scenarioName) {
        return req.error(400, 'Scenario name is required');
      }

      const existing = await SELECT.one.from(CommunicationScenarios).where({ scenarioCode });
      if (existing) {
        return req.error(409, `Scenario with code '${scenarioCode}' already exists`);
      }

      req.data.isEnabled = false;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CommunicationScenarios, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('enable', CommunicationScenarios, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(CommunicationScenarios).set({
        isEnabled: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(CommunicationScenarios).where({ ID });
    });

    this.on('disable', CommunicationScenarios, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(CommunicationScenarios).set({
        isEnabled: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(CommunicationScenarios).where({ ID });
    });

    this.on('testConnection', CommunicationScenarios, async (req) => {
      const { ID } = req.params[0];
      const scenario = await SELECT.one.from(CommunicationScenarios).where({ ID });

      if (!scenario) {
        return req.error(404, 'Communication scenario not found');
      }

      // Simulate connection test
      const startTime = Date.now();

      // In real implementation, would make HTTP request to endpoint
      const success = Math.random() > 0.2; // 80% success rate for demo
      const latencyMs = Math.floor(Math.random() * 200) + 50;

      return {
        success: success,
        message: success ? 'Connection successful' : 'Connection failed - timeout',
        latencyMs: latencyMs
      };
    });

    // ===========================================
    // ETL JOBS - CRUD Operations
    // ===========================================

    this.before('CREATE', ETLJobs, async (req) => {
      const { jobCode, jobName, sourceEntity, targetEntity } = req.data;

      if (!jobCode) {
        return req.error(400, 'Job code is required');
      }
      if (!jobName) {
        return req.error(400, 'Job name is required');
      }

      const existing = await SELECT.one.from(ETLJobs).where({ jobCode });
      if (existing) {
        return req.error(409, `ETL Job with code '${jobCode}' already exists`);
      }

      req.data.isEnabled = false;
      req.data.status = 'Idle';
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', ETLJobs, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.on('enable', ETLJobs, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(ETLJobs).set({
        isEnabled: true,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(ETLJobs).where({ ID });
    });

    this.on('disable', ETLJobs, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(ETLJobs).set({
        isEnabled: false,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(ETLJobs).where({ ID });
    });

    this.on('runNow', ETLJobs, async (req) => {
      const { ID } = req.params[0];
      const job = await SELECT.one.from(ETLJobs).where({ ID });

      if (!job) {
        return req.error(404, 'ETL Job not found');
      }

      // Create a job run
      const run = {
        job_ID: ID,
        status: 'Running',
        startedAt: new Date(),
        recordsProcessed: 0,
        recordsFailed: 0,
        createdAt: new Date(),
        createdBy: req.user.id
      };

      await INSERT.into(ETLJobRuns).entries(run);

      // Update job status
      await UPDATE(ETLJobs).set({
        status: 'Running',
        lastRunAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      // Simulate job execution (in real implementation, would run async)
      const recordsProcessed = Math.floor(Math.random() * 100) + 10;
      const recordsFailed = Math.floor(Math.random() * 5);

      // Update run with results
      const runId = run.ID;
      await UPDATE(ETLJobRuns).set({
        status: recordsFailed === 0 ? 'Completed' : 'Completed with Errors',
        completedAt: new Date(),
        recordsProcessed: recordsProcessed,
        recordsFailed: recordsFailed
      }).where({ ID: runId });

      // Update job status
      await UPDATE(ETLJobs).set({
        status: 'Idle',
        modifiedAt: new Date()
      }).where({ ID });

      return SELECT.one.from(ETLJobRuns).where({ ID: runId });
    });

    // ===========================================
    // SERVICE-LEVEL FUNCTIONS
    // ===========================================

    this.on('getIntegrationHealth', async (req) => {
      // Get sync status counts
      const pending = await SELECT.one.from(SyncStatus).columns('count(*) as count').where({ status: 'Pending' });
      const failed = await SELECT.one.from(SyncStatus).columns('count(*) as count').where({ status: 'Failed' });

      // Get last sync time
      const lastSync = await SELECT.one.from(IntegrationLogs)
        .orderBy({ startedAt: 'desc' });

      const failedCount = failed?.count || 0;
      let overallStatus = 'Healthy';
      if (failedCount > 10) overallStatus = 'Critical';
      else if (failedCount > 0) overallStatus = 'Warning';

      return {
        overallStatus: overallStatus,
        s4hanaStatus: 'Connected',
        lastSyncTime: lastSync?.startedAt || null,
        pendingSyncs: pending?.count || 0,
        failedSyncs: failedCount
      };
    });

    this.on('getRecentLogs', async (req) => {
      const { hours } = req.data;
      const cutoff = new Date();
      cutoff.setHours(cutoff.getHours() - (hours || 24));

      return SELECT.from(IntegrationLogs)
        .where({ startedAt: { '>=': cutoff } })
        .orderBy({ startedAt: 'desc' });
    });

    this.on('getFailedSyncs', async (req) => {
      return SELECT.from(SyncStatus).where({ status: 'Failed' });
    });

    this.on('getETLJobStatus', async (req) => {
      const jobs = await SELECT.from(ETLJobs);
      const results = [];

      for (const job of jobs) {
        const lastRun = await SELECT.one.from(ETLJobRuns)
          .where({ job_ID: job.ID })
          .orderBy({ startedAt: 'desc' });

        results.push({
          jobName: job.jobName,
          lastRunStatus: lastRun?.status || 'Never Run',
          lastRunTime: lastRun?.startedAt || null,
          nextRunTime: job.nextRunAt || null
        });
      }

      return results;
    });

    // ===========================================
    // S/4HANA SYNC ACTIONS
    // ===========================================

    this.on('syncVendors', async (req) => {
      const logId = await this._createIntegrationLog('Vendor Sync', 'Inbound');

      // Simulate sync operation
      const recordsProcessed = Math.floor(Math.random() * 50) + 10;
      const recordsFailed = Math.floor(Math.random() * 3);

      await this._completeIntegrationLog(logId, recordsProcessed, recordsFailed);

      return { recordsProcessed, recordsFailed };
    });

    this.on('syncCostElements', async (req) => {
      const logId = await this._createIntegrationLog('Cost Element Sync', 'Inbound');

      const recordsProcessed = Math.floor(Math.random() * 100) + 20;
      const recordsFailed = Math.floor(Math.random() * 5);

      await this._completeIntegrationLog(logId, recordsProcessed, recordsFailed);

      return { recordsProcessed, recordsFailed };
    });

    this.on('syncCostActuals', async (req) => {
      const { fromDate, toDate } = req.data;
      const logId = await this._createIntegrationLog('Cost Actuals Sync', 'Inbound');

      const recordsProcessed = Math.floor(Math.random() * 200) + 50;
      const recordsFailed = Math.floor(Math.random() * 10);

      await this._completeIntegrationLog(logId, recordsProcessed, recordsFailed);

      return { recordsProcessed, recordsFailed };
    });

    this.on('syncCommitments', async (req) => {
      const { fromDate, toDate } = req.data;
      const logId = await this._createIntegrationLog('Commitments Sync', 'Inbound');

      const recordsProcessed = Math.floor(Math.random() * 100) + 30;
      const recordsFailed = Math.floor(Math.random() * 5);

      await this._completeIntegrationLog(logId, recordsProcessed, recordsFailed);

      return { recordsProcessed, recordsFailed };
    });

    this.on('syncExchangeRates', async (req) => {
      const { rateDate } = req.data;
      const logId = await this._createIntegrationLog('Exchange Rates Sync', 'Inbound');

      const recordsProcessed = Math.floor(Math.random() * 30) + 10;
      const recordsFailed = 0;

      await this._completeIntegrationLog(logId, recordsProcessed, recordsFailed);

      return { recordsProcessed, recordsFailed };
    });

    // ===========================================
    // DATA QUALITY ACTIONS
    // ===========================================

    this.on('runDataQualityCheck', async (req) => {
      const { entityType } = req.data;

      // Get active rules for entity type
      const rules = await SELECT.from(DataQualityRules).where({ entityType, isActive: true });
      const errors = [];

      // Simulate running rules (in real implementation, would validate actual data)
      for (const rule of rules) {
        const hasError = Math.random() > 0.9; // 10% error rate for demo
        if (hasError) {
          errors.push({
            entityId: cds.utils.uuid(),
            ruleCode: rule.ruleCode,
            severity: rule.severity || 'Error',
            message: `Validation failed for rule: ${rule.ruleName}`
          });
        }
      }

      return errors;
    });

    this.on('validateAllData', async (req) => {
      const entityTypes = ['Fields', 'Wells', 'AFEs', 'CostActuals', 'Vendors', 'Partners'];
      const results = [];
      let totalEntities = 0;
      let totalErrors = 0;
      let totalWarnings = 0;

      for (const entityType of entityTypes) {
        const rules = await SELECT.from(DataQualityRules).where({ entityType, isActive: true });
        const entityErrors = Math.floor(Math.random() * 10);
        const entityWarnings = Math.floor(Math.random() * 20);

        results.push({
          entityType: entityType,
          errors: entityErrors,
          warnings: entityWarnings
        });

        totalEntities += 1;
        totalErrors += entityErrors;
        totalWarnings += entityWarnings;
      }

      return {
        totalEntities: totalEntities,
        totalErrors: totalErrors,
        totalWarnings: totalWarnings,
        details: results
      };
    });

    // ===========================================
    // HELPER METHODS
    // ===========================================

    this._createIntegrationLog = async (operation, direction) => {
      const log = {
        operation: operation,
        direction: direction,
        status: 'Running',
        startedAt: new Date(),
        createdAt: new Date(),
        createdBy: 'system'
      };

      const result = await INSERT.into(IntegrationLogs).entries(log);
      return result.req.data.ID;
    };

    this._completeIntegrationLog = async (logId, processed, failed) => {
      await UPDATE(IntegrationLogs).set({
        status: failed === 0 ? 'Completed' : 'Completed with Errors',
        completedAt: new Date(),
        recordsProcessed: processed,
        recordsFailed: failed,
        modifiedAt: new Date()
      }).where({ ID: logId });
    };

    await super.init();
  }
};
