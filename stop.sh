#!/bin/bash

killall -9 parity
killall -9 millau-bridge-node
killall -9 rialto-bridge-node
killall -9 ethereum-poa-relay
killall -9 substrate-relay
killall -9 rialto-parachain-collator
pkill -9 -f 'sleep 30'
pkill -9 -f 'poa-exchange-tx-generator.sh'
pkill -9 -f 'millau-to-rialto-messages-generator.sh'
pkill -9 -f 'rialto-to-millau-messages-generator.sh'
pkill -9 -f 'millau-to-rialto-parachain-messages-generator.sh'
pkill -9 -f 'rialto-parachain-to-millau-messages-generator.sh'
pkill -9 -f 'token-swap-generator.sh'
docker stop relay-prometheus
docker stop relay-grafana