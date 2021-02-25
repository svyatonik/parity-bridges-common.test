#!/bin/bash
. ./prelude.sh

cargo build $BUILD_TYPE --manifest-path=$BRIDGES_REPO_PATH/bin/millau/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/$BUILD_FOLDER/millau-bridge-node ./bin