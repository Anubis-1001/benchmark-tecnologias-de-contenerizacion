#!/bin/bash

BASE_NAME="base-container"
SNAPSHOT_NAME="test-container"
TEMPLATE="download"
STRESS_SCRIPT="../assets/stress.py"
LOG_FILE="results/record_CPU_lxc.txt"

if ! sudo lxc-info -n $BASE_NAME &>/dev/null; then
    echo "[INFO] Creating base container '$BASE_NAME'"
    sudo lxc-create -n $BASE_NAME -t $TEMPLATE -- --dist ubuntu --release jammy --arch amd64
    sudo lxc-start -n $BASE_NAME -d
    sleep 5

    echo "[INFO] Installing dependencies..."
    sudo lxc-attach -n $BASE_NAME -- bash -c "
        apt update &&
        DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip sysstat &&
        pip3 install numpy
    "

    echo "[INFO] Copying stress.py"
    sudo lxc-attach -n $BASE_NAME -- mkdir -p /root
    sudo lxc-attach -n $BASE_NAME -- bash -c "cat > /root/stress.py" < "$STRESS_SCRIPT"

    sudo lxc-stop -n $BASE_NAME
    echo "[INFO] Base container setup complete."
fi

for i in {1..10}; do

    echo "Iteration $i"

    sudo lxc-copy -n $BASE_NAME -N $SNAPSHOT_NAME -s
    sudo lxc-start -n $SNAPSHOT_NAME -d

    sleep 2

    sudo lxc-attach -n $SNAPSHOT_NAME -- bash -c "
        ls -l /root/stress.py
        cat /root/stress.py
        nohup python3 /root/stress.py &
        sleep 1
    "

    CONTAINER_PID=$(sudo lxc-attach -n $SNAPSHOT_NAME -- pgrep -f "/root/stress.py")


    echo "Overcomed continue statement"
    sleep 2  
    sudo lxc-attach -n $SNAPSHOT_NAME -- pidstat -h -r -u -p $CONTAINER_PID 1 1 | tee -a "$LOG_FILE"

    sudo lxc-stop -n $SNAPSHOT_NAME
    sudo lxc-destroy -n $SNAPSHOT_NAME

    sleep 2
done

