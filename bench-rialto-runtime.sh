#!/bin/bash
. ./prelude.sh

cargo build --manifest-path=$BRIDGES_REPO_PATH/bin/rialto/node/Cargo.toml --release --features runtime-benchmarks
cp $BRIDGES_REPO_PATH/target/release/rialto-bridge-node ./bin/rialto-bridge-node-benchmarks

#RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet=pallet_bridge_eth_poa --extrinsic=*
#RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet=pallet_bridge_currency_exchange --extrinsic=*
RUST_LOG=runtime=trace,pallet_substrate_bridge=trace,pallet_message_lane=trace,pallet_bridge_call_dispatch=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet=pallet_message_lane --extrinsic=*
