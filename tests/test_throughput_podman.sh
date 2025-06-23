#!/bin/bash

iperf3 -s -p 5401 &
pid_iperf=$!

sleep 1;
podman run --rm --name iperf3-client networkstatic/iperf3 -c 172.17.0.1 -p 5401  >> record_throughput_podman.txt 2>&1
sleep 2;

kill -9 $pid_iperf
