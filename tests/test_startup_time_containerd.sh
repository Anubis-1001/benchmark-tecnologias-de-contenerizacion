#!/bin/bash

IMAGE_NAME="docker.io/library/nginx:latest"
CONTAINER_NAME="test-time"
REPEATS=10

echo "Measuring container startup time for image: $IMAGE_NAME"
echo "Repeats: $REPEATS"
echo ""

sudo ctr images pull $IMAGE_NAME


for i in $(seq 1 $REPEATS); do
    echo "Run #$i"
    /usr/bin/time -f "Elapsed time: %e seconds" \
    ctr run --detach \
        $IMAGE_NAME \
        $CONTAINER_NAME \
        /bin/sh -c "sleep 5" \
        >> results/record_time_containerd.txt 2>&1

    PID=$( ctr task ls | grep $CONTAINER_NAME | awk '{printf "%s\n", $2 }' )

    kill -9 $PID
    sleep 2
    ctr task delete $CONTAINER_NAME || true
    ctr container rm $CONTAINER_NAME

done

