### Hello world

The `docker pull` command output shows image layers and their hashes
```shell
docker pull hello-world
```

Run the container with the `docker run` command (it pulls the image for you: no need to pull it beforehand)
```shell
docker run hello-world
```

List image and container layers
```bash
ls -Al /var/lib/docker/image/devicemapper/layerdb/sha256/
ls -Al /var/lib/docker/containers
```

Remember that the Docker Engine maintains the link between the layer and a randomly generated cache ID that will be used as the name of the directory to store the layer itself.