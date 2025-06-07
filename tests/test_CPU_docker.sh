#!/bin/bash

docker stop test-container
docker rm test-container
docker run -itd --name test-container test-stress

PID=$(docker inspect -f '{{.State.Pid}}' test-container)

ps -p $PID -o %cpu,%mem,cmd | tee -a record_docker.txt

pidstat -h -r -u -p $PID 1 1 | tee -a record_docker.txt


docker stop test-container
docker rm test-container
