#!/bin/bash

HOST_IP=$(hostname -I | awk '{print $1}')

iperf3 -s -p 5401 -B 0.0.0.0 &

pid_iperf=$!

CONTAINER_NAME="iperf3-client"

nerdctl run --rm --name $CONTAINER_NAME --net=bridge --snapshotter=btrfs \
    docker.io/networkstatic/iperf3:latest \
    iperf3 -c $HOST_IP -p 5401 | tee -a results/record_throughput_containerd.txt 2>&1

kill -9 $pid_iperf

