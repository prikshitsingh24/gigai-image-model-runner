# gigai-model-runner

## To build the docker file
docker build -t gigai-image-model-runner .

## To create the container
docker run --rm --gpus all -p 3000:3000 -p 8000:8000 gigai-image-model-runner
