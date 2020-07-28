#!/bin/bash
. ./prelude.sh

cargo build --manifest-path=$BRIDGES_REPO_PATH/bin/node/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/release/bridge-node ./bin