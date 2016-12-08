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