### Single Docker engine - Compose
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