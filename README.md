# gigai-model-runner

## To build the docker file
docker build -t gigai-image-model-runner .

## To create the container
docker run --gpus all -p 3000:3000 -p 8000:8000 -v ~/comfyui-data/models:/opt/ComfyUI/models -v ~/comfyui-data/output:/opt/ComfyUI/output -v ~/comfyui-data/input:/opt/ComfyUI/input -v /var/run/docker.sock:/var/run/docker.sock --name gigai-image-model-runner gigai-image-model-runner
