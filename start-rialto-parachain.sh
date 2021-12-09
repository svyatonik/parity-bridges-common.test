#!/bin/bash
. ./prelude.sh
. ./build-rialto-parachain-collator.sh

# remove rialto databases
rm -rf data/rialto-parachain-alice.db
rm -rf data/rialto-parachain-bob.db
rm -rf data/rialto-parachain-charlie.db

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

./bin/rialto-bridge-node build-spec --chain local --raw --disable-default-bootnode > ./data/rialto-relaychain-spec-raw.json
CHAIN=./data/rialto-relaychain-spec-raw.json

###############################################################################
### Start parachain node ######################################################
###############################################################################

RUST_LOG=parachain=trace,rpc=trace
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
	--chain $CHAIN \
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
	--chain $CHAIN \
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
	--chain $CHAIN \
	--port 30502 \
	--ws-port 12002"&

###############################################################################
### Register Rialto parachain #################################################
###############################################################################

RUST_LOG=bridge=trace
export RUST_LOG

./run-with-log.sh rialto-parachain-registrator "./bin/substrate-relay register-parachain rialto-parachain \
	--parachain-host 127.0.0.1 \
	--parachain-port 11949 \
	--relaychain-host 127.0.0.1 \
	--relaychain-port 9944 \
	--relaychain-signer //Alice"&

###############################################################################
### Start Rialto -> Millau parachains relay ###################################
###############################################################################

./run-with-log.sh rialto-to-millau-parachain-relay "./bin/substrate-relay relay-parachains rialto-to-millau \
	--source-host 127.0.0.1 \
	--source-port 9944 \
	--target-host 127.0.0.1 \
	--target-port 10944 \
	--target-signer //George"&

###############################################################################
### Start generating messages on Millau <> RialtoParachain lanes ##############
###############################################################################

# start generating Millau -> RialtoParachain messages
./run-with-log.sh \
	millau-to-rialto-parachain-messages-generator\
	./millau-to-rialto-parachain-messages-generator.sh&

# start generating RialtoParachain -> Millau messages
./run-with-log.sh \
	rialto-parachain-to-millau-messages-generator\
	./rialto-parachain-to-millau-messages-generator.sh&

###############################################################################
### Start RialtoParachain <-> Millau messages relays ##########################
###############################################################################

#./run-with-log.sh relay-rialto-parachain-to-millau-messages "./bin/substrate-relay relay-messages rialto-parachain-to-millau \
#	--source-host 127.0.0.1 \
#	--source-port 11949 \
#	--target-host 127.0.0.1 \
#	--target-port 10944 \
#	--target-signer //Harry"&

./run-with-log.sh relay-millau-to-rialto-parachain-messages "./bin/substrate-relay relay-messages millau-to-rialto-parachain \
	--relayer-mode=altruistic \
	--source-host 127.0.0.1 \
	--source-port 10944 \
	--source-signer //Harry \
	--target-host 127.0.0.1 \
	--target-port 11949 \
	--target-signer //Harry"&

# or manual actions:
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

