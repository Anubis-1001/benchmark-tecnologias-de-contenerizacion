#!/bin/bash

for x in {1..10}
do
	docker run -itd --name test-container test-stress

	PID=$(docker inspect -f '{{.State.Pid}}' test-container)

	pidstat -h -r -u -p $PID 1 1 | tee -a record_CPU_docker.txt


	docker stop test-container
	docker rm test-container
	sleep 2;
done
