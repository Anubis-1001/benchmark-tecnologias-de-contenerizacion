#!/bin/bash

iperf3 -s -p 5401 &
pid_iperf=$!

CONTAINER_NAME="iperf3-client"

sudo ctr images pull docker.io/networkstatic/iperf3:latest


ctr run --rm \
--net-host \
docker.io/networkstatic/iperf3:latest \
$CONTAINER_NAME \
iperf3 -c 127.0.0.1 -p 5401 >> record_throughput_containerd.txt 2>&1

kill -9 $pid_iperf

