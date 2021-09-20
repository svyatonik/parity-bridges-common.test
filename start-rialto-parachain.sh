#!/bin/bash
. ./prelude.sh
. ./build-rialto-parachain-collator.sh

# remove rialto databases
#rm -rf data/rialto-parachain-alice.db
#rm -rf data/rialto-parachain-bob.db
#rm -rf data/rialto-parachain-charlie.db

if [ -z "$DISABLE_RIALTO_PARACHAIN" ]; then

RIALTO_PARACHAIN_COLLATOR_BINARY_PATH=./bin/rialto-parachain-collator

###############################################################################
### Prepare data required for parachain onboarding ############################
###############################################################################

$RIALTO_PARACHAIN_COLLATOR_BINARY_PATH export-genesis-state --parachain-id 2000 > ./data/rialto-parachain-genesis-state
$RIALTO_PARACHAIN_COLLATOR_BINARY_PATH export-genesis-wasm > ./data/rialto-parachain-genesis-wasm

###############################################################################
### Parachain node requires to connect to the relay chain => we need relay ####
### chain spec.                                                            ####
###############################################################################

#./bin/rialto-bridge-node build-spec --chain local --raw --disable-default-bootnode > ./data/rialto-relaychain-spec-raw.json
#CHAIN=./data/rialto-relaychain-spec-raw.json
CHAIN=rococo

###############################################################################
### Start parachain node ######################################################
###############################################################################

RUST_LOG=parachain=trace
export RUST_LOG

./run-with-log.sh rialto-parachain-collator-alice "$RIALTO_PARACHAIN_COLLATOR_BINARY_PATH \
	--alice \
	--collator \
	--force-authoring \
	--parachain-id 2000 \
	--base-path ./data/rialto-parachain-alice.db \
	--port 50333 \
	--ws-port 11949 \
	--rpc-port=11933 \
	-- \
	--execution wasm \
	--chain ./data/rialto-relaychain-spec-raw.json \
	--port 30500 \
	--ws-port 12000"&

./run-with-log.sh rialto-parachain-collator-bob "$RIALTO_PARACHAIN_COLLATOR_BINARY_PATH \
	--bob \
	--collator \
	--force-authoring \
	--parachain-id 2000 \
	--base-path ./data/rialto-parachain-bob.db \
	--port 50335 \
	--ws-port 11950 \
	--rpc-port=11934 \
	-- \
	--execution wasm \
	--chain ./data/rialto-relaychain-spec-raw.json \
	--port 30501 \
	--ws-port 12001"&

./run-with-log.sh rialto-parachain-collator-charlie "$RIALTO_PARACHAIN_COLLATOR_BINARY_PATH \
	--charlie \
	--collator \
	--force-authoring \
	--parachain-id 2000 \
	--base-path ./data/rialto-parachain-charlie.db \
	--port 50336 \
	--ws-port 11951 \
	--rpc-port=11935 \
	-- \
	--execution wasm \
	--chain ./data/rialto-relaychain-spec-raw.json \
	--port 30502 \
	--ws-port 12002"&

# manual actions:
# 1) https://polkadot.js.org/apps/#/ and connect to Rialto node (ws://127.0.0.1:9944)
# 2) reserve parachain id #2000:
#    network/parachains/parathreads/+ParaId
#      para = 2000
#
#    registrar::reserve())
#    https://github.com/substrate-developer-hub/cumulus-workshop/blob/master/en/2-relay-chain/2-reserve.md
# 3) register parathread (without auction/crowdloan):
#    network/parachains/parathreads/+ParaThread
#      para = 2000
#      code = data/rialto-parachain-genesis-wasm
#      initial-state = data/rialto-parachain-genesis-state
#
#    https://github.com/substrate-developer-hub/cumulus-workshop/blob/master/en/5-rococo-registration/1-register.md
# 4) register parachain (option 2): 
#    developer/sudo/slots/forceLease
#      para = 2000
#      leaser = Alice
#      amount = 0
#      period_begin = 0
#      period_end = 100
#
#    https://github.com/substrate-developer-hub/cumulus-workshop/blob/master/en/3-parachains/2-register.md
fi

