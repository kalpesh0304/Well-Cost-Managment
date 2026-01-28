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
    { Value: reportNumber, Label: 'Report #', ![@UI.Importance]: #High },
    { Value: reportDate, Label: 'Date', ![@UI.Importance]: #High },
    { Value: well.wellName, Label: 'Well', ![@UI.Importance]: #High },
    { Value: dayNumber, Label: 'Day #' },
    { Value: currentDepth, Label: 'Current Depth' },
    { Value: dailyFootage, Label: 'Daily Footage' },
    { Value: dailyCost, Label: 'Daily Cost', ![@UI.Importance]: #High },
    { Value: cumulativeCost, Label: 'Cum. Cost' },
    { Value: status, Label: 'Status', Criticality: statusCriticality }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'GeneralInfoFacet',
      Label: 'Report Summary',
      Target: '@UI.FieldGroup#GeneralInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'DepthInfoFacet',
      Label: 'Depth Information',
      Target: '@UI.FieldGroup#DepthInfo'
    },
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'TimeInfoFacet',
      Label: 'Time Breakdown',
      Target: '@UI.FieldGroup#TimeInfo'
    },
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
  ],

  UI.FieldGroup#GeneralInfo: {
    Label: 'Report Summary',
    Data: [
      { Value: reportNumber, Label: 'Report Number' },
      { Value: reportDate, Label: 'Report Date' },
      { Value: well_ID, Label: 'Well' },
      { Value: afe_ID, Label: 'AFE' },
      { Value: dayNumber, Label: 'Day Number' },
      { Value: status, Label: 'Status' },
      { Value: weatherConditions, Label: 'Weather Conditions' },
      { Value: remarks, Label: 'Remarks' }
    ]
  },

  UI.FieldGroup#DepthInfo: {
    Label: 'Depth Information',
    Data: [
      { Value: startDepth, Label: 'Start Depth' },
      { Value: currentDepth, Label: 'Current Depth' },
      { Value: dailyFootage, Label: 'Daily Footage' },
      { Value: targetDepth, Label: 'Target Depth' },
      { Value: depthProgress, Label: 'Depth Progress %' }
    ]
  },

  UI.FieldGroup#TimeInfo: {
    Label: 'Time Breakdown',
    Data: [
      { Value: productiveHours, Label: 'Productive Hours' },
      { Value: nptHours, Label: 'NPT Hours' },
      { Value: waitingHours, Label: 'Waiting Hours' },
      { Value: totalHours, Label: 'Total Hours' },
      { Value: dailyCost, Label: 'Daily Cost' },
      { Value: cumulativeCost, Label: 'Cumulative Cost' }
    ]
  }
);

annotate OperationsService.DailyReports with {
  ID @UI.Hidden;
  statusCriticality @Core.Computed;
  reportNumber @title: 'Report Number';
  reportDate @title: 'Report Date' @Common.FieldControl: #Mandatory;
  well @title: 'Well' @Common.FieldControl: #Mandatory;
  dailyCost @title: 'Daily Cost' @Measures.ISOCurrency: currency_code;
  cumulativeCost @title: 'Cumulative Cost' @Measures.ISOCurrency: currency_code;
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
    { Value: startTime, Label: 'Start', ![@UI.Importance]: #High },
    { Value: endTime, Label: 'End', ![@UI.Importance]: #High },
    { Value: activityCode, Label: 'Code' },
    { Value: description, Label: 'Description', ![@UI.Importance]: #High },
    { Value: duration, Label: 'Duration (hrs)', ![@UI.Importance]: #High },
    { Value: activityType, Label: 'Type' },
    { Value: isNPT, Label: 'NPT', Criticality: nptCriticality },
    { Value: depthFrom, Label: 'From Depth' },
    { Value: depthTo, Label: 'To Depth' }
  ]
);

annotate OperationsService.DailyActivities with {
  ID @UI.Hidden;
  report @UI.Hidden;
  nptCriticality @Core.Computed;
  description @title: 'Description' @Common.FieldControl: #Mandatory;
  duration @title: 'Duration (hrs)' @Common.FieldControl: #Mandatory;
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
    TypeNamePlural: 'Daily Costs',
    Title: { Value: costElement.elementName }
  },

  UI.LineItem: [
    { Value: costElement.elementName, Label: 'Cost Element', ![@UI.Importance]: #High },
    { Value: vendor.vendorName, Label: 'Vendor' },
    { Value: description, Label: 'Description', ![@UI.Importance]: #High },
    { Value: quantity, Label: 'Quantity' },
    { Value: unitRate, Label: 'Unit Rate' },
    { Value: amount, Label: 'Amount', ![@UI.Importance]: #High }
  ]
);

annotate OperationsService.DailyCosts with {
  ID @UI.Hidden;
  report @UI.Hidden;
  amount @title: 'Amount' @Common.FieldControl: #Mandatory @Measures.ISOCurrency: currency_code;
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
    { Value: alertType, Label: 'Type', ![@UI.Importance]: #High },
    { Value: severity, Label: 'Severity', Criticality: severityCriticality, ![@UI.Importance]: #High },
    { Value: title, Label: 'Title', ![@UI.Importance]: #High },
    { Value: well.wellName, Label: 'Well' },
    { Value: afe.afeNumber, Label: 'AFE' },
    { Value: status, Label: 'Status', Criticality: statusCriticality },
    { Value: triggeredAt, Label: 'Triggered At' },
    { Value: acknowledgedBy, Label: 'Acknowledged By' }
  ],

  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      ID: 'AlertDetailsFacet',
      Label: 'Alert Details',
      Target: '@UI.FieldGroup#AlertDetails'
    }
  ],

  UI.FieldGroup#AlertDetails: {
    Label: 'Alert Details',
    Data: [
      { Value: alertType, Label: 'Alert Type' },
      { Value: severity, Label: 'Severity' },
      { Value: title, Label: 'Title' },
      { Value: message, Label: 'Message' },
      { Value: well_ID, Label: 'Well' },
      { Value: afe_ID, Label: 'AFE' },
      { Value: status, Label: 'Status' },
      { Value: triggeredAt, Label: 'Triggered At' },
      { Value: acknowledgedAt, Label: 'Acknowledged At' },
      { Value: acknowledgedBy, Label: 'Acknowledged By' },
      { Value: resolvedAt, Label: 'Resolved At' },
      { Value: resolvedBy, Label: 'Resolved By' }
    ]
  }
);

annotate OperationsService.Alerts with {
  ID @UI.Hidden;
  severityCriticality @Core.Computed;
  statusCriticality @Core.Computed;
  alertType @title: 'Alert Type' @Common.FieldControl: #Mandatory;
  severity @title: 'Severity' @Common.FieldControl: #Mandatory;
  title @title: 'Title' @Common.FieldControl: #Mandatory;
  message @title: 'Message' @Common.FieldControl: #Mandatory;
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
    TypeNamePlural: 'Cost Forecasts',
    Title: { Value: afe.afeNumber },
    Description: { Value: forecastDate }
  },

  UI.SelectionFields: [
    afe_ID,
    forecastType,
    status
  ],

  UI.LineItem: [
    { Value: afe.afeNumber, Label: 'AFE', ![@UI.Importance]: #High },
    { Value: forecastDate, Label: 'Forecast Date', ![@UI.Importance]: #High },
    { Value: forecastType, Label: 'Type' },
    { Value: budgetAmount, Label: 'Budget', ![@UI.Importance]: #High },
    { Value: actualToDate, Label: 'Actual to Date' },
    { Value: forecastAmount, Label: 'Forecast', ![@UI.Importance]: #High },
    { Value: varianceAmount, Label: 'Variance', Criticality: varianceCriticality },
    { Value: variancePercent, Label: 'Var %', Criticality: varianceCriticality },
    { Value: status, Label: 'Status' }
  ]
);

annotate OperationsService.CostForecasts with {
  ID @UI.Hidden;
  varianceCriticality @Core.Computed;
  budgetAmount @title: 'Budget Amount' @Measures.ISOCurrency: currency_code;
  actualToDate @title: 'Actual to Date' @Measures.ISOCurrency: currency_code;
  forecastAmount @title: 'Forecast Amount' @Measures.ISOCurrency: currency_code;
  varianceAmount @title: 'Variance Amount' @Measures.ISOCurrency: currency_code;
}

// ============================================
// KPI SNAPSHOTS (Read-Only)
// ============================================
annotate OperationsService.KPISnapshots with @(
  UI.HeaderInfo: {
    TypeName: 'KPI Snapshot',
    TypeNamePlural: 'KPI Snapshots',
    Title: { Value: snapshotDate }
  },

  UI.SelectionFields: [
    well_ID,
    snapshotDate,
    snapshotType
  ],

  UI.LineItem: [
    { Value: snapshotDate, Label: 'Date', ![@UI.Importance]: #High },
    { Value: well.wellName, Label: 'Well', ![@UI.Importance]: #High },
    { Value: snapshotType, Label: 'Type' },
    { Value: budgetAmount, Label: 'Budget' },
    { Value: actualAmount, Label: 'Actual' },
    { Value: varianceAmount, Label: 'Variance', Criticality: varianceCriticality },
    { Value: variancePercent, Label: 'Var %' },
    { Value: depthProgress, Label: 'Depth %' },
    { Value: scheduleProgress, Label: 'Schedule %' }
  ]
);
