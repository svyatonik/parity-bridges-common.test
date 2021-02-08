#!/bin/bash

killall -9 parity
killall -9 millau-bridge-node
killall -9 rialto-bridge-node
killall -9 ethereum-poa-relay
killall -9 substrate-relay
pkill -9 -f 'sleep 30'
pkill -9 -f 'poa-exchange-tx-generator-entrypoint.sh'
pkill -9 -f 'millau-messages-generator.sh'
pkill -9 -f 'rialto-messages-generator.sh'
docker stop relay-prometheus
docker stop relay-grafana