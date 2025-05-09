@description('Location for all resources.')
param location string
@description('Base name that will appear for all resources.') 
param baseName string = 'adecosmosapp2'
@description('Three letter environment abreviation to denote environment that will appear in all resource names') 
param environmentName string = 'cicd'
@description('App Service Plan Sku') 
param appServicePlanSKU string = 'B1'
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

//targetScope = 'subscription'
var nameSuffix = empty(adeName) ?  toLower('${baseName}-${environmentName}-${regionReference[location]}') : '${devCenterProjectName}-${adeName}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspace
  scope: resourceGroup(logAnalyticsResourceGroup)
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing ={
  name: cosmosDBName
  scope: resourceGroup(cosmosDBResourceGroup)
}
module userAssignedIdentity 'br:acrbicepregistry.azurecr.io/module/managedidentity/userassignedidentities:v1' ={
  name: 'userAssignedIdentityModule'
  params:{
    location: location
    userIdentityName: nameSuffix
  }
}

module appServicePlan 'br:acrbicepregistry.azurecr.io/module/web/serverfarms:v1' ={
  name: 'appServicePlanModule'
  params:{
    location: location
    appServicePlanName: nameSuffix
    language: language
    appServicePlanSKU: appServicePlanSKU
    appServiceKind: 'linux'
  }
}

module appService 'br:acrbicepregistry.azurecr.io/module/web/sites:v1' ={
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
      name: 'CosmosDb:Account'
      value: 'https://${cosmosDB.name}.documents.azure.com:443/'
    }
    {
      name: 'CosmosDb:DatabaseName'
      value: 'Tasks'
    }
    {
      name: 'CosmosDb:ContainerName'
      value: 'Item'
    }
    {
      name: 'WEBSITE_RUN_FROM_PACKAGE'
      value: '1'
    }
    {
      name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
      value: 'true'
    }
    {
      name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
      value: '~2'
    }
  ]
  }
}


module appInsights 'br:acrbicepregistry.azurecr.io/module/insights/components:v1' ={
  name: 'appInsightsModule'
  params:{
    location: location
    appInsightsName: nameSuffix
    logAnalyticsWorkspaceID: logAnalytics.id
    language: language
  }
}

module cosmosRBAC 'br:acrbicepregistry.azurecr.io/module/documentdb/databaseaccounts/sqldatabases/sqlroleassignment:v1' ={
  name: 'cosmosRBACModule'
  scope: resourceGroup(cosmosDBResourceGroup)
  params: {
    databaseAccountName: cosmosDB.name
    databaseAccountResourceGroup: cosmosDBResourceGroup
    principalId: appService.outputs.appServiceManagedIdentity
  }
}




