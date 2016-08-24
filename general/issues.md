# Issues



### PID 1 zombie reaping
http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
http://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html/
http://github.com/Yelp/dumb-init
http://github.com/discordianfish/alpine-armhf-docker-dumb-init/blob/master/Dockerfile



### Issue - Volumes and permissions
http://twitter.com/luigiberrettini/status/735730691724304384

http://github.com/rocker-org/rocker/wiki/Sharing-files-with-host-machine
http://github.com/rocker-org/rocker/wiki/managing-users-in-docker
http://denibertovic.com/posts/handling-permissions-with-docker-volumes

http://github.com/docker/docker/issues/7198#issuecomment-112015480
Host user UID/GID can be provided to the container when run:
```shell
docker run -e USER_ID=`id -u` -e GROUP_ID=`id -g`
```
with a Dockerfile like this
```Dockerfile
env USER_ID 1000
env GROUP_ID 1000
cmd bash -lc 'build.sh && chown -R $USER_ID:$GROUP_ID build'
```

https://github.com/kubernetes/kubernetes/issues/2630#issuecomment-110028095
```shell
USER_ID=`id -u`
GROUP_ID=`id -g`
docker run --user "$USER_ID:$GROUP_ID"
```

http://renzok.github.io/2015/09/20/docker-host-volume-user-permissions.html

http://github.com/kylemanna/docker-aosp/blob/master/utils/docker_entrypoint.sh

http://github.com/dotnet/cli/blob/rel/1.0.0/scripts/docker/centos/Dockerfile