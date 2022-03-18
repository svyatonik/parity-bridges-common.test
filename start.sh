#!/bin/bash

mkdir bin >/dev/null 2>&1 || true
mkdir data >/dev/null 2>&1 || true
mkdir logs >/dev/null 2>&1 || true

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
