#!/bin/bash
# containers.sh: run, inspect and remove a web server container
docker pull nginx:stable                        # download the nginx image
docker run -d -p 8080:80 --name web nginx:stable  # start it, publishing port 8080
curl -I http://localhost:8080                   # test: expect "HTTP/1.1 200 OK"
docker ps                                       # list running containers
docker stats --no-stream                        # their CPU and memory use, once
docker stop web && docker rm web                # stop and remove the container
