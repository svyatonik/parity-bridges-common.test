#!/bin/bash
. ./prelude.sh

cargo build --release --manifest-path=$BRIDGES_REPO_PATH/bin/millau/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/release/millau-bridge-node ./bin