# Azure Deployment Guide

This guide explains how to deploy the Voice Live Avatar application to Azure using Azure Container Apps and Azure Container Registry.

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) installed
- An Azure subscription
- Docker installed (for local testing)

## Architecture

The deployment uses the following Azure resources:

- **Azure Container Registry (ACR)**: Stores the container image
- **Azure Container Apps**: Hosts the application
- **Azure Container Apps Environment**: Provides the managed environment
- **Log Analytics Workspace**: Collects logs and metrics

## Deployment Steps

### Option 1: Using Azure Developer CLI (Recommended)

1. **Login to Azure**:
   ```bash
   azd auth login
   ```

2. **Initialize the environment** (first time only):
   ```bash
   azd init
   ```

3. **Provision and deploy**:
   ```bash
   azd up
   ```

   This single command will:
   - Provision all Azure resources
   - Build the Docker container
   - Push the container to ACR
   - Deploy the container to Container Apps

4. **View the application**:
   After deployment, azd will output the URL of your application.

### Option 2: Manual Deployment

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Set your subscription**:
   ```bash
   az account set --subscription "Your-Subscription-Name"
   ```

3. **Create a resource group** (if needed):
   ```bash
   az group create --name rg-voice-live-avatar --location eastus
   ```

4. **Deploy the infrastructure**:
   ```bash
   az deployment sub create \
     --location eastus \
     --template-file ./infra/main.bicep \
     --parameters environmentName=voice-live-avatar \
                  location=eastus
   ```

5. **Build and push the Docker image**:
   ```bash
   # Get ACR login server
   ACR_NAME=$(az deployment sub show --name main --query properties.outputs.AZURE_CONTAINER_REGISTRY_NAME.value -o tsv)
   
   # Login to ACR
   az acr login --name $ACR_NAME
   
   # Build and push
   docker build -t $ACR_NAME.azurecr.io/voice-live-avatar:latest .
   docker push $ACR_NAME.azurecr.io/voice-live-avatar:latest
   ```

6. **Update the Container App with the new image**:
   ```bash
   az containerapp update \
     --name <container-app-name> \
     --resource-group <resource-group-name> \
     --image $ACR_NAME.azurecr.io/voice-live-avatar:latest
   ```

## Environment Variables

The application may require environment variables. You can set them during deployment:

```bash
azd env set VARIABLE_NAME "value"
```

Or via Bicep parameters by modifying the `environmentVariables` array in `infra/core/host/container-app.bicep`.

## Monitoring and Logs

1. **View application logs**:
   ```bash
   az containerapp logs show \
     --name <container-app-name> \
     --resource-group <resource-group-name> \
     --follow
   ```

2. **View in Azure Portal**:
   - Navigate to your Container App in the Azure Portal
   - Click on "Log stream" or "Monitoring" -> "Logs"

## Updating the Application

To deploy updates:

```bash
azd deploy
```

This will rebuild the container and deploy the new version.

## Scaling

You can modify the scaling settings in `infra/core/host/container-app.bicep`:

```bicep
scale: {
  minReplicas: 1
  maxReplicas: 10
}
```

## Cleanup

To delete all Azure resources:

```bash
azd down
```

Or manually:

```bash
az group delete --name rg-voice-live-avatar --yes --no-wait
```

## Troubleshooting

### Container won't start
- Check the logs: `az containerapp logs show --name <app-name> --resource-group <rg-name>`
- Verify the container image is correct
- Check environment variables are set correctly

### ACR authentication issues
- Ensure the Container App's managed identity has `AcrPull` role on the Container Registry
- This is configured automatically in the Bicep template

### Port issues
- Ensure the `targetPort` in the Bicep matches the port your application listens on (3000 for this app)

## Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
