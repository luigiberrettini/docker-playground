### Single Docker engine - Build and run PHP
docker build -t web-hello-world -f ~/workdir/dockerfile-app-php ~/workdir/
docker run --rm -ti web-hello-world ls -Al /
docker run --name web-hello-world -d web-hello-world

curl --silent $(docker inspect -f '{{.NetworkSettings.IPAddress}}' $(docker ps --filter 'ancestor=web-hello-world' -aq)) | grep  -i 'SERVER_ADDR '
telnet $(docker inspect -f '{{.NetworkSettings.IPAddress}}' $(docker ps --filter 'ancestor=web-hello-world' -aq)) 80
# GET /

docker stop $(docker ps --filter 'ancestor=web-hello-world' -aq) && docker rm $(docker ps --filter 'ancestor=web-hello-world' -aq)
docker rmi web-hello-world
docker rmi $(docker images -f "dangling=true" -q)



### Single Docker engine - Build and run JS
docker build -t web-hello-world -f ~/workdir/dockerfile-app-js ~/workdir/
docker run --rm -ti web-hello-world ls -Al /
docker run --name web-hello-world -d web-hello-world

curl --silent $(docker inspect -f '{{.NetworkSettings.IPAddress}}' $(docker ps --filter 'ancestor=web-hello-world' -aq))

docker stop $(docker ps --filter 'ancestor=web-hello-world' -aq) && docker rm $(docker ps --filter 'ancestor=web-hello-world' -aq)
docker rmi web-hello-world
docker rmi $(docker images -f "dangling=true" -q)