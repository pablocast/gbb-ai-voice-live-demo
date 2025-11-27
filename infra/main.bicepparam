using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'voice-live-avatar')
param location = readEnvironmentVariable('AZURE_LOCATION', 'eastus')
param principalId = readEnvironmentVariable('AZURE_PRINCIPAL_ID', '')
