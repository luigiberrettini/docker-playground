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

docker pull nginx:alpine

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