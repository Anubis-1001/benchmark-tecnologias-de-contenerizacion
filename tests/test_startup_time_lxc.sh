#!/bin/bash

CONTAINER_NAME="test-container"
TEMPLATE="ubuntu"
REPEATS=5


echo "Measuring LXC container startup time..."
echo "Container name: $CONTAINER_NAME"
echo "Template: $TEMPLATE"
echo "Repeats: $REPEATS"
echo ""

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"


    sudo lxc-create -n $CONTAINER_NAME -t $TEMPLATE &>/dev/null

    START=$(date +%s%N)
    sudo lxc-start -n $CONTAINER_NAME -d
    while ! sudo lxc-info -n $CONTAINER_NAME | grep -q 'RUNNING'; do
        sleep 0.1
    done
    END=$(date +%s%N)

    ELAPSED_NS=$((END - START))
    ELAPSED_SEC=$(echo "scale=3; $ELAPSED_NS / 1000000000" | bc)
    echo "Startup time: $ELAPSED_SEC seconds"
    echo ""

    sudo lxc-stop -n $CONTAINER_NAME
    sudo lxc-destroy -n $CONTAINER_NAME
done

