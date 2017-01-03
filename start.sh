#!/bin/bash

geth --datadir /data/db --nodiscover --port 30301 --rpc --rpcapi db,eth,net,web3,personal,shh --shh --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcport 8545
