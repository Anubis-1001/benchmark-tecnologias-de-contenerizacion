#!/bin/bash

for _ in {1..10}
do
	podman volume create diskio-test-vol

	podman run --rm \
	    --name fio-test \
	    -v diskio-test-vol:/data \
	    docker.io/xridge/fio \
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
	    | grep -A 5 "clat percentiles" >> record_disk_io_podman.txt 2>&1

	podman volume rm diskio-test-vol
	sleep 2;
done
