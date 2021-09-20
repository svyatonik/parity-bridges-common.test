#!/bin/bash
. ./prelude.sh

if [ -z "$SKIP_RIALTO_PARACHAIN_COLLATOR_BUILD" ]; then

cargo build $BUILD_TYPE --manifest-path=$BRIDGES_REPO_PATH/bin/rialto-parachain/node/Cargo.toml
cp $BRIDGES_REPO_PATH/target/$BUILD_FOLDER/rialto-parachain-collator ./bin

fi
