#!/bin/bash
. ./prelude.sh

cargo build --release --manifest-path=$BRIDGES_REPO_PATH/relays/substrate/Cargo.toml
cp $BRIDGES_REPO_PATH/target/release/substrate-relay ./bin