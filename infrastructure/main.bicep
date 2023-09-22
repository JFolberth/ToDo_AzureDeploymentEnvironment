@description('Location for all resources.')
param location string
@description('Base name that will appear for all resources.') 
param baseName string = 'adecosmosapp'
@description('Three letter environment abreviation to denote environment that will appear in all resource names') 
param environmentName string = 'dev'
@description('App Service Plan Sku') 
param appServicePlanSKU string = 'D1'
@description('Resource Group Log Analytics Workspace is in')
param logAnalyticsResourceGroup string 
@description('Log Analytics Workspace Name')
param logAnalyticsWorkspace string
@description('Resource Group CosmosDB is in')
param cosmosDBResourceGroup string
@description('CosmosDB Name')
param cosmosDBName string
@description('Dev Center Project Name')
param devCenterProjectName string = ''
@description('Name for the Azure Deployment Environment')
param adeName string =  ''


var regionReference = {
  centralus: 'cus'
  eastus: 'eus'
  westus: 'wus'
  westus2: 'wus2'
}

var language = 'Bicep'

targetScope = 'subscription'
var nameSuffix = empty(adeName) ?  toLower('${baseName}-${environmentName}-${regionReference[location]}') : '${devCenterProjectName}-${adeName}'
var rgName = 'rg-${nameSuffix}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspace
  scope: resourceGroup(logAnalyticsResourceGroup)
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing ={
  name: cosmosDBName
  scope: resourceGroup(cosmosDBResourceGroup)
}
module  resourceGroups 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/resourcegroup:v1' = if(!empty(adeName)) {
  name: 'resourceGroupModule${nameSuffix}'
  params:{
    baseName:nameSuffix
    location: location
    tags:{}
    }
    scope: subscription()
  }

module userAssignedIdentity 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/userassignedidentity:v1' ={
  name: 'userAssignedIdentityModule'
  params:{
    location: location
    userIdentityName: nameSuffix
  }
  scope: resourceGroup(rgName)
}

module appServicePlan 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/appserviceplan:v1' ={
  name: 'appServicePlanModule'
  params:{
    location: location
    appServicePlanName: nameSuffix
    language: language
    appServicePlanSKU: appServicePlanSKU
  }
  scope: resourceGroup(rgName)
}

module appService 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/appservice:v1' ={
  name: 'appServiceModule'
  params:{
    location: location
    appServicePlanID: appServicePlan.outputs.appServicePlanID
    appServiceName: nameSuffix
    principalId: userAssignedIdentity.outputs.userIdentityResrouceId
    appSettingsArray: [
      {
       name:'APPINSIGHTS_INSTRUMENTATIONKEY'
       value: appInsights.outputs.appInsightsInstrumentationKey
    }
    {
      name: 'ConnectionString'
      value: 'AccountEndpoint=https://${cosmosDB.name}.documents.azure.com:443/;'
    }
  ]
  }
  scope: resourceGroup(rgName)
}


module appInsights 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/appinsights:v1' ={
  name: 'appInsightsModule'
  params:{
    location: location
    appInsightsName: nameSuffix
    logAnalyticsWorkspaceID: logAnalytics.id
    language: language
  }
  scope: resourceGroup(rgName)
}

module cosmosRBAC 'br:acrbicepregistrydeveus.azurecr.io/bicep/modules/cosmossqldbroleassignment:v1' ={
  name: 'cosmosRBACModule'
  scope: resourceGroup(cosmosDBResourceGroup)
  params: {
    databaseAccountName: cosmosDB.name
    databaseAccountResourceGroup: cosmosDBResourceGroup
    principalId: userAssignedIdentity.outputs.userIdentityPrincipalOutput
  }
}




