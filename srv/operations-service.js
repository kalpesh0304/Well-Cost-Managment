/**
 * Operations Service Handler
 * Implements CRUD operations for Daily Reports, Alerts, Forecasts, and KPIs
 */
const cds = require('@sap/cds');

module.exports = class OperationsService extends cds.ApplicationService {

  async init() {
    const { DailyReports, DailyActivities, DailyCosts, Alerts, AlertRecipients,
            CostForecasts, KPISnapshots } = this.entities;

    // ===========================================
    // DAILY REPORTS - CRUD Operations
    // ===========================================

    this.before('CREATE', DailyReports, async (req) => {
      const { well_ID, reportDate } = req.data;

      if (!well_ID) {
        return req.error(400, 'Well reference is required');
      }
      if (!reportDate) {
        return req.error(400, 'Report date is required');
      }

      // Check for existing report on same date
      const existing = await SELECT.one.from(DailyReports).where({ well_ID, reportDate });
      if (existing) {
        return req.error(409, 'A daily report already exists for this well on this date');
      }

      // Auto-generate report number
      const countResult = await SELECT.one.from(DailyReports).columns('count(*) as count');
      const count = (countResult?.count || 0) + 1;
      req.data.reportNumber = req.data.reportNumber || `DDR-${new Date().getFullYear()}-${String(count).padStart(5, '0')}`;

      req.data.status = 'Draft';
      req.data.totalHours = 24;
      req.data.productiveHours = 0;
      req.data.nptHours = 0;
      req.data.totalCost = 0;
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', DailyReports, async (req) => {
      const { ID } = req.data;

      if (ID) {
        const current = await SELECT.one.from(DailyReports).where({ ID });
        if (current?.status === 'Approved') {
          return req.error(400, 'Cannot modify approved daily report');
        }
      }

      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    this.before('DELETE', DailyReports, async (req) => {
      const reportId = req.data.ID;
      const report = await SELECT.one.from(DailyReports).where({ ID: reportId });

      if (report?.status !== 'Draft') {
        return req.error(400, 'Only draft reports can be deleted');
      }
    });

    // Action: submit
    this.on('submit', DailyReports, async (req) => {
      const { ID } = req.params[0];
      const report = await SELECT.one.from(DailyReports).where({ ID });

      if (!report) {
        return req.error(404, 'Daily report not found');
      }
      if (report.status !== 'Draft') {
        return req.error(400, `Cannot submit report in '${report.status}' status`);
      }

      // Validate activities sum to 24 hours
      const activities = await SELECT.from(DailyActivities).where({ report_ID: ID });
      const totalHours = activities.reduce((sum, a) => sum + (a.duration || 0), 0);

      if (Math.abs(totalHours - 24) > 0.01) {
        return req.error(400, `Activities must sum to 24 hours (current: ${totalHours} hours)`);
      }

      await UPDATE(DailyReports).set({
        status: 'Submitted',
        submittedAt: new Date(),
        submittedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(DailyReports).where({ ID });
    });

    // Action: approve (report)
    this.on('approve', DailyReports, async (req) => {
      const { ID } = req.params[0];
      const report = await SELECT.one.from(DailyReports).where({ ID });

      if (!report) {
        return req.error(404, 'Daily report not found');
      }
      if (report.status !== 'Submitted') {
        return req.error(400, 'Only submitted reports can be approved');
      }

      await UPDATE(DailyReports).set({
        status: 'Approved',
        approvedAt: new Date(),
        approvedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(DailyReports).where({ ID });
    });

    // Action: reject (report)
    this.on('reject', DailyReports, async (req) => {
      const { ID } = req.params[0];
      const { reason } = req.data;
      const report = await SELECT.one.from(DailyReports).where({ ID });

      if (!report) {
        return req.error(404, 'Daily report not found');
      }
      if (report.status !== 'Submitted') {
        return req.error(400, 'Only submitted reports can be rejected');
      }

      await UPDATE(DailyReports).set({
        status: 'Rejected',
        rejectionReason: reason,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(DailyReports).where({ ID });
    });

    // Action: copyFromPrevious
    this.on('copyFromPrevious', DailyReports, async (req) => {
      const { ID } = req.params[0];
      const report = await SELECT.one.from(DailyReports).where({ ID });

      if (!report) {
        return req.error(404, 'Daily report not found');
      }

      // Find previous day's report
      const previousDate = new Date(report.reportDate);
      previousDate.setDate(previousDate.getDate() - 1);

      const previousReport = await SELECT.one.from(DailyReports)
        .where({ well_ID: report.well_ID, reportDate: previousDate.toISOString().split('T')[0] });

      if (!previousReport) {
        return req.error(404, 'No previous day report found');
      }

      // Copy activities
      const previousActivities = await SELECT.from(DailyActivities).where({ report_ID: previousReport.ID });
      for (const activity of previousActivities) {
        await INSERT.into(DailyActivities).entries({
          report_ID: ID,
          activityCode: activity.activityCode,
          activityDescription: activity.activityDescription,
          startTime: activity.startTime,
          endTime: activity.endTime,
          duration: activity.duration,
          isNPT: activity.isNPT,
          nptCategory: activity.nptCategory,
          createdAt: new Date(),
          createdBy: req.user.id
        });
      }

      // Copy costs
      const previousCosts = await SELECT.from(DailyCosts).where({ report_ID: previousReport.ID });
      for (const cost of previousCosts) {
        await INSERT.into(DailyCosts).entries({
          report_ID: ID,
          costElement_ID: cost.costElement_ID,
          vendor_ID: cost.vendor_ID,
          description: cost.description,
          quantity: cost.quantity,
          unitCost: cost.unitCost,
          totalCost: cost.totalCost,
          createdAt: new Date(),
          createdBy: req.user.id
        });
      }

      // Recalculate totals
      await this._updateReportTotals(ID);

      return SELECT.one.from(DailyReports).where({ ID });
    });

    // Action: exportToPDF
    this.on('exportToPDF', DailyReports, async (req) => {
      const { ID } = req.params[0];
      return Buffer.from(`Daily Drilling Report PDF for ${ID}`);
    });

    // ===========================================
    // DAILY ACTIVITIES - CRUD Operations
    // ===========================================

    this.before('CREATE', DailyActivities, async (req) => {
      const { report_ID, activityDescription, duration } = req.data;

      if (!report_ID) {
        return req.error(400, 'Report reference is required');
      }
      if (!activityDescription) {
        return req.error(400, 'Activity description is required');
      }
      if (!duration || duration <= 0) {
        return req.error(400, 'Valid duration is required');
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', DailyActivities, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // After CREATE/UPDATE/DELETE - Update report totals
    this.after(['CREATE', 'UPDATE', 'DELETE'], DailyActivities, async (data, req) => {
      const reportId = data?.report_ID || req.data?.report_ID;
      if (reportId) {
        await this._updateReportTotals(reportId);
      }
    });

    // ===========================================
    // DAILY COSTS - CRUD Operations
    // ===========================================

    this.before('CREATE', DailyCosts, async (req) => {
      const { report_ID, description, quantity, unitCost } = req.data;

      if (!report_ID) {
        return req.error(400, 'Report reference is required');
      }
      if (!description) {
        return req.error(400, 'Description is required');
      }

      // Calculate total
      if (quantity && unitCost) {
        req.data.totalCost = quantity * unitCost;
      }

      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', DailyCosts, async (req) => {
      // Recalculate total
      if (req.data.quantity !== undefined && req.data.unitCost !== undefined) {
        req.data.totalCost = req.data.quantity * req.data.unitCost;
      }
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // After CREATE/UPDATE/DELETE - Update report totals
    this.after(['CREATE', 'UPDATE', 'DELETE'], DailyCosts, async (data, req) => {
      const reportId = data?.report_ID || req.data?.report_ID;
      if (reportId) {
        await this._updateReportTotals(reportId);
      }
    });

    // ===========================================
    // ALERTS - CRUD Operations
    // ===========================================

    this.before('CREATE', Alerts, async (req) => {
      const { alertType, severity, title, message } = req.data;

      if (!alertType) {
        return req.error(400, 'Alert type is required');
      }
      if (!title) {
        return req.error(400, 'Title is required');
      }
      if (!message) {
        return req.error(400, 'Message is required');
      }

      req.data.status = 'Active';
      req.data.triggeredAt = new Date();
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    // Action: acknowledge
    this.on('acknowledge', Alerts, async (req) => {
      const { ID } = req.params[0];

      await UPDATE(Alerts).set({
        status: 'Acknowledged',
        acknowledgedAt: new Date(),
        acknowledgedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Alerts).where({ ID });
    });

    // Action: resolve
    this.on('resolve', Alerts, async (req) => {
      const { ID } = req.params[0];
      const { resolution } = req.data;

      await UPDATE(Alerts).set({
        status: 'Resolved',
        resolution: resolution,
        resolvedAt: new Date(),
        resolvedBy: req.user.id,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Alerts).where({ ID });
    });

    // Action: snooze
    this.on('snooze', Alerts, async (req) => {
      const { ID } = req.params[0];
      const { untilDate } = req.data;

      await UPDATE(Alerts).set({
        status: 'Snoozed',
        snoozedUntil: untilDate,
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(Alerts).where({ ID });
    });

    // ===========================================
    // COST FORECASTS - CRUD Operations
    // ===========================================

    this.before('CREATE', CostForecasts, async (req) => {
      const { afe_ID, forecastType } = req.data;

      if (!afe_ID) {
        return req.error(400, 'AFE reference is required');
      }

      req.data.forecastType = forecastType || 'Manual';
      req.data.status = 'Draft';
      req.data.createdAt = new Date();
      req.data.createdBy = req.user.id;
    });

    this.before('UPDATE', CostForecasts, async (req) => {
      req.data.modifiedAt = new Date();
      req.data.modifiedBy = req.user.id;
    });

    // Action: generateAIForecast
    this.on('generateAIForecast', CostForecasts, async (req) => {
      const { ID } = req.params[0];
      const forecast = await SELECT.one.from(CostForecasts).where({ ID });

      if (!forecast) {
        return req.error(404, 'Cost forecast not found');
      }

      // Get historical data for the AFE
      const db = await cds.connect.to('db');
      const { CostActuals } = db.entities('wcm.financial');

      const actuals = await SELECT.from(CostActuals).where({ afe_ID: forecast.afe_ID });
      const totalActual = actuals.reduce((sum, a) => sum + (a.amount || 0), 0);

      // Simple AI forecast (in reality, would use ML model)
      const daysElapsed = forecast.daysElapsed || 30;
      const totalDays = forecast.totalPlannedDays || 90;
      const burnRate = totalActual / daysElapsed;
      const forecastedTotal = burnRate * totalDays;

      await UPDATE(CostForecasts).set({
        forecastType: 'AI',
        forecastedCost: forecastedTotal,
        confidenceLevel: 0.75,
        forecastedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(CostForecasts).where({ ID });
    });

    // Action: recalculate
    this.on('recalculate', CostForecasts, async (req) => {
      const { ID } = req.params[0];
      const forecast = await SELECT.one.from(CostForecasts).where({ ID });

      if (!forecast) {
        return req.error(404, 'Cost forecast not found');
      }

      // Simple linear projection
      const currentCost = forecast.currentCost || 0;
      const percentComplete = forecast.percentComplete || 50;

      const forecastedCost = percentComplete > 0
        ? (currentCost / (percentComplete / 100))
        : currentCost * 2;

      await UPDATE(CostForecasts).set({
        forecastedCost: forecastedCost,
        forecastedAt: new Date(),
        modifiedAt: new Date(),
        modifiedBy: req.user.id
      }).where({ ID });

      return SELECT.one.from(CostForecasts).where({ ID });
    });

    // ===========================================
    // SERVICE-LEVEL ACTIONS
    // ===========================================

    // Action: createAlert
    this.on('createAlert', async (req) => {
      const { alertType, severity, title, message, wellId, afeId, recipientUserIds } = req.data;

      const alert = {
        alertType: alertType,
        severity: severity || 'Medium',
        title: title,
        message: message,
        well_ID: wellId,
        afe_ID: afeId,
        status: 'Active',
        triggeredAt: new Date(),
        createdAt: new Date(),
        createdBy: req.user.id
      };

      const result = await INSERT.into(Alerts).entries(alert);
      const alertId = result.req.data.ID;

      // Create recipients
      if (recipientUserIds && recipientUserIds.length > 0) {
        for (const userId of recipientUserIds) {
          await INSERT.into(AlertRecipients).entries({
            alert_ID: alertId,
            userId: userId,
            notifiedAt: new Date()
          });
        }
      }

      return SELECT.one.from(Alerts).where({ ID: alertId });
    });

    // Action: generateKPISnapshot
    this.on('generateKPISnapshot', async (req) => {
      const { snapshotDate, snapshotType } = req.data;

      const db = await cds.connect.to('db');
      const { Wells, Fields } = db.entities('wcm.master');
      const { AFEs } = db.entities('wcm.afe');

      const wells = await SELECT.from(Wells).where({ status: { '!=': 'Abandoned' } });
      const snapshots = [];

      for (const well of wells) {
        // Calculate KPIs for each well
        const afes = await SELECT.from(AFEs).where({ well_ID: well.ID });
        const totalEstimated = afes.reduce((sum, a) => sum + (a.estimatedCost || 0), 0);
        const totalActual = afes.reduce((sum, a) => sum + (a.actualCost || 0), 0);
        const variance = totalActual - totalEstimated;
        const variancePct = totalEstimated > 0 ? (variance / totalEstimated) * 100 : 0;

        const snapshot = {
          well_ID: well.ID,
          field_ID: well.field_ID,
          snapshotDate: snapshotDate,
          snapshotType: snapshotType || 'Daily',
          totalEstimatedCost: totalEstimated,
          totalActualCost: totalActual,
          costVariance: variance,
          costVariancePct: variancePct,
          createdAt: new Date(),
          createdBy: req.user.id
        };

        await INSERT.into(KPISnapshots).entries(snapshot);
        snapshots.push(snapshot);
      }

      return snapshots;
    });

    // Action: generateDrillingReport
    this.on('generateDrillingReport', async (req) => {
      const { wellId, fromDate, toDate, format } = req.data;
      return Buffer.from(`Drilling Report for well ${wellId} from ${fromDate} to ${toDate} in ${format || 'PDF'} format`);
    });

    // ===========================================
    // FUNCTIONS
    // ===========================================

    this.on('getDailyReportsByWell', async (req) => {
      const { wellId, fromDate, toDate } = req.data;

      return SELECT.from(DailyReports).where({
        well_ID: wellId,
        reportDate: { '>=': fromDate, '<=': toDate }
      }).orderBy({ reportDate: 'desc' });
    });

    this.on('getLatestDailyReport', async (req) => {
      const { wellId } = req.data;

      return SELECT.one.from(DailyReports)
        .where({ well_ID: wellId })
        .orderBy({ reportDate: 'desc' });
    });

    this.on('getActiveAlerts', async (req) => {
      return SELECT.from(Alerts).where({ status: 'Active' });
    });

    this.on('getMyAlerts', async (req) => {
      const alerts = await SELECT.from(Alerts).where({ status: 'Active' });
      const myAlerts = [];

      for (const alert of alerts) {
        const recipient = await SELECT.one.from(AlertRecipients)
          .where({ alert_ID: alert.ID, userId: req.user.id });
        if (recipient) {
          myAlerts.push(alert);
        }
      }

      return myAlerts;
    });

    this.on('getAlertsByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(Alerts).where({ well_ID: wellId });
    });

    this.on('getWellProgress', async (req) => {
      const { wellId } = req.data;

      const db = await cds.connect.to('db');
      const { Wells } = db.entities('wcm.master');
      const { AFEs } = db.entities('wcm.afe');

      const well = await SELECT.one.from(Wells).where({ ID: wellId });
      if (!well) {
        return req.error(404, 'Well not found');
      }

      // Get latest daily report for depth info
      const latestReport = await SELECT.one.from(DailyReports)
        .where({ well_ID: wellId })
        .orderBy({ reportDate: 'desc' });

      // Get AFE info
      const afes = await SELECT.from(AFEs).where({ well_ID: wellId });
      const totalEstimated = afes.reduce((sum, a) => sum + (a.estimatedCost || 0), 0);
      const totalActual = afes.reduce((sum, a) => sum + (a.actualCost || 0), 0);

      return {
        currentDepth: latestReport?.currentDepth || 0,
        targetDepth: well.targetDepth || 0,
        progressPct: well.targetDepth > 0 ? ((latestReport?.currentDepth || 0) / well.targetDepth) * 100 : 0,
        daysElapsed: latestReport?.daysFromSpud || 0,
        plannedDays: well.plannedDays || 0,
        scheduleVariance: (latestReport?.daysFromSpud || 0) - (well.plannedDays || 0),
        costToDate: totalActual,
        estimatedCost: totalEstimated,
        costVariancePct: totalEstimated > 0 ? ((totalActual - totalEstimated) / totalEstimated) * 100 : 0
      };
    });

    this.on('getDrillingSummary', async (req) => {
      const { wellId } = req.data;

      const reports = await SELECT.from(DailyReports).where({ well_ID: wellId, status: 'Approved' });

      const totalDays = reports.length;
      const productiveHours = reports.reduce((sum, r) => sum + (r.productiveHours || 0), 0);
      const nptHours = reports.reduce((sum, r) => sum + (r.nptHours || 0), 0);
      const totalCost = reports.reduce((sum, r) => sum + (r.totalCost || 0), 0);
      const totalFootage = reports.reduce((sum, r) => sum + (r.footageDrilled || 0), 0);

      return {
        totalDays: totalDays,
        productiveHours: productiveHours,
        nptHours: nptHours,
        nptPct: (productiveHours + nptHours) > 0 ? (nptHours / (productiveHours + nptHours)) * 100 : 0,
        avgCostPerDay: totalDays > 0 ? totalCost / totalDays : 0,
        avgFootagePerDay: totalDays > 0 ? totalFootage / totalDays : 0
      };
    });

    this.on('getNPTAnalysis', async (req) => {
      const { wellId } = req.data;

      const activities = await SELECT.from(DailyActivities)
        .columns('nptCategory', 'sum(duration) as totalHours')
        .where({ 'report.well_ID': wellId, isNPT: true })
        .groupBy('nptCategory');

      const totalNPT = activities.reduce((sum, a) => sum + (a.totalHours || 0), 0);

      return activities.map(a => ({
        category: a.nptCategory || 'Uncategorized',
        hours: a.totalHours || 0,
        pct: totalNPT > 0 ? ((a.totalHours || 0) / totalNPT) * 100 : 0,
        cost: 0 // Would need cost per hour to calculate
      }));
    });

    // ===========================================
    // HELPER METHODS
    // ===========================================

    this._updateReportTotals = async (reportId) => {
      // Calculate activity hours
      const activities = await SELECT.from(DailyActivities).where({ report_ID: reportId });
      const productiveHours = activities.filter(a => !a.isNPT).reduce((sum, a) => sum + (a.duration || 0), 0);
      const nptHours = activities.filter(a => a.isNPT).reduce((sum, a) => sum + (a.duration || 0), 0);

      // Calculate costs
      const costs = await SELECT.from(DailyCosts).where({ report_ID: reportId });
      const totalCost = costs.reduce((sum, c) => sum + (c.totalCost || 0), 0);

      await UPDATE(DailyReports).set({
        productiveHours: productiveHours,
        nptHours: nptHours,
        totalCost: totalCost,
        modifiedAt: new Date()
      }).where({ ID: reportId });
    };

    await super.init();
  }
};
