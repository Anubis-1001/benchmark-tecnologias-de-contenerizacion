#!/bin/bash

IMAGE="ubuntu:22.04"


lxc launch $IMAGE test-container
sleep 3
lxc exec test-container -- bash -c "apt-get update && apt-get install -y python3 python3-pip sysstat && pip3 install numpy"

lxc file push ../assets/stress.py test-container/root/cpu_test.py


for x in {1..10}
do
    gnome-terminal -- lxc exec test-container -- bash -c "python3 /root/cpu_test.py"

    sleep 3

    PID=$( lxc exec test-container -- bash -c "pgrep python3" )

    lxc exec test-container -- bash -c "pidstat -h -r -u -p $PID 1 1" | tee -a record_CPU_lxd.txt

    lxc exec test-container -- bash -c "kill -9 $PID"

    sleep 2
done

lxc stop test-container --force
lxc delete test-container
