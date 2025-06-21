#!/bin/bash

CONTAINER_NAME="fio-test"
HOST_VOL_BASE="/tmp/lxc-fio-vols"
IMAGE="ubuntu"
REPEATS=10

mkdir -p $HOST_VOL_BASE

for i in $(seq 1 $REPEATS); do
    echo "Run #$i"

    VOL_DIR="$HOST_VOL_BASE/vol-$i"
    mkdir -p "$VOL_DIR"

    # Clean up any existing container
    sudo lxc-stop -n $CONTAINER_NAME &>/dev/null
    sudo lxc-destroy -n $CONTAINER_NAME &>/dev/null

    # Create and configure container
    sudo lxc-create -n $CONTAINER_NAME -t download -- -d $IMAGE -r focal -a amd64

    echo "lxc.mount.entry = $VOL_DIR data none bind,create=dir 0 0" | sudo tee -a /var/lib/lxc/$CONTAINER_NAME/config

    # Start container
    sudo lxc-start -n $CONTAINER_NAME -d
    while ! sudo lxc-info -n $CONTAINER_NAME | grep -q "RUNNING"; do sleep 0.5; done
    sleep 3

    # Install fio inside container if not already
    sudo lxc-attach -n $CONTAINER_NAME -- apt update -qq
    sudo lxc-attach -n $CONTAINER_NAME -- apt install -y fio

    # Run fio and extract relevant output
    sudo lxc-attach -n $CONTAINER_NAME -- fio --name=write_test \
        --filename=/data/testfile \
        --size=1G \
        --bs=4k \
        --rw=write \
        --ioengine=libaio \
        --direct=1 \
        --numjobs=1 \
        --runtime=60 \
        --group_reporting \
        | grep -A 5 "clat percentiles" >> record_disk_io_lxc.txt 2>&1

    # Cleanup
    sudo lxc-stop -n $CONTAINER_NAME
    sudo lxc-destroy -n $CONTAINER_NAME
    rm -rf "$VOL_DIR"
    sleep 2
done

