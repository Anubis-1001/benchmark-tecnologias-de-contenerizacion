#!/bin/bash

BASE_NAME="base-container"
SNAPSHOT_NAME="test-container"
TEMPLATE="ubuntu"
STRESS_SCRIPT="../assets/stress.py"
LOG_FILE="record_CPU_lxc.txt"

if ! sudo lxc-info -n $BASE_NAME &>/dev/null; then
    echo "[INFO] Creating base container '$BASE_NAME'"
    sudo lxc-create -n $BASE_NAME -t $TEMPLATE
    sudo lxc-start -n $BASE_NAME -d
    sleep 5

    echo "[INFO] Installing dependencies..."
    sudo lxc-attach -n $BASE_NAME -- bash -c "
        apt update &&
        DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip sysstat &&
        pip3 install numpy
    "

    echo "[INFO] Copying stress.py"
    sudo cp "$STRESS_SCRIPT" "/var/lib/lxc/$BASE_NAME/rootfs/root/"

    sudo lxc-stop -n $BASE_NAME
    echo "[INFO] Base container setup complete."
fi

for i in {1..10}; do

    sudo lxc-stop -n $SNAPSHOT_NAME 2>/dev/null
    sudo lxc-destroy -n $SNAPSHOT_NAME 2>/dev/null

    sudo lxc-copy -n $BASE_NAME -N $SNAPSHOT_NAME -s
    sudo lxc-start -n $SNAPSHOT_NAME -d

    sleep 3

    sudo lxc-attach -n $SNAPSHOT_NAME -- bash -c "
        nohup python3 /root/stress.py > /root/stress.log 2>&1 &
        sleep 1
    "

    CONTAINER_PID=$(sudo lxc-attach -n $SNAPSHOT_NAME -- pgrep -f "/root/stress.py")

    if [[ -z "$CONTAINER_PID" ]]; then
        continue
    fi

    sleep 2  
    sudo lxc-attach -n $SNAPSHOT_NAME -- pidstat -h -r -u -p $CONTAINER_PID 1 1 | tee -a "$LOG_FILE"

    sudo lxc-stop -n $SNAPSHOT_NAME
    sudo lxc-destroy -n $SNAPSHOT_NAME

    sleep 2
done

