#!/bin/bash

for x in {1..10}
do
	sudo docker run -itd --name test-container test-stress

	PID=$(sudo docker inspect -f '{{.State.Pid}}' test-container)

	pidstat -h -r -u -p $PID 1 1 | tee -a results/record_CPU_docker.txt


	sudo docker stop test-container
	sudo docker rm test-container
	sleep 2;
done
