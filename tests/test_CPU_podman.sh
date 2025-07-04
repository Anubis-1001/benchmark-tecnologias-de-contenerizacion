#!/bin/bash

# Run without sudo privileges
for x in {1..10}
do

	podman run -itd --name test-container --network bridge test-stress

	PID=$(podman inspect -f '{{.State.Pid}}' test-container)

	pidstat -h -r -u -p $PID 1 1 | tee -a results/record_CPU_podman.txt

	podman stop test-container
	podman rm test-container
	sleep 2;
done
