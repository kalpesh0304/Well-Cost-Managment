const cds = require('@sap/cds');

module.exports = class OperationsService extends cds.ApplicationService {

  async init() {
    const { DailyReports, Alerts, CostForecasts, KPISnapshots } = this.entities;

    // ============================================
    // DAILY REPORTS CRUD
    // ============================================
    this.before('CREATE', DailyReports, async (req) => {
      const { well_ID, reportDate } = req.data;
      // Check for duplicate
      const exists = await SELECT.one.from(DailyReports).where({ well_ID, reportDate });
      if (exists) req.error(409, `Daily report for this well on ${reportDate} already exists`);

      if (!req.data.status) req.data.status = 'Draft';
      if (!req.data.dayNumber) {
        // Calculate day number from well spud date
        req.data.dayNumber = 1;
      }
      // Calculate cumulative cost
      if (req.data.dailyCost) {
        const prevReports = await SELECT.from(DailyReports)
          .where({ well_ID, reportDate: { '<': reportDate } })
          .orderBy('reportDate desc');
        const prevCumulative = prevReports[0]?.cumulativeCost || 0;
        req.data.cumulativeCost = prevCumulative + req.data.dailyCost;
      }
    });

    this.before('UPDATE', DailyReports, async (req) => {
      const { ID, status } = req.data;
      const report = await SELECT.one.from(DailyReports).where({ ID });
      if (report?.status === 'Approved' && status !== 'Approved') {
        req.error(400, 'Cannot modify an approved daily report');
      }
    });

    // ============================================
    // ALERTS CRUD
    // ============================================
    this.before('CREATE', Alerts, async (req) => {
      if (!req.data.status) req.data.status = 'Active';
      if (!req.data.triggeredAt) req.data.triggeredAt = new Date().toISOString();
    });

    // ============================================
    // COST FORECASTS CRUD
    // ============================================
    this.before('CREATE', CostForecasts, async (req) => {
      // Calculate forecast at completion
      if (req.data.actualToDate !== undefined && req.data.forecastToComplete !== undefined) {
        req.data.forecastAtCompletion = req.data.actualToDate + req.data.forecastToComplete;
        if (req.data.estimatedTotal) {
          req.data.varianceAtCompletion = req.data.forecastAtCompletion - req.data.estimatedTotal;
        }
      }
    });

    // ============================================
    // ACTIONS
    // ============================================
    this.on('submitReport', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(DailyReports).set({
        status: 'Submitted',
        submittedAt: new Date().toISOString(),
        submittedBy: req.user.id
      }).where({ ID });
      return SELECT.one.from(DailyReports).where({ ID });
    });

    this.on('approveReport', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(DailyReports).set({
        status: 'Approved',
        approvedAt: new Date().toISOString(),
        approvedBy: req.user.id
      }).where({ ID });
      return SELECT.one.from(DailyReports).where({ ID });
    });

    this.on('acknowledgeAlert', async (req) => {
      const { ID } = req.params[0];
      await UPDATE(Alerts).set({
        status: 'Acknowledged',
        acknowledgedAt: new Date().toISOString(),
        acknowledgedBy: req.user.id
      }).where({ ID });
      return SELECT.one.from(Alerts).where({ ID });
    });

    this.on('resolveAlert', async (req) => {
      const { ID } = req.params[0];
      const { resolution } = req.data || {};
      await UPDATE(Alerts).set({
        status: 'Resolved',
        resolvedAt: new Date().toISOString(),
        resolvedBy: req.user.id
      }).where({ ID });
      return SELECT.one.from(Alerts).where({ ID });
    });

    this.on('generateForecast', async (req) => {
      const { afeId } = req.data;
      // Simplified forecast generation
      const forecast = {
        ID: cds.utils.uuid(),
        afe_ID: afeId,
        forecastDate: new Date().toISOString().split('T')[0],
        forecastType: 'Trend',
        estimatedTotal: 15000000,
        actualToDate: 5000000,
        forecastToComplete: 11000000,
        forecastAtCompletion: 16000000,
        varianceAtCompletion: 1000000,
        confidenceLevel: 'Medium',
        confidencePct: 0.75,
        generatedBy: 'SYSTEM'
      };
      await INSERT.into(CostForecasts).entries(forecast);
      return forecast;
    });

    this.on('createKPISnapshot', async (req) => {
      const { wellId, snapshotType } = req.data;
      const snapshot = {
        ID: cds.utils.uuid(),
        snapshotDate: new Date().toISOString().split('T')[0],
        snapshotType: snapshotType || 'Daily',
        well_ID: wellId,
        totalEstimated: 15000000,
        totalActual: 5000000,
        totalCommitted: 3000000,
        variancePct: -0.05,
        plannedDays: 45,
        actualDays: 20,
        scheduleVariance: 0,
        incidentCount: 0,
        nptHours: 12.5
      };
      await INSERT.into(KPISnapshots).entries(snapshot);
      return snapshot;
    });

    this.on('triggerCostAlert', async (req) => {
      const { afeId, wellId, alertType, message } = req.data;
      const alert = {
        ID: cds.utils.uuid(),
        alertType: alertType || 'CostOverrun',
        severity: 'Warning',
        title: `Cost Alert for AFE`,
        message: message || 'Cost threshold exceeded',
        afe_ID: afeId,
        well_ID: wellId,
        status: 'Active',
        triggeredAt: new Date().toISOString()
      };
      await INSERT.into(Alerts).entries(alert);
      return alert;
    });

    // ============================================
    // FUNCTIONS
    // ============================================
    this.on('getDailyReportsByWell', async (req) => {
      const { wellId, fromDate, toDate } = req.data;
      let query = SELECT.from(DailyReports).where({ well_ID: wellId });
      if (fromDate && toDate) {
        query = query.and({ reportDate: { between: fromDate, and: toDate } });
      }
      return query.orderBy('reportDate desc');
    });

    this.on('getActiveAlerts', async () => {
      return SELECT.from(Alerts).where({ status: 'Active' }).orderBy('triggeredAt desc');
    });

    this.on('getAlertsByWell', async (req) => {
      const { wellId } = req.data;
      return SELECT.from(Alerts).where({ well_ID: wellId });
    });

    this.on('getWellProgress', async (req) => {
      const { wellId } = req.data;
      const reports = await SELECT.from(DailyReports).where({ well_ID: wellId }).orderBy('reportDate desc');
      const latest = reports[0];

      return {
        wellId,
        currentDepthMD: latest?.depthMD || 0,
        currentDepthTVD: latest?.depthTVD || 0,
        totalDays: latest?.dayNumber || 0,
        cumulativeCost: latest?.cumulativeCost || 0,
        totalNPTHours: reports.reduce((sum, r) => sum + (r.nptHours || 0), 0),
        currentPhase: latest?.operationPhase || 'Unknown',
        reportCount: reports.length
      };
    });

    this.on('getCostTrend', async (req) => {
      const { wellId, days } = req.data;
      const fromDate = new Date();
      fromDate.setDate(fromDate.getDate() - (days || 30));

      return SELECT.from(DailyReports)
        .where({ well_ID: wellId, reportDate: { '>=': fromDate.toISOString().split('T')[0] } })
        .orderBy('reportDate');
    });

    this.on('getLatestForecast', async (req) => {
      const { afeId } = req.data;
      return SELECT.one.from(CostForecasts)
        .where({ afe_ID: afeId })
        .orderBy('forecastDate desc');
    });

    await super.init();
  }
};
