### Swarm - Distributed Application Bundle and Stacks
# A Dockerfile can be built into an image, and containers can be created from that image
# Similarly, a docker-compose.yml can be built into a distributed application bundle
# and stacks can be created from that bundle
# In that sense, the bundle is a multi-services distributable image format
git clone https://github.com/luigiberrettini/example-voting-app ~/example-voting-app
docker-compose -f ~/example-voting-app/docker-compose.yml pull
cd example-voting-app
docker-compose bundle
cat examplevotingapp.dab
docker deploy examplevotingapp # SAME AS docker stack deploy examplevotingapp
docker stack config examplevotingapp
docker service ls
docker stack ps examplevotingapp