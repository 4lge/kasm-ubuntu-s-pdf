#!/bin/sh
# docker-machine restart default
eval $(docker-machine env)
docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password 4lge/kasm-ubuntu-s-pdf:v1
