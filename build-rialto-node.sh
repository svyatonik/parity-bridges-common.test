#!/bin/bash
. ./prelude.sh

cargo build --manifest-path=$BRIDGES_REPO_PATH/bin/millau-node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/debug/rialto-bridge-node ./bin