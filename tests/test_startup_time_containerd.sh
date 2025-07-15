#!/bin/bash

IMAGE_NAME="docker.io/library/nginx:latest"
CONTAINER_NAME="test-startup-time"
REPEATS=10

echo "Measuring container startup time for image: $IMAGE_NAME"
echo "Repeats: $REPEATS"
echo ""

nerdctl pull $IMAGE_NAME

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"
    /usr/bin/time -f "Elapsed time: %e seconds" \
    nerdctl run --name $CONTAINER_NAME --detach --snapshotter=btrfs \
        --net=bridge $IMAGE_NAME \
        /bin/sh -c "sleep 7" >> results/record_time_containerd.txt 2>&1

    container_pid=`sudo ctr task ls | awk ' NR==2 { print $2 }'`
    sudo kill -9 "$container_pid"
    sudo nerdctl rm "$CONTAINER_NAME"

    sleep 2
done

