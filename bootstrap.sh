#!/bin/bash

geth --exec 'personal.newAccount("pw0")' --ipcpath /root/.ethereum/geth.ipc  attach

