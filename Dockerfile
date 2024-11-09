ARG comfy_version=0.2.6
FROM ghcr.io/ai-dock/comfyui:v2-cuda-12.1.1-base-22.04-v${comfy_version}

# Disable the authentication and cloudflare tunnels provided by the base image
ENV WEB_ENABLE_AUTH=false
ENV CF_QUICK_TUNNELS=false

# Disable a bunch of services we don't need for the worker
RUN rm /etc/supervisor/supervisord/conf.d/jupyter.conf
RUN rm /etc/supervisor/supervisord/conf.d/storagemonitor.conf
RUN rm /etc/supervisor/supervisord/conf.d/comfyui_api_wrapper.conf
RUN rm /etc/supervisor/supervisord/conf.d/serviceportal.conf
RUN rm /etc/supervisor/supervisord/conf.d/sshd.conf
RUN rm /etc/supervisor/supervisord/conf.d/syncthing.conf

# Set up working directory
WORKDIR /app

# Download ComfyUI API binary to /app directory
ARG api_version=1.5.0
ADD https://github.com/SaladTechnologies/comfyui-api/releases/download/${api_version}/comfyui-api /app/comfyui-api
RUN chmod +x /app/comfyui-api

# Set up environment variables
ENV MODEL_DIR=/opt/ComfyUI/models
ENV OUTPUT_DIR=/opt/ComfyUI/output
ENV INPUT_DIR=/opt/ComfyUI/input
ENV STARTUP_CHECK_MAX_TRIES=30
ENV PATH="/usr/local/bin:${PATH}"

# Install Python and required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create Python symlink
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install required packages
RUN pip3 install --upgrade pip
RUN pip3 install comfy-cli fastapi uvicorn python-multipart aiofiles

# Clone the model-manager repository
RUN git clone https://github.com/prikshitsingh24/gigai-image-model-api.git

# Disable tracking and set default directory
RUN echo "N" | comfy tracking disable
RUN comfy set-default /opt/ComfyUI/

# Create start script
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'cd /app' >> /app/start.sh && \
    echo 'python3 gigai-image-model-api/src/main.py &' >> /app/start.sh && \
    echo '/app/comfyui-api' >> /app/start.sh

RUN chmod +x /app/start.sh

# Expose both API ports
EXPOSE 3000 8000

CMD ["/app/start.sh"]
