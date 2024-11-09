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

# Download ComfyUI API binary
ARG api_version=1.5.0
ADD https://github.com/SaladTechnologies/comfyui-api/releases/download/${api_version}/comfyui-api .
RUN chmod +x comfyui-api

# Set up environment variables
ENV MODEL_DIR=/opt/ComfyUI/models
ENV OUTPUT_DIR=/opt/ComfyUI/output
ENV INPUT_DIR=/opt/ComfyUI/input
ENV STARTUP_CHECK_MAX_TRIES=30

# Install required packages
RUN pip install --upgrade pip
RUN pip install comfy-cli fastapi uvicorn python-multipart aiofiles

# Clone the model-manager repository
RUN git clone https://github.com/prikshitsingh24/gigai-image-model-api.git

# Disable tracking and set default directory
RUN echo "N" | comfy tracking disable
RUN comfy set-default /opt/ComfyUI/

# Create start script to run both services
RUN echo '#!/bin/bash\n\
python gigai-image-model-api/src/main.py &\n\
./comfyui-api' > start.sh

RUN chmod +x start.sh

# Expose both API ports
EXPOSE 3000 8000

CMD ["./start.sh"]
