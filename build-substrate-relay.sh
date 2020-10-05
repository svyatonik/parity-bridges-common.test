#!/bin/bash
. ./prelude.sh

cargo build --manifest-path=$BRIDGES_REPO_PATH/relays/substrate/Cargo.toml
cp $BRIDGES_REPO_PATH/target/debug/substrate-relay ./bin