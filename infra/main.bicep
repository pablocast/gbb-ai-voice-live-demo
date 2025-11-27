// ------------------
//    PARAMETERS
// ------------------

@allowed(['Consumption', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32', 'NC24-A100', 'NC48-A100', 'NC96-A100'])
param azureContainerAppsWorkloadProfile string
param environmentName string

@description('Used by azd for containerapps deployment')
param webAppExists bool

// ------------------
//    VARIABLES
// ------------------
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
var resourceSuffix = uniqueString(subscription().id, resourceGroup().id, deploymentTimestamp)
var tags = { 'azd-env-name': environmentName }

// ------------------
//    RESOURCES
// ------------------

// 1. Log Analytics Workspace
module lawModule './core/monitor/workspaces.bicep' = {
  name: 'lawModule'
  params: {
    resourceSuffix: resourceSuffix
  }
}

// 2. Application Insights
module appInsightsModule './core/monitor/appinsights.bicep' = {
  name: 'appInsightsModule'
  params: {
    lawId: lawModule.outputs.id
    customMetricsOptedInType: 'WithDimensions'
    resourceSuffix: resourceSuffix
  }
}


// Azure container apps resources
// User-assigned identity for pulling images from ACR
var acaIdentityName = 'aca-identity-${resourceSuffix}'
module acaIdentity './core/security/aca-identity.bicep' = {
  name: 'aca-identity'
  scope: resourceGroup()
  params: {
    identityName: acaIdentityName
    location: resourceGroup().location
  }
}

module containerApps './core/host/container-apps.bicep' = {
  name: 'container-apps'
  scope: resourceGroup()
  params: {
    name: 'app'
    tags: tags
    location: resourceGroup().location
    workloadProfile: azureContainerAppsWorkloadProfile
    containerAppsEnvironmentName: '${environmentName}-aca-env-${resourceSuffix}'
    containerRegistryName: 'containerregistry${resourceSuffix}'
    logAnalyticsWorkspaceResourceId: lawModule.outputs.id
  }
}

// Container Apps for the web application (Python Quart app with JS frontend)
module acaBackend './core/host/container-app-upsert.bicep' = {
  name: 'aca-web'
  scope: resourceGroup()
  dependsOn: [
    containerApps
    acaIdentity
  ]
  params: {
    name: 'webapp-backend-${resourceSuffix}'
    location: resourceGroup().location
    identityName: acaIdentityName
    exists: webAppExists
    workloadProfile: azureContainerAppsWorkloadProfile
    containerRegistryName: containerApps.outputs.registryName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    identityType: 'UserAssigned'
    tags: union(tags, { 'azd-service-name': 'web' })
    targetPort: 3000
    containerCpuCoreCount: '2.0'
    containerMemory: '4Gi'
  }
}



// ------------------
//    OUTPUTS
// ------------------

output logAnalyticsWorkspaceId string = lawModule.outputs.customerId
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer
output WEBSITE_URL string = acaBackend.outputs.uri
