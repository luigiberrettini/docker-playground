# Basics

### Running a container

Run a container with a specific image version and a command to be executed
```shell
docker run ubuntu:latest /bin/echo 'Hello world'
```

Run an interactive container and execute some commands inside it (e.g. `pwd` and `ls`)
```shell
docker run -t -i ubuntu /bin/bash
```

Run a container with a daemon
```shell
docker run -d ubuntu /bin/bash
```


FROM ubuntu
RUN echo "Hello world" > /tmp/newfile

docker build -t changed-ubuntu .

docker history changed-ubuntu

docker run -dit changed-ubuntu bash

Some layers are shown as <missing> because since Docker 1.10 we no more have one image per layer