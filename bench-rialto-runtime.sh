#!/bin/bash
. ./prelude.sh

cargo build --manifest-path=$BRIDGES_REPO_PATH/bin/millau-node/Cargo.toml --release --features runtime-benchmarks
cp $BRIDGES_REPO_PATH/target/release/rialto-bridge-node ./bin/rialto-bridge-node-benchmarks

RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet bridge-eth-poa --extrinsic import_unsigned_header_best_case
RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet bridge-currency-exchange --extrinsic import_peer_transaction_best_case
RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet bridge-currency-exchange --extrinsic import_peer_transaction_when_recipient_does_not_exists
RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet bridge-currency-exchange --extrinsic import_peer_transaction_when_transaction_size_increases
RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet bridge-currency-exchange --extrinsic import_peer_transaction_when_proof_size_increases
RUST_LOG=runtime=trace ./bin/rialto-bridge-node-benchmarks benchmark --pallet bridge-currency-exchange --extrinsic import_peer_transaction_worst_case
