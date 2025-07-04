#!/bin/bash

iperf3 -s -p 5401 &
pid_iperf=$!

CONTAINER_NAME="iperf3-client"
sudo ctr images pull docker.io/networkstatic/iperf3:latest


ctr run --snapshotter btrfs --rm \
--runc-binary crun --runtime io.containerd.runc.v2 \
--net-host \
docker.io/networkstatic/iperf3:latest \
$CONTAINER_NAME \
iperf3 -c 127.0.0.1 -p 5401 >> results/record_throughput_containerd.txt 2>&1

kill -9 $pid_iperf

