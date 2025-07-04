#!/bin/bash

ctr images pull docker.io/xridge/fio:latest

BASE_VOL_DIR="/tmp/diskio-test"

mkdir -p "$BASE_VOL_DIR"

for i in {1..10}
do
    VOL_DIR="$BASE_VOL_DIR/vol_$i"
    mkdir -p "$VOL_DIR"

    sudo ctr run --snapshotter btrfs --rm \
	--runc-binary crun --runtime io.containerd.runc.v2 \
        --mount type=bind,src="$VOL_DIR",dst=/data,options=rbind:rw \
        docker.io/xridge/fio:latest \
        fio-test-$i \
        fio \
        --name=write_test \
        --filename=/data/testfile \
        --size=1G \
        --bs=4k \
        --rw=write \
        --ioengine=libaio \
        --direct=1 \
        --numjobs=1 \
        --runtime=60 \
        --group_reporting \
        | grep -A 5 "clat percentiles" >> results/record_disk_io_containerd.txt 2>&1

    rm -rf "$VOL_DIR"

    sleep 2
done

