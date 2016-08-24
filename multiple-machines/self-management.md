### Swarm - Self-healing
docker stop $(docker ps -a -q) # 4
docker ps



### Swarm - Self-organizing
vagrant halt vm_docker-playground-4
docker service ps redisServer
vagrant up docker-playground-4
docker node list # 1: 4 is already joined to the Swarm cluster