#!/bin/bash

for _ in {1..10}
do
	docker volume create diskio-test-vol

	sudo docker run --rm \
	    --name fio-test \
	    -v diskio-test-vol:/data \
	    xridge/fio \
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
	    | grep -A 5 "clat percentiles" >> results/record_disk_io_docker.txt 2>&1

	docker volume rm diskio-test-vol
	sleep 2;
done
