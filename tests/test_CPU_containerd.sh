#!/bin/bash

IMAGE="docker.io/library/test-stress:latest"

for x in {1..10}
do
    sudo nerdctl run -d --name test-container\
	--net=bridge \
	--snapshotter=btrfs $IMAGE

    PID=$(sudo nerdctl inspect --format '{{.State.Pid}}' test-container)

    echo $PID ===
    { sudo pidstat -h -r -u -p "$PID" 1 1 | sudo tee -a results/record_CPU_containerd.txt; } &
    bg_id=$!
    sleep 3;
    sudo kill -9 "$bg_id"


    sudo ctr task kill -s SIGKILL test-container 2>/dev/null
    sudo ctr task delete test-container --force 2>/dev/null
    sudo nerdctl rm -f test-container 2>/dev/null

    sleep 2
done
