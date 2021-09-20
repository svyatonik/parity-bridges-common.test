#!/bin/bash
. ./prelude.sh

if [ -z "$SKIP_SUBSTRATE_RELAY_BUILD" ]; then

cargo build $BUILD_TYPE --manifest-path=$BRIDGES_REPO_PATH/relays/bin-substrate/Cargo.toml
cp $BRIDGES_REPO_PATH/target/$BUILD_FOLDER/substrate-relay ./bin

fi
