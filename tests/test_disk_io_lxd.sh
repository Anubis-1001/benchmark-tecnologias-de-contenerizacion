#!/bin/bash

STORAGE_POOL=default

IMAGE=ubuntu:22.04


for i in {1..10}
do
    echo "=== Iteration $i ===" | tee -a record_disk_io_lxd.txt

    lxc stop fio-test --force 2>/dev/null
    lxc delete fio-test 2>/dev/null

    lxc storage volume delete $STORAGE_POOL diskio-test-vol 2>/dev/null

    lxc storage volume create $STORAGE_POOL diskio-test-vol

    lxc launch $IMAGE fio-test

    lxc storage volume attach $STORAGE_POOL diskio-test-vol fio-test /mnt/data

    sleep 5

    lxc exec fio-test -- apt update -qq
    lxc exec fio-test -- apt install -y -qq fio

    lxc exec fio-test -- bash -c "
        fio --name=write_test \
            --filename=/mnt/data/testfile \
            --size=1G \
            --bs=4k \
            --rw=write \
            --ioengine=libaio \
            --direct=1 \
            --numjobs=1 \
            --runtime=60 \
            --group_reporting
    " | grep -A 5 "clat percentiles" >> record_disk_io_lxd.txt 2>&1

    lxc stop fio-test --force
    lxc delete fio-test
    lxc storage volume delete $STORAGE_POOL diskio-test-vol

    sleep 2
done

