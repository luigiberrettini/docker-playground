docker pull php:7.0-apache
docker pull node

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