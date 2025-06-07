#!/bin/bash

docker run -d --name mynginx -p 8085:80 nginx

sleep 2

ab -n 100000 -c 100 http://localhost:8085/

docker rm -f mynginx
