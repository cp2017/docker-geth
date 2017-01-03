#!/bin/bash


GETH_OPTS="--rpc --rpcaddr 0.0.0.0 --rpcapi db,eth,net,web3,personal,shh --shh"

geth $(echo ${GETH_OPTS} | tr -d '"')
