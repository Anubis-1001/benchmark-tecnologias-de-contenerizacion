#!/bin/bash

CONTAINER_NAME="iperf3-client"
HOST_IP="10.0.3.1"     # Adjust this if your LXC bridge uses another IP (e.g., 172.17.0.1)
PORT=5401
REPEATS=10

# Start iperf3 server on host
iperf3 -s -p $PORT &
pid_iperf=$!
echo "iperf3 server started on port $PORT (PID $pid_iperf)"

# Create container (only once)
sudo lxc-destroy -n $CONTAINER_NAME &>/dev/null
sudo lxc-create -n $CONTAINER_NAME -t download -- -d ubuntu -r focal -a amd64

# Start and wait for container to boot
sudo lxc-start -n $CONTAINER_NAME -d
echo "Waiting for container to start..."
while ! sudo lxc-info -n $CONTAINER_NAME | grep -q 'RUNNING'; do sleep 0.5; done
sleep 5  # Extra wait for network init

# Install iperf3 inside container if needed
sudo lxc-attach -n $CONTAINER_NAME -- apt update
sudo lxc-attach -n $CONTAINER_NAME -- apt install -y iperf3

# Run client test 10 times
for x in $(seq 1 $REPEATS); do
    echo "Run #$x"
    sudo lxc-attach -n $CONTAINER_NAME -- iperf3 -c $HOST_IP -p $PORT >> record_throughput_lxc.txt 2>&1
    sleep 2
done

# Cleanup
kill -9 $pid_iperf
sudo lxc-stop -n $CONTAINER_NAME
sudo lxc-destroy -n $CONTAINER_NAME

echo "Done. Results in record_throughput_lxc.txt"
