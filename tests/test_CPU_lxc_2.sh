
CONTAINER_NAME="test-container"
TEMPLATE="ubuntu"

for x in {1..10}
do
    echo "[$(date)] Iteration $x" | tee -a record_lxc.txt

    sudo lxc-stop -n $CONTAINER_NAME 2>/dev/null
    sudo lxc-destroy -n $CONTAINER_NAME 2>/dev/null

    sudo lxc-create -n $CONTAINER_NAME -t $TEMPLATE
    sudo lxc-start -n $CONTAINER_NAME -d

    sudo lxc-attach -n $CONTAINER_NAME -- bash -c "
        apt update &&
        DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip &&
        pip3 install numpy
    "

    sudo cp ../assets/stress.py /var/lib/lxc/$CONTAINER_NAME/rootfs/root/

    sudo lxc-attach -n $CONTAINER_NAME -- bash -c "python3 /root/stress.py &"

    PID=$(sudo lxc-info -n $CONTAINER_NAME -pH)
    echo "PID: $PID" | tee -a record_lxc.txt

    ps -p $PID -o comm,%cpu,%mem,cmd | tee -a record_lxc.txt
    pidstat -h -r -u -p $PID 1 1 | tee -a record_lxc.txt

    sudo lxc-stop -n $CONTAINER_NAME
    sudo lxc-destroy -n $CONTAINER_NAME

    sleep 2
done

