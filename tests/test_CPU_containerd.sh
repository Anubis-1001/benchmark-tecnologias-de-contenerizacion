#!/bin/bash


IMAGE="docker.io/library/test-stress:latest"



for x in {1..10}
do


    ctr run  -d --label test=true "$IMAGE" test-container

    sleep 3;
    PID=$(ctr task ls | grep test-container | awk '{print $2}')

    echo $PID === 
    pidstat -h -r -u -p $PID 1 1 | tee -a results/record_CPU_containerd.txt
    
    kill -9 $PID
    ctr task delete test-container || true
    ctr container rm test-container

    sleep 2
done

