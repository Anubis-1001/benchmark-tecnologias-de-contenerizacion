#!/bin/bash

podman stop test-container
podman rm test-container

podman run -itd --name test-container test-stress

PID=$(podman inspect -f '{{.State.Pid}}' test-container)

ps -p $PID -o %cpu,%mem,cmd | tee -a record_podman.txt 

pidstat -h -r -u -p $PID 1 1 | tee -a record_podman.txt

podman stop test-container
podman rm test-container
