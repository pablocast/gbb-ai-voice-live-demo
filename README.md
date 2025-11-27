# Microsoft Azure Voice Live with Avatar Sample

This sample demonstrates the usage of Azure Voice Live API with avatar capabilities, enabling real-time voice conversations with AI-powered avatars.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Deployment to Azure (Recommended)](#deployment-to-azure-recommended)
- [Local Development Setup](#local-development-setup)
- [Configuration and Usage](#configuration-and-usage)

## Prerequisites

### Azure Resources (Required)
- An active Azure account. [Create one for free](https://azure.microsoft.com/free/ai-services)
- An **Azure AI Services resource** in a supported region
  - Get your endpoint and API key from the `Keys and Endpoint` tab
  - Endpoint format: `https://<region>.api.cognitive.microsoft.com/` or `https://<custom-domain>.cognitiveservices.azure.com/`
- (Optional) **Azure AI Search resource** - Required only if using the Search tool for knowledge base integration
  - Obtain search endpoint, API key, index name, and semantic configuration
  - Configure content and identifier field names for your index

### Regional Availability
- **Voice Live API**: Available in regions supporting Azure AI Services. See [voice live overview documentation](https://learn.microsoft.com/azure/ai-services/speech-service/voice-live)
- **Avatar Feature**: Currently available in:
  - Southeast Asia
  - North Europe
  - West Europe
  - Sweden Central
  - South Central US
  - East US 2
  - West US 2

### For Deployment
- **Azure Container Registry** (for cloud deployment)
- **Azure Container Apps** (recommended hosting platform)

### For Local Development
- Docker installed on your machine. [Get Docker](https://www.docker.com/get-started)

## Deployment to Azure (Recommended)

Deploying to Azure Container Apps provides a scalable, production-ready environment with global accessibility.

### Step 1: Build the Docker Image

Navigate to the project directory and build the Docker image:

```bash
docker build -t voice-live-avatar .
```

### Step 2: Create Azure Container Registry

If you don't have an Azure Container Registry:

```bash
# Login to Azure
az login

# Create a resource group
az group create --name voice-live-rg --location eastus2

# Create Azure Container Registry
az acr create --resource-group voice-live-rg \
  --name <your-registry-name> --sku Basic

# Login to ACR
az acr login --name <your-registry-name>
```

### Step 3: Push Image to Azure Container Registry

Tag and push the image:

```bash
docker tag voice-live-avatar <your-registry-name>.azurecr.io/voice-live-avatar:latest
docker push <your-registry-name>.azurecr.io/voice-live-avatar:latest
```

### Step 4: Deploy to Azure Container Apps

Create and configure the Container App:

```bash
# Create Container Apps environment
az containerapp env create \
  --name voice-live-env \
  --resource-group voice-live-rg \
  --location eastus2

# Deploy the container
az containerapp create \
  --name voice-live-app \
  --resource-group voice-live-rg \
  --environment voice-live-env \
  --image <your-registry-name>.azurecr.io/voice-live-avatar:latest \
  --target-port 3000 \
  --ingress external \
  --registry-server <your-registry-name>.azurecr.io \
  --cpu 1.0 --memory 2.0Gi
```

### Step 5: (Optional) Configure Environment Variables

Pre-configure the application with environment variables:

```bash
az containerapp update \
  --name voice-live-app \
  --resource-group voice-live-rg \
  --set-env-vars \
    RETURN_CONFIGS=true \
    AI_SERVICE_ENDPOINT=<your-ai-service-endpoint> \
    AZURE_FOUNDRY_PROJECT_NAME=<your-project-name>
```

### Step 6: Access Your Application

Get the application URL:

```bash
az containerapp show \
  --name voice-live-app \
  --resource-group voice-live-rg \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

Navigate to the URL in your browser (format: `https://voice-live-app.xxx.azurecontainerapps.io`)

### Continuous Deployment (Optional)

Set up CI/CD pipelines for automated deployments:
- [Azure Container Apps with GitHub Actions](https://learn.microsoft.com/azure/container-apps/github-actions)
- [Azure Container Apps with Azure DevOps](https://learn.microsoft.com/azure/container-apps/azure-pipelines)

## Local Development Setup

For local testing and development, run the application using Docker.

### Build the Docker Image

Navigate to the project directory containing the `Dockerfile`:

```bash
docker build -t voice-live-avatar .
```

### Run the Container

Start the application locally:

```bash
docker run --rm -p 3000:3000 voice-live-avatar
```

### Access the Application

Open your web browser and navigate to `http://localhost:3000`

### Running with Environment Variables (Optional)

To pre-configure settings for local development:

```bash
docker run --rm -p 3000:3000 \
  -e RETURN_CONFIGS=true \
  -e AI_SERVICE_ENDPOINT=<your-endpoint> \
  -e AZURE_FOUNDRY_PROJECT_NAME=<your-project> \
  voice-live-avatar
```

## Configuration and Usage

### Initial Setup

1. **Connection Settings**
   - Navigate to the `Connection Settings` section
   - Enter your **Azure AI Services Endpoint**
   - Enter your **Subscription Key** (from Azure Portal → AI Services resource → Keys and Endpoint)

2. **Select Mode**
   - Choose `Model` (direct model access) or `Agent` (AI Agent framework)

### Conversation Configuration

1. **Basic Settings**
   - Configure **Recognition Language** (or use Auto Detect)
   - Set **Turn Detection** method (Server VAD or Azure Semantic VAD)
   - Adjust **Temperature** for response creativity
   - Add custom **Instructions** for the AI behavior

2. **Voice Configuration**
   - Select **Voice Type**: Standard, Custom, or Personal
   - Choose from available voices or configure custom voice settings

3. **Avatar Configuration** (Optional)
   - Toggle the **Avatar** switch to enable avatars
   - Choose between Standard Avatars, Photo Avatars, or Custom Avatars
   - Select avatar character and style from dropdowns

4. **Tool Configuration** (Model Mode Only)
   - Enable **Search** to integrate Azure AI Search knowledge bases
   - Configure:
     - Search endpoint
     - Search index name
     - Search API key
     - Semantic configuration name
     - Content field name
     - Identifier field name
   - Enable other tools like time lookup, weather, calculator, pronunciation assessment, etc.

### Starting a Conversation

1. Click the **Connect** button to establish the session
2. Wait for the avatar to appear (if enabled)
3. Click the **microphone button** to start speaking
4. The AI will respond with voice and avatar animations
5. Click the microphone button again to stop recording

### Developer Mode

Toggle the **Developer mode** switch at the top to:
- View conversation history as text
- See detailed logs and debugging information
- Access additional troubleshooting tools

### Recording Conversations

- Sessions are automatically recorded
- After disconnecting, click **Download Recording** to save the audio as a WAV file

## Troubleshooting

### Common Issues

**Avatar not appearing:**
- Ensure your Azure AI Services resource is in a supported avatar region
- Check that avatar toggle is enabled in settings
- Verify WebRTC connection in browser console

**Search not working:**
- Confirm Azure AI Search endpoint, index, and API key are correct
- Verify semantic configuration name matches your index configuration
- Check that content and identifier fields exist in your search index

**Connection failures:**
- Validate Azure AI Services endpoint and subscription key
- Ensure you're using a supported region
- Check browser console for detailed error messages

**Audio issues:**
- Grant microphone permissions in your browser
- Check audio input/output device settings
- Try enabling noise suppression or echo cancellation

## Resources

- [Azure Voice Live Documentation](https://learn.microsoft.com/azure/ai-services/speech-service/voice-live)
- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure AI Services Documentation](https://learn.microsoft.com/azure/ai-services/)
- [Azure AI Search Documentation](https://learn.microsoft.com/azure/search/)
