#!/bin/sh

set -x

IMAGE=pommib/powerdns:4.6-bookworm
docker pull $IMAGE
docker pull debian:bookworm-slim
docker build --no-cache -t $IMAGE ./debian/12/
docker push $IMAGE

docker tag $IMAGE pommib/powerdns:latest
docker push pommib/powerdns:latest
