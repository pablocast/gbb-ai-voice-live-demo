# <img src="images/ai_foundry.png" alt="Azure Foundry" style="width:70px;height:40px;"/># Microsoft Azure Voice Live with Avatar Sample

This sample demonstrates the usage of Azure Voice Live API with avatar capabilities, enabling real-time voice conversations with AI-powered avatars.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Deployment to Azure (Recommended)](#deployment-to-azure-recommended)
- [Local Development Setup](#local-development-setup)
- [Configuration and Usage](#configuration-and-usage)

## Prerequisites

### Azure Resources (Required)
- An active Azure account. [Create one for free](https://azure.microsoft.com/free/ai-services)
- A **Microsoft Foundry Resource** in a supported region
  - Get your endpoint and API key from the Azure AI Services library in the `Overview` tab
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
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) installed

### For Local Development
- Docker installed on your machine. [Get Docker](https://www.docker.com/get-started)

## Deployment to Azure (Recommended)

Deploy to Azure Container Apps with a single command using Azure Developer CLI (azd).

### Prerequisites

Install Azure Developer CLI if you haven't already:

**Windows:**
```powershell
winget install microsoft.azd
```

**macOS:**
```bash
brew tap azure/azd && brew install azd
```

**Linux:**
```bash
curl -fsSL https://aka.ms/install-azd.sh | bash
```

### Deploy

1. Login to Azure:
```bash
azd auth login
```

2. Deploy the application:
```bash
azd up
```

This single command will:
- Provision Azure Container Registry
- Provision Azure Container Apps environment
- Build and push the Docker image
- Deploy the application
- Provide you with the application URL

3. Access your application at the URL provided by `azd up` (format: `https://voice-live-app.xxx.azurecontainerapps.io`)

### Update Deployment

To redeploy after making changes:

```bash
azd deploy
```

### Clean Up Resources

To delete all Azure resources created by azd:

```bash
azd down
```

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
