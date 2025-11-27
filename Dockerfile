# Use multi-stage build with caching
FROM mcr.microsoft.com/azurelinux/base/nodejs:20 AS web-builder

# Install dependencies in one layer
RUN tdnf distro-sync -y && \
    tdnf install -y jq git && \
    tdnf clean all

# Clone and build SDK (this is cached unless the commit changes)
RUN git clone https://github.com/yulin-li/aoai-realtime-audio-sdk.git && \
    cd aoai-realtime-audio-sdk/javascript/standalone && \
    git checkout feature/voice-agent && \
    git checkout 96d2089ef0829f687abf14d52ba1aaba2e8886a9 && \
    npm install && npm run build && npm pack

FROM mcr.microsoft.com/azurelinux/base/nodejs:20 AS web

RUN tdnf distro-sync -y && \
    tdnf install -y jq && \
    tdnf clean all

# Copy the built package
COPY --from=web-builder /aoai-realtime-audio-sdk/javascript/standalone/rt-client-0.5.2.tgz /web/rt-client-0.5.2.tgz

WORKDIR /web

# Copy package files first for better caching
COPY package*.json ./

# Install ALL dependencies (including dev dependencies needed for build)
RUN npm install

# Copy rest of the code
COPY . .
RUN npm run build

# Final stage - Python runtime
FROM mcr.microsoft.com/azurelinux/base/python:3 AS final

RUN tdnf distro-sync -y && \
    tdnf install -y ca-certificates && \
    tdnf upgrade -y && \
    tdnf clean all

# Copy built web files
COPY --from=web /web/out /web/out
COPY app.py /web/app.py

# Install Python dependencies
RUN pip install --no-cache-dir aiohttp azure-identity "azure-ai-agents" "azure-search-documents"

WORKDIR /web

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD python3 -c "import http.client; conn = http.client.HTTPConnection('localhost', 3000); conn.request('GET', '/config'); r = conn.getresponse(); exit(0 if r.status == 404 or r.status == 200 else 1)"

EXPOSE 3000

ENTRYPOINT ["python3", "app.py"]