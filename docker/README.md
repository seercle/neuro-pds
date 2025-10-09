# Requirements

## Building and Running Containers
  - Docker
  - Docker Compose

  ### Building the Docker Image
  To build both CPU and GPU docker images, you can use the following command:
  ```bash
  bash build_images.sh
  ```

  ### Running the Docker Container
  To run the container, you can use the following commands:

  - For CPU:
    ```bash
    cd cpu
    docker compose up -d
    ```

### Notes

- Docker keeps the images in your local storage. So in case you rebuild multiple times the image, you might want to clean up unused images from time to time. You can do this with the command:
  ```bash
  docker image prune
  ```
