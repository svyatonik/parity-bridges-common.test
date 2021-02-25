#!/bin/bash
. ./prelude.sh

cargo build $BUILD_TYPE --manifest-path=$BRIDGES_REPO_PATH/bin/rialto/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/$BUILD_FOLDER/rialto-bridge-node ./bin