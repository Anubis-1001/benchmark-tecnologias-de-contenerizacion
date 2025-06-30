#!/bin/bash

CONTAINER_NAME="iperf3-client"
HOST_IP="10.0.3.1"     
PORT=5401

iperf3 -s -p $PORT &
pid_iperf=$!
echo "iperf3 server started on port $PORT (PID $pid_iperf)"

sudo lxc-destroy -n $CONTAINER_NAME &>/dev/null
sudo lxc-create -n $CONTAINER_NAME -t download -- -d ubuntu -r focal -a amd64

sudo lxc-start -n $CONTAINER_NAME -d
echo "Waiting for container to start..."
while ! sudo lxc-info -n $CONTAINER_NAME | grep -q 'RUNNING'; do sleep 0.5; done
sleep 5  

sudo lxc-attach -n $CONTAINER_NAME -- apt update
sudo lxc-attach -n $CONTAINER_NAME -- apt install -y iperf3

sudo lxc-attach -n $CONTAINER_NAME -- iperf3 -c $HOST_IP -p $PORT >> results/record_throughput_lxc.txt 2>&1
sleep 2

kill -9 $pid_iperf
sudo lxc-stop -n $CONTAINER_NAME
sudo lxc-destroy -n $CONTAINER_NAME

