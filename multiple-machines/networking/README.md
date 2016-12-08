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


# The swarm manager uses ingress load balancing to expose the services you want to make available externally to the swarm
# Only services with a published port (using the -p option) require the ingress network
# Containers of services which doesn’t publish ports are NOT attached to the ingress network
# All nodes in the swarm cluster route ingress connections to a running task instance

# The docker_gwbridge network allows containers to have external connectivity (outside of their cluster)
# It is created on each worker node

# User-defined overlay networks are specified by users
# A container can be on multiple user-defined overlay networks



### Swarm - Routing mesh
# A mesh network is a network topology in which each node relays data for the network
# Container-aware routing mesh is capable of transparent rerouting the traffic 
docker service rm redisServer
docker service create --replicas 3 --network overWhaleNet --name redisServer --publish 6379:6379/tcp redis
# DNS round robin instead of IPVS load balancing through a VIP: --endpoint-mode dnsrr 
docker service inspect redisServer --pretty

sudo aptitude install redis-tools
redis-cli -h $advertiseAddr -p 6379 lpush myList item
redis-cli -h $advertiseAddr -p 6379 lrange myList 0 -1