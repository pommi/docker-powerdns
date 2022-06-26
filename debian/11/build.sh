#!/bin/sh

set -x

IMAGE=pommib/powerdns:4.4-bullseye
docker pull $IMAGE
docker pull debian:bullseye-slim
docker build --no-cache -t $IMAGE ./debian/11/
docker push $IMAGE
