#!/bin/bash
. ./prelude.sh

if [ -z "$SKIP_MILLAU_NODE_BUILD" ]; then

cargo build $BUILD_TYPE --manifest-path=$BRIDGES_REPO_PATH/bin/millau/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/$BUILD_FOLDER/millau-bridge-node ./bin

fi
