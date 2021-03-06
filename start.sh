#!/bin/bash
set -m 

if [ "X${GETH_TEST_DATABASE}" == "Xtrue" ];then
    echo ">>>>>> Use GETH test database"
    rm -rf /data/db
    cp -r /opt/db /data/
fi
geth --datadir /data/db --nodiscover --port 30301 --rpc --rpcapi db,eth,miner,net,web3,personal,shh --shh --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcport 8545 --ipcpath /root/.ethereum/geth.ipc --ipcapi "db,eth,net,web3,miner" &

if [ "X${GETH_BOOTSTRAP}" == "Xtrue" ];then
    sleep 3
    /opt/bootstrap.sh
fi
fg
