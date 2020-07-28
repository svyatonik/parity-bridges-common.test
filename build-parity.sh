#!/bin/bash
. ./prelude.sh

cargo build --manifest-path=$OPEN_ETHEREUM_REPO_PATH/Cargo.toml
cp $OPEN_ETHEREUM_REPO_PATH/target/debug/openethereum ./bin/parity
