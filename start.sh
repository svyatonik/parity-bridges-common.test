#!/bin/bash

. ./prelude.sh
. ./build-millau-node.sh
. ./build-rialto-node.sh
. ./build-ethereum-relay.sh
. ./build-substrate-relay.sh
. ./build-rialto-parachain-collator.sh

rm -rf logs/*
bash ./start-rialto.sh
bash ./start-millau.sh
bash ./start-rialto-parachain.sh
bash ./start-dashboards.sh
