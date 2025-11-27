using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'voice-live-avatar')
param webAppExists = false 
param azureContainerAppsWorkloadProfile = 'Consumption'
