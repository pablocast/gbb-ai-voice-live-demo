@description('The name of the Container Apps Environment')
param name string

@description('The location of the Container Apps Environment')
param location string = resourceGroup().location

@description('Tags to apply to the Container Apps Environment')
param tags object = {}

@description('The name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

@description('The resource ID of the Container Apps Environment')
output id string = containerAppsEnvironment.id

@description('The name of the Container Apps Environment')
output name string = containerAppsEnvironment.name

@description('The default domain of the Container Apps Environment')
output defaultDomain string = containerAppsEnvironment.properties.defaultDomain
