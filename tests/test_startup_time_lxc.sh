#!/bin/bash

CONTAINER_NAME="test-container"
TEMPLATE="download"
REPEATS=10


echo "Measuring LXC container startup time..."
echo "Container name: $CONTAINER_NAME"
echo "Repeats: $REPEATS"
echo ""

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"


    START=$(date +%s%N)
    sudo lxc-create -n $CONTAINER_NAME -t $TEMPLATE -- --dist ubuntu --release jammy --arch amd64 &>/dev/null

    sudo lxc-start -n $CONTAINER_NAME -d
    while ! sudo lxc-info -n $CONTAINER_NAME | grep -q 'RUNNING'; do
        sleep 0.1
    done
    END=$(date +%s%N)

    ELAPSED_NS=$((END - START))
    ELAPSED_SEC=$(echo "scale=3; $ELAPSED_NS / 1000000000" | bc)
    echo "Startup time: $ELAPSED_SEC seconds" | tee -a results/record_time_lxc.txt

    sudo lxc-stop -n $CONTAINER_NAME
    sudo lxc-destroy -n $CONTAINER_NAME
    echo "Containers destroyed"
done

