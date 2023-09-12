@description('Location for all resources.')
param location string
@description('Base name that will appear for all resources.') 
param baseName string = 'iacflavorsbicepASP'
@description('Three letter environment abreviation to denote environment that will appear in all resource names') 
param environmentName string = 'dev'
@description('App Service Plan Sku')
param appServicePlanSKU string
@description('How many days to retain Log Analytics Logs')
param retentionDays int


var regionReference = {
  centralus: 'cus'
  eastus: 'eus'
  westus: 'wus'
  westus2: 'wus2'
}
var nameSuffix = toLower('${baseName}-${environmentName}-${regionReference[location]}')
var language = 'Bicep'


module appServicePlan 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/appserviceplan:v1' ={
  name: 'appServicePlanModule'
  params:{
    location: location
    appServicePlanName: nameSuffix
    language: language
    appServicePlanSKU: appServicePlanSKU
  }
}

module appService 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/appservice:v1' ={
  name: 'appServiceModule'
  params:{
    location: location
    appServicePlanID: appServicePlan.outputs.appServicePlanID
    appServiceName: nameSuffix
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    language: language
  }
}

module logAnalytics 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/loganalytics:v1' ={
  name: 'logAnalyticsModule'
  params:{
    location: location
    logAnalyticsName: nameSuffix
    language: language
    retentionDays: retentionDays
  }
}

module appInsights 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/appinsights:v1' ={
  name: 'appInsightsModule'
  params:{
    location: location
    appInsightsName: nameSuffix
    logAnalyticsWorkspaceID: logAnalytics.outputs.logAnalyticsWorkspaceID
    language: language
  }
}

