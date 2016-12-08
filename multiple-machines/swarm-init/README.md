### Swarm - Init
advertiseAddr=$(ifconfig eth1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)
docker swarm init --advertise-addr $advertiseAddr --listen-addr $advertiseAddr:2377
docker swarm leave --force
docker swarm init --advertise-addr $advertiseAddr --listen-addr $advertiseAddr:2377
workerToken=$(docker swarm join-token worker | grep -o 'SWMTKN[^ ]*' | head -1)
echo "$workerToken"
managerToken=$(docker swarm join-token manager | grep -o 'SWMTKN[^ ]*' | head -1)
echo "$managerToken"

# Add a worker and a manager
# #2 = worker
#workerToken=
#advertiseAddr=
docker swarm join --token $workerToken $advertiseAddr:2377
# #3 = manager
#managerToken=
#advertiseAddr=
docker swarm join --token $managerToken $advertiseAddr:2377

# 1 and 2
docker node ls

# 1
docker node promote $(docker node ls | grep docker-playground-2 | awk '{print $1}')
docker node demote $(docker node ls | grep docker-playground-2 | awk '{print $1}')
docker node promote $(docker node ls | grep docker-playground-2 | awk '{print $1}')