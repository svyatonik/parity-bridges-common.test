#!/bin/bash
. ./prelude.sh

if [ -z "$SKIP_ETHEREUM_RELAY_BUILD" ]; then

cargo build --manifest-path=$BRIDGES_REPO_PATH/relays/bin-ethereum/Cargo.toml
cp $BRIDGES_REPO_PATH/target/debug/ethereum-poa-relay ./bin

fi
