#!/bin/bash

IMAGE="ubuntu:22.04"
CONTAINER_NAME="test-container"
SESSION_NAME="cpu_test_session"


if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux kill-session -t $SESSION_NAME
fi

lxc launch $IMAGE $CONTAINER_NAME
sleep 5

lxc exec $CONTAINER_NAME -- bash -c "apt-get update && apt-get install -y python3 python3-pip sysstat && pip3 install numpy"

lxc file push ../assets/stress.py $CONTAINER_NAME/root/cpu_test.py

tmux new-session -d -s $SESSION_NAME

for x in {1..10}
do
    tmux send-keys -t $SESSION_NAME "lxc exec $CONTAINER_NAME -- python3 /root/cpu_test.py " C-m

    for i in {1..10}; do
        PID=$(lxc exec $CONTAINER_NAME -- pgrep -f /root/cpu_test.py)
        if [[ -n "$PID" ]]; then break; fi
        sleep 1
    done

    if [[ -z "$PID" ]]; then
        echo "No running Python process found."
        continue
    fi

    lxc exec $CONTAINER_NAME -- bash -c "pidstat -h -r -u -p $PID 1 1" | tee -a record_CPU_lxd.txt

    lxc exec $CONTAINER_NAME -- kill -9 $PID

    sleep 2
done

lxc stop $CONTAINER_NAME --force
lxc delete $CONTAINER_NAME
tmux kill-session -t $SESSION_NAME

echo "Test complete. Results saved to record_CPU_lxd.txt"

