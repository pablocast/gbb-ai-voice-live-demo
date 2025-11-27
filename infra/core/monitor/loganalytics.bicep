@description('The name of the Log Analytics workspace')
param name string

@description('The location of the Log Analytics workspace')
param location string = resourceGroup().location

@description('Tags to apply to the Log Analytics workspace')
param tags object = {}

@description('The SKU of the Log Analytics workspace')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string = 'PerGB2018'

@description('The data retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

@description('The resource ID of the Log Analytics workspace')
output id string = logAnalytics.id

@description('The name of the Log Analytics workspace')
output name string = logAnalytics.name

@description('The customer ID of the Log Analytics workspace')
output customerId string = logAnalytics.properties.customerId
