#!/bin/sh
# docker-machine restart default
eval $(docker-machine env)
docker build -t 4lge/kasm-ubuntu-s-pdf:v1 -f dockerfile-kasm-s-pdf .
