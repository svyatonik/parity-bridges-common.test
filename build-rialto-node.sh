#!/bin/bash
. ./prelude.sh

cargo build --release --manifest-path=$BRIDGES_REPO_PATH/bin/rialto/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/release/rialto-bridge-node ./bin