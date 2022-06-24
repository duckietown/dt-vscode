#!/bin/bash

apt-get update
apt-get install -y curl
curl -fsSL https://get.docker.com -o get-docker.sh
DRY_RUN=1 sh get-docker.sh
bash get-docker.sh

#docker info