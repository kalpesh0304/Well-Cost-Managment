// UI Annotations for Operations Service
using OperationsService from './operations-service';

// ============================================
// DAILY REPORTS
// ============================================
annotate OperationsService.DailyReports with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Daily Report',
    TypeNamePlural: 'Daily Reports',
    Title: { Value: reportNumber },
    Description: { Value: reportDate }
  },

  UI.SelectionFields: [
    well_ID,
    reportDate,
    status
  ],

  UI.LineItem: [
    { Value: reportNumber, Label: 'Report #' },
    { Value: reportDate, Label: 'Date' },
    { Value: dayNumber, Label: 'Day #' },
    { Value: currentDepth, Label: 'Current Depth' },
    { Value: dailyFootage, Label: 'Daily Footage' },
    { Value: dailyCost, Label: 'Daily Cost' },
    { Value: cumulativeCost, Label: 'Cum. Cost' },
    { Value: status, Label: 'Status' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'ActivitiesFacet',
      Label: 'Activities',
      Target: 'activities/@UI.LineItem'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'CostsFacet',
      Label: 'Daily Costs',
      Target: 'costs/@UI.LineItem'
    }
  ]
);

annotate OperationsService.DailyReports with {
  ID @UI.Hidden;
  reportNumber @title: 'Report Number';
  reportDate @title: 'Report Date';
  dailyCost @title: 'Daily Cost';
}

// ============================================
// DAILY ACTIVITIES
// ============================================
annotate OperationsService.DailyActivities with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Activity',
    TypeNamePlural: 'Activities',
    Title: { Value: activityCode },
    Description: { Value: description }
  },

  UI.LineItem: [
    { Value: startTime, Label: 'Start' },
    { Value: endTime, Label: 'End' },
    { Value: activityCode, Label: 'Code' },
    { Value: description, Label: 'Description' },
    { Value: duration, Label: 'Duration (hrs)' },
    { Value: activityType, Label: 'Type' },
    { Value: isNPT, Label: 'NPT' },
    { Value: depthFrom, Label: 'From Depth' },
    { Value: depthTo, Label: 'To Depth' }
  ]
);

annotate OperationsService.DailyActivities with {
  ID @UI.Hidden;
  report @UI.Hidden;
  description @title: 'Description';
  duration @title: 'Duration (hrs)';
}

// ============================================
// DAILY COSTS
// ============================================
annotate OperationsService.DailyCosts with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Daily Cost',
    TypeNamePlural: 'Daily Costs'
  },

  UI.LineItem: [
    { Value: description, Label: 'Description' },
    { Value: quantity, Label: 'Quantity' },
    { Value: unitRate, Label: 'Unit Rate' },
    { Value: amount, Label: 'Amount' }
  ]
);

annotate OperationsService.DailyCosts with {
  ID @UI.Hidden;
  report @UI.Hidden;
  amount @title: 'Amount';
}

// ============================================
// ALERTS
// ============================================
annotate OperationsService.Alerts with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: false }
  },

  UI.HeaderInfo: {
    TypeName: 'Alert',
    TypeNamePlural: 'Alerts',
    Title: { Value: title },
    Description: { Value: alertType }
  },

  UI.SelectionFields: [
    well_ID,
    alertType,
    severity,
    status
  ],

  UI.LineItem: [
    { Value: alertType, Label: 'Type' },
    { Value: severity, Label: 'Severity' },
    { Value: title, Label: 'Title' },
    { Value: status, Label: 'Status' },
    { Value: triggeredAt, Label: 'Triggered At' },
    { Value: acknowledgedBy, Label: 'Acknowledged By' }
  ]
);

annotate OperationsService.Alerts with {
  ID @UI.Hidden;
  alertType @title: 'Alert Type';
  severity @title: 'Severity';
  title @title: 'Title';
  message @title: 'Message';
}

// ============================================
// COST FORECASTS
// ============================================
annotate OperationsService.CostForecasts with @(
  Capabilities: {
    InsertRestrictions: { Insertable: true },
    UpdateRestrictions: { Updatable: true },
    DeleteRestrictions: { Deletable: true }
  },

  UI.HeaderInfo: {
    TypeName: 'Cost Forecast',
    TypeNamePlural: 'Cost Forecasts'
  },

  UI.SelectionFields: [
    afe_ID,
    forecastType,
    status
  ],

  UI.LineItem: [
    { Value: forecastDate, Label: 'Forecast Date' },
    { Value: forecastType, Label: 'Type' },
    { Value: budgetAmount, Label: 'Budget' },
    { Value: actualToDate, Label: 'Actual to Date' },
    { Value: forecastAmount, Label: 'Forecast' },
    { Value: varianceAmount, Label: 'Variance' },
    { Value: variancePercent, Label: 'Var %' },
    { Value: status, Label: 'Status' }
  ]
);

annotate OperationsService.CostForecasts with {
  ID @UI.Hidden;
  budgetAmount @title: 'Budget Amount';
  forecastAmount @title: 'Forecast Amount';
}
