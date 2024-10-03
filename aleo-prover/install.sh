#!/bin/bash

PKG_DIR=/opt/aleo/prover

while test $# -gt 0
do
    case "$1" in
        --address) ADDRESS=$2; shift ;;
        --pool) POOL_HOST=$2; shift ;;
        --socks) SOCKS_HOST=$2; shift ;;
        --agent) AGENT_HOST=$2; shift ;;
        --name) WORKER_NAME=$2; shift ;;
        *) REST_ARGS="$REST_ARGS $1"
        ;;
    esac
    shift
done

if [ -z "$ADDRESS" ]; then
    echo "--address param empty"
    exit
fi

if [ -z "$AGENT_HOST" ]; then
    echo "--agent param empty"
    exit
fi

if [ -z "$POOL_HOST" ]; then
    echo "--pool param empty"
    exit
fi


sudo rm $PKG_DIR/* -R
sudo mkdir -p ${PKG_DIR}
sudo chmod 777 ${PKG_DIR}

cp * -R $PKG_DIR/
cd $PKG_DIR

if [ -z "$WORKER_NAME" ]; then
    if type ip &> /dev/null; then
        echo "ip command found"
    else
        echo "ip command not found"
        sudo apt update
        sudo apt install -y iproute2
    fi
    WORKER_NAME=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
fi


ADDRESS_WORKER=$ADDRESS.$WORKER_NAME
PROVER_PARAMS=" -l $PKG_DIR/prover.log -a $AGENT_HOST -w $ADDRESS_WORKER " 


if [[ $POOL_HOST == tcp://* ]]; then
    #tcp
    POOL_HOST=${POOL_HOST#tcp://}
    PROVER_PARAMS=$PROVER_PARAMS" -p $POOL_HOST "
elif [[ $POOL_HOST == tls://* ]]; then
    #tls
    POOL_HOST=${POOL_HOST#tls://}
    PROVER_PARAMS=$PROVER_PARAMS" -tls=true -p $POOL_HOST "
else
    echo "--pool param err"
    exit;
fi


if [[ -n "$SOCKS_HOST" ]]; then
    PROVER_PARAMS=$PROVER_PARAMS" -sock $SOCKS_HOST"
fi

echo $PROVER_PARAMS
echo "#!/bin/bash
cd $PKG_DIR
export LD_LIBRARY_PATH=./:\$LD_LIBRARY_PATH
./aleo-prover $PROVER_PARAMS
" > start.sh 

chmod 755 start.sh

echo "#!/bin/bash
ps -aux | grep aleo-prover | grep -v grep | awk '{print \$2}' | xargs kill -9
" > stop.sh 

chmod 755 stop.sh

PROGRAM_NAME=aleo-prover
sudo echo "[Unit]
Description=$PROGRAM_NAME
After=network.target

[Service]
ExecStart=$PKG_DIR/start.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
" > ./$PROGRAM_NAME.service
sudo cp ./$PROGRAM_NAME.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $PROGRAM_NAME

echo "start $PROGRAM_NAME..."
sudo systemctl start $PROGRAM_NAME

rm install.sh


echo "install to directory: $PKG_DIR"
echo "install successfully!"
