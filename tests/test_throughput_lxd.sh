
SERVER_PORT=5401
CONTAINER_NAME="iperf3-client"
IMAGE="ubuntu:22.04"

iperf3 -s -p $SERVER_PORT &
pid_iperf=$!
echo "Started iperf3 server with PID $pid_iperf"
sleep 2



lxc launch $IMAGE $CONTAINER_NAME

sleep 3

lxc exec $CONTAINER_NAME -- apt update -qq
lxc exec $CONTAINER_NAME -- apt install -y -qq iperf3

lxc exec $CONTAINER_NAME -- iperf3 -c 10.0.3.1 -p $SERVER_PORT >> results/record_throughput_lxd.txt 2>&1

lxc delete --force $CONTAINER_NAME
sleep 2

kill -9 $pid_iperf
echo "Stopped iperf3 server"
