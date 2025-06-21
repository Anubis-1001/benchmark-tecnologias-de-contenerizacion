#!/bin/bash

BASE_NAME="base-container"
SNAPSHOT_NAME="test-container"
TEMPLATE="ubuntu"
STRESS_SCRIPT="../assets/stress.py"
LOG_FILE="record_lxc.txt"

# Create base container once (only if it doesn't exist)
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

# Run 10 test iterations using snapshot container
for i in {1..10}; do
    echo "[INFO] Starting iteration $i" | tee -a "$LOG_FILE"
    echo "[$(date)] Iteration $i" | tee -a "$LOG_FILE"

    # Clean up previous test container
    sudo lxc-stop -n $SNAPSHOT_NAME 2>/dev/null
    sudo lxc-destroy -n $SNAPSHOT_NAME 2>/dev/null

    # Clone from base container (snapshot mode)
    sudo lxc-copy -n $BASE_NAME -N $SNAPSHOT_NAME -s
    sudo lxc-start -n $SNAPSHOT_NAME -d

    echo "[$(date)] Waiting for container to boot..." | tee -a "$LOG_FILE"
    sleep 3

    # Start stress.py inside the container
    sudo lxc-attach -n $SNAPSHOT_NAME -- bash -c "
        nohup python3 /root/stress.py > /root/stress.log 2>&1 &
        sleep 1
    "

    # Get the actual PID of stress.py using pgrep
    CONTAINER_PID=$(sudo lxc-attach -n $SNAPSHOT_NAME -- pgrep -f "/root/stress.py")

    if [[ -z "$CONTAINER_PID" ]]; then
        echo "[WARN] stress.py not running or PID not found!" | tee -a "$LOG_FILE"
        continue
    fi

    echo "PID inside container: $CONTAINER_PID" | tee -a "$LOG_FILE"

    sleep 2  
    sudo lxc-attach -n $SNAPSHOT_NAME -- ps -p $CONTAINER_PID -o pid,comm,%cpu,%mem,cmd | tee -a "$LOG_FILE"
    sudo lxc-attach -n $SNAPSHOT_NAME -- pidstat -h -r -u -p $CONTAINER_PID 1 1 | tee -a "$LOG_FILE"

    # Clean up container
    sudo lxc-stop -n $SNAPSHOT_NAME
    sudo lxc-destroy -n $SNAPSHOT_NAME

    sleep 2
done

echo "[INFO] All iterations complete."

