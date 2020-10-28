#!/bin/bash

killall -9 parity
killall -9 millau-bridge-node
killall -9 rialto-bridge-node
killall -9 ethereum-poa-relay
killall -9 substrate-relay
kill -9 `ps -A -o pid,args -C bash | awk '/poa-exchange-tx-generator-entrypoint.sh/ { print $1 }' | head -n 1`
docker stop rialto-relay-prometheus
docker stop rialto-relay-grafana