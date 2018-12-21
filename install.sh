#!/bin/sh

# Docker
curl -s https://get.docker.com | sudo sh

# Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose --version

# download images from Docker Hub, build and start containers
./start.sh