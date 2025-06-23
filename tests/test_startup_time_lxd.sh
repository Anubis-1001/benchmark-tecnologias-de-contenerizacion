#!/bin/bash

IMAGE="ubuntu:22.04"
CONTAINER_NAME="test-time"
REPEATS=10


echo "Measuring container startup time for image: $IMAGE"
echo "Repeats: $REPEATS"
echo ""

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"
    /usr/bin/time -f "Elapsed time: %e seconds" \
    lxc launch $IMAGE $CONTAINER_NAME \
        >> record_time_lxd.txt 2>&1

    sleep 2


    lxc delete --force $CONTAINER_NAME
    sleep 1
done

