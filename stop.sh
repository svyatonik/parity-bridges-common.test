#!/bin/bash

killall -9 parity
killall -9 bridge-node
killall -9 ethereum-poa-relay
kill -9 `ps -A -o pid,args -C bash | awk '/poa-exchange-tx-generator-entrypoint.sh/ { print $1 }' | head -n 1`