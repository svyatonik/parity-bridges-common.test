#!/bin/bash

. ./prelude.sh
. ./build-millau-node.sh
. ./build-rialto-node.sh
. ./build-ethereum-relay.sh
. ./build-substrate-relay.sh

rm -rf logs/*
bash ./start-rialto.sh
bash ./start-millau.sh
bash ./start-dashboards.sh
