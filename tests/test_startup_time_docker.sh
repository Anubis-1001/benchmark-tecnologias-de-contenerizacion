#!/bin/bash

IMAGE_NAME="nginx"
CONTAINER_NAME="test-time"
REPEATS=10

echo "Measuring container startup time for image: $IMAGE_NAME"
echo "Repeats: $REPEATS"
echo ""

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"

    /usr/bin/time -f "Elapsed time: %e seconds"  \
    docker run -itd --rm --name $CONTAINER_NAME $IMAGE_NAME \
    >> record_docker_time.txt 2>&1

    docker stop $CONTAINER_NAME
    sleep 2

    echo ""
done

