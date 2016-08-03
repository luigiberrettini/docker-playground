wget https://github.com/luigiberrettini/docker-playground/raw/master/tutorial.sh -O ~/tutorial.sh
git clone https://github.com/luigiberrettini/example-voting-app ~/example-voting-app
docker-compose -f ~/example-voting-app/docker-compose.yml pull
sudo aptitude install redis-tools
docker pull php:7.0-apache
docker pull node
docker pull nginx:alpine



cd ~
mkdir --parent ~/workdir



### Single Docker engine - Build and run PHP
printf '<html>\n    <head><title>Hello World</title></head>\n    <body><h1>Hello World! <?php phpinfo(); ?></h1></body>\n</html>\n' > ~/workdir/index.php

printf 'FROM php:7.0-apache\nCOPY index.php /var/www/html/\n' > ~/workdir/dockerfile-app-php

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
echo 'const http = require("http");' > ~/workdir/server.js
echo 'const os = require("os");' >> ~/workdir/server.js
echo 'http.createServer(function (req, res) {' >> ~/workdir/server.js
echo '    const interfaces = os.networkInterfaces();' >> ~/workdir/server.js
echo '    var addresses = "";' >> ~/workdir/server.js
echo '    for (var i in interfaces) {' >> ~/workdir/server.js
echo '        for (var j in interfaces[i]) {' >> ~/workdir/server.js
echo '            var ifDetails = interfaces[i][j];' >> ~/workdir/server.js
echo '            if (ifDetails.family === "IPv4" && ifDetails.internal == false) {' >> ~/workdir/server.js
echo '                addresses += ifDetails.address + " ";' >> ~/workdir/server.js
echo '            }' >> ~/workdir/server.js
echo '        }' >> ~/workdir/server.js
echo '    }' >> ~/workdir/server.js
echo '    res.writeHead(200, {"Content-Type": "text/plain"});' >> ~/workdir/server.js
echo '    res.write("SERVER_ADDR " + addresses + "\n");' >> ~/workdir/server.js
echo '    res.end();' >> ~/workdir/server.js
echo '}).listen(80);' >> ~/workdir/server.js

printf 'FROM node\nCOPY server.js /bin\nEXPOSE 80\nCMD ["node", "/bin/server.js"]\n' > ~/workdir/dockerfile-app-js

docker build -t web-hello-world -f ~/workdir/dockerfile-app-js ~/workdir/
docker run --rm -ti web-hello-world ls -Al /
docker run --name web-hello-world -d web-hello-world

curl --silent $(docker inspect -f '{{.NetworkSettings.IPAddress}}' $(docker ps --filter 'ancestor=web-hello-world' -aq))

docker stop $(docker ps --filter 'ancestor=web-hello-world' -aq) && docker rm $(docker ps --filter 'ancestor=web-hello-world' -aq)
docker rmi web-hello-world
docker rmi $(docker images -f "dangling=true" -q)



### Single Docker engine - Compose
echo 'resolver 127.0.0.11 valid=2s;' > ~/workdir/proxy.conf
echo '' >> ~/workdir/proxy.conf
echo 'server {' >> ~/workdir/proxy.conf
echo '    listen 80;' >> ~/workdir/proxy.conf
echo '    location /php/ {' >> ~/workdir/proxy.conf
echo '        set $lbhwphp lbwebhelloworldphp;' >> ~/workdir/proxy.conf
echo '        proxy_pass http://$lbhwphp/;' >> ~/workdir/proxy.conf
echo '    }' >> ~/workdir/proxy.conf
echo '    location /js/ {' >> ~/workdir/proxy.conf
echo '        set $lbhwjs lbwebhelloworldjs;' >> ~/workdir/proxy.conf
echo '        proxy_pass http://$lbhwjs/;' >> ~/workdir/proxy.conf
echo '    }' >> ~/workdir/proxy.conf
echo '}' >> ~/workdir/proxy.conf
echo '' >> ~/workdir/proxy.conf

printf 'FROM nginx:alpine\nRUN rm /etc/nginx/conf.d/*\nCOPY proxy.conf /etc/nginx/conf.d\n' > ~/workdir/dockerfile-proxy

printf 'version: "2"\n\n' > ~/workdir/dkr-compose.yml
printf 'services:\n' >> ~/workdir/dkr-compose.yml
printf '    lbwebhelloworldphp:\n' >> ~/workdir/dkr-compose.yml
printf '        build:\n' >> ~/workdir/dkr-compose.yml
printf '            context: .\n' >> ~/workdir/dkr-compose.yml
printf '            dockerfile: dockerfile-app-php\n' >> ~/workdir/dkr-compose.yml
printf '        image: lb-web-hello-world-php\n\n' >> ~/workdir/dkr-compose.yml
printf '    lbwebhelloworldjs:\n' >> ~/workdir/dkr-compose.yml
printf '        build:\n' >> ~/workdir/dkr-compose.yml
printf '            context: .\n' >> ~/workdir/dkr-compose.yml
printf '            dockerfile: dockerfile-app-js\n' >> ~/workdir/dkr-compose.yml
printf '        image: lb-web-hello-world-js\n\n' >> ~/workdir/dkr-compose.yml
printf '    loadbalancer:\n' >> ~/workdir/dkr-compose.yml
printf '        build:\n' >> ~/workdir/dkr-compose.yml
printf '            context: .\n' >> ~/workdir/dkr-compose.yml
printf '            dockerfile: dockerfile-proxy\n' >> ~/workdir/dkr-compose.yml
printf '        image: load-balancer\n' >> ~/workdir/dkr-compose.yml
printf '        ports:\n' >> ~/workdir/dkr-compose.yml
printf '         - "80:80"\n' >> ~/workdir/dkr-compose.yml

docker-compose -f ~/workdir/dkr-compose.yml build
docker images

docker-compose -f ~/workdir/dkr-compose.yml up -d
docker-compose -f ~/workdir/dkr-compose.yml ps

curl --silent "$(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'ancestor=load-balancer' -aq))/php/" | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
curl --silent "$(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'ancestor=load-balancer' -aq))/js/" | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'

docker-compose -f ~/workdir/dkr-compose.yml scale lbwebhelloworldphp=2
docker-compose -f ~/workdir/dkr-compose.yml scale lbwebhelloworldjs=2
docker-compose -f ~/workdir/dkr-compose.yml ps

docker exec workdir_loadbalancer_1 nslookup lbwebhelloworldphp
docker exec workdir_loadbalancer_1 nslookup lbwebhelloworldjs
docker exec workdir_loadbalancer_1 cat /etc/resolv.conf

#curl --silent $(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'name=workdir_lbwebhelloworldphp_1' -aq)) | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
#curl --silent $(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'name=workdir_lbwebhelloworldphp_2' -aq)) | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
#curl --silent $(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'name=workdir_lbwebhelloworldjs_1' -aq)) | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
#curl --silent $(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'name=workdir_lbwebhelloworldjs_2' -aq)) | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'

for i in `seq 1 100`; do
    curl --silent "$(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'ancestor=load-balancer' -aq))/php/" | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
    curl --silent "$(docker inspect -f '{{.NetworkSettings.Networks.workdir_default.IPAddress}}' $(docker ps --filter 'ancestor=load-balancer' -aq))/js/" | grep -i 'SERVER_ADDR ' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
done



### Swarm - Init
advertiseAddr=$(ifconfig eth1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)
docker swarm init --advertise-addr $advertiseAddr --listen-addr $advertiseAddr:2377
docker swarm leave --force
swarmInitOutput=$(docker swarm init --advertise-addr $advertiseAddr --listen-addr $advertiseAddr:2377)
echo "$swarmInitOutput"
workerToken=$(echo "$swarmInitOutput" | grep -o 'SWMTKN[^ ]*' | head -1)
managerToken=$(echo "$swarmInitOutput" | grep -o 'SWMTKN[^ ]*' | tail -1)

# Add a worker and a manager
#workerToken=
#advertiseAddr=
docker swarm join --token $workerToken $advertiseAddr:2377
#managerToken=
#advertiseAddr=
docker swarm join --token $managerToken $advertiseAddr:2377

# 1 and 2
docker node ls

# 1
docker node promote $(docker node ls | grep docker-playground-2 | awk '{print $1}')
docker node demote $(docker node ls | grep docker-playground-2 | awk '{print $1}')
docker node promote $(docker node ls | grep docker-playground-2 | awk '{print $1}')



### Swarm - Creating services and listing tasks
docker service create --name pinger busybox ping collabnix.com
docker service ls
docker service inspect $(docker service ls | grep pinger | awk '{print $1}')

docker service ps pinger
docker service scale pinger=5
docker service ps pinger
docker service rm pinger

docker service create --name pinger --replicas 2 busybox ping collabnix.com
docker service ps pinger
docker service rm pinger

docker service create --name pinger --mode global busybox ping collabnix.com
docker service ps pinger
docker service rm pinger

docker service create --name pinger --mode replicated --replicas 3 --constraint 'node.hostname != docker-playground-1' busybox ping collabnix.com
docker service ps pinger
docker service rm pinger



### Swarm - Scaling services and performing rolling updates on them
docker service create --name redisServer --update-delay 10s --update-parallelism 2 redis:3.0.6
docker service ps redisServer
docker service scale redisServer=4
docker service ps redisServer
docker service update --image redis:latest redisServer
docker service ps redisServer
docker service update --image redis:latest redisServer
docker service ps redisServer
docker ps # on some node



### Swarm - Networking
docker network ls # 1
docker network create -d overlay overWhaleNet
docker network ls # 1
# docker swarm join node 4
docker network ls # 4
docker service scale redisServer=6
docker network ls # 4 (now overWhaleNet is visible also from node 4)

docker network create -d bridge bridgeWhaleNet
docker run --network=bridgeWhaleNet --name rdssrv -d redis
docker run --network=bridgeWhaleNet -it --rm redis redis-cli -h rdssrv -p 6379 lpush netList netItem > /dev/null
docker run --network=bridgeWhaleNet -it --rm redis redis-cli -h rdssrv -p 6379 lrange netList 0 -1

# Only services with a published port (using the -p option) require the ingress network
# Containers of services which doesn’t publish ports are NOT attached to the ingress network
# All nodes in the swarm cluster route ingress connections to a running task instance

# The docker_gwbridge network allows containers to have external connectivity (outside of their cluster)
# It is created on each worker node

# User-defined overlay networks are specified by users
# A container can be on multiple user-defined overlays



### Swarm - Self-healing
docker stop $(docker ps -a -q) # 4
docker ps



### Swarm - Self-organizing
vagrant halt vm_docker-playground-4
docker service ps redisServer
vagrant up docker-playground-4
docker node list # 1: 4 is already joined to the Swarm cluster



### Swarm - Routing Mesh
docker service rm redisServer
docker service create --replicas 3 --network overWhaleNet --name redisServer --publish 6379:6379/tcp redis

redis-cli -h $advertiseAddr -p 6379 lpush myList item
redis-cli -h $advertiseAddr -p 6379 lrange myList 0 -1



### Swarm - Distributed Application Bundle and Stacks
# A Dockerfile can be built into an image, and containers can be created from that image
# Similarly, a docker-compose.yml can be built into a distributed application bundle
# and stacks can be created from that bundle
# In that sense, the bundle is a multi-services distributable image format
cd example-voting-app
docker-compose bundle
cat examplevotingapp.dab
docker deploy examplevotingapp # SAME AS docker stack deploy examplevotingapp
docker stack config examplevotingapp
docker service ls
docker stack ps examplevotingapp