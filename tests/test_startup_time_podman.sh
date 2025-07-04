#!/bin/bash

IMAGE_NAME="docker.io/library/nginx"
CONTAINER_NAME="test-time"
REPEATS=10

echo "Measuring container startup time for image: $IMAGE_NAME"
echo "Repeats: $REPEATS"
echo ""

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"

    /usr/bin/time -f "Elapsed time: %e seconds"  \
    podman run -itd --rm --network bridge --name $CONTAINER_NAME $IMAGE_NAME \
    >> results/record_time_podman.txt 2>&1;

    podman stop $CONTAINER_NAME;

    sleep 2;

done

