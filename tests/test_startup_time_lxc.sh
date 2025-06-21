#!/bin/bash

TEMPLATE="ubuntu"
BASE_NAME="base-time"
CONTAINER_NAME="test-time"
REPEATS=10
LOG_FILE="record_time_lxc.txt"

echo "Measuring LXC container startup time using template: $TEMPLATE"
echo "Repeats: $REPEATS"
echo ""

# Prepare a base container if it doesn't exist
if ! sudo lxc-info -n $BASE_NAME &>/dev/null; then
    echo "[INFO] Creating base container '$BASE_NAME'"
    sudo lxc-create -n $BASE_NAME -t $TEMPLATE
    sudo lxc-stop -n $BASE_NAME 2>/dev/null
fi

# Clear log
echo "" > "$LOG_FILE"

for i in $(seq 1 $REPEATS); do
    echo "Run #$i" | tee -a "$LOG_FILE"

    # Remove previous container if exists
    sudo lxc-stop -n $CONTAINER_NAME &>/dev/null
    sudo lxc-destroy -n $CONTAINER_NAME &>/dev/null

    # Clone from base to simulate a new container (snapshot mode)
    /usr/bin/time -f "Elapsed time: %e seconds" \
        sudo lxc-copy -n $BASE_NAME -N $CONTAINER_NAME -s \
        >> "$LOG_FILE" 2>&1

    # Start the container
    sudo lxc-start -n $CONTAINER_NAME -d

    # Wait a bit and stop the container
    sleep 3
    sudo lxc-stop -n $CONTAINER_NAME
    sudo lxc-destroy -n $CONTAINER_NAME

    echo "" | tee -a "$LOG_FILE"
done

echo "Done. Results saved to $LOG_FILE."

