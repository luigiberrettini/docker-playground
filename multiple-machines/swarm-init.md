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