#!/bin/bash
. ./prelude.sh
. ./build-millau-node.sh
. ./build-substrate-relay.sh

###############################################################################
### Millau (Substrate) chain startup ##########################################
###############################################################################

# TODO: Millau should use other authorities && other session management

RUST_LOG=runtime=trace,runtime::bridge=trace,txpool=trace,sc_basic_authorship=trace
export RUST_LOG

# remove Millau databases
rm -rf data/millau-alice.db
rm -rf data/millau-bob.db
rm -rf data/millau-charlie.db
rm -rf data/millau-dave.db
rm -rf data/millau-eve.db

if [ -z "$DISABLE_MILLAU" ]; then

# start Millau nodes
./run-with-log.sh millau-alice "./bin/millau-bridge-node\
	--alice\
	--base-path=data/millau-alice.db\
	--bootnodes=/ip4/127.0.0.1/tcp/40334/p2p/12D3KooWM5LFR5ne4yTQ4sBSXJ75M4bDo2MAhAW2GhL3i8fe5aRb\
	--node-key=0f900c89f4e626f4a217302ab8c7d213737d00627115f318ad6fb169717ac8e0\
	--port=40333\
	--prometheus-port=10615\
	--rpc-port=10933\
	--ws-port=10944\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh millau-bob "./bin/millau-bridge-node\
	--bob\
	--base-path=data/millau-bob.db\
	--bootnodes=/ip4/127.0.0.1/tcp/40333/p2p/12D3KooWFqiV73ipQ1jpfVmCfLqBCp8G9PLH3zPkY9EhmdrSGA4H\
	--node-key=db383639ff2905d79f8e936fd5dc4416ef46b514b2f83823ec3c42753d7557bb\
	--port=40334\
	--prometheus-port=10616\
	--rpc-port=10934\
	--ws-port=10945\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh millau-charlie "./bin/millau-bridge-node\
	--charlie\
	--base-path=data/millau-charlie.db\
	--bootnodes=/ip4/127.0.0.1/tcp/40333/p2p/12D3KooWFqiV73ipQ1jpfVmCfLqBCp8G9PLH3zPkY9EhmdrSGA4H\
	--port=40335\
	--prometheus-port=10617\
	--rpc-port=10935\
	--ws-port=10946\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh millau-dave "./bin/millau-bridge-node\
	--dave\
	--base-path=data/millau-dave.db\
	--bootnodes=/ip4/127.0.0.1/tcp/40333/p2p/12D3KooWFqiV73ipQ1jpfVmCfLqBCp8G9PLH3zPkY9EhmdrSGA4H\
	--port=40336\
	--prometheus-port=10618\
	--rpc-port=10936\
	--ws-port=10947\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh millau-eve "./bin/millau-bridge-node\
	--eve\
	--base-path=data/millau-eve.db\
	--bootnodes=/ip4/127.0.0.1/tcp/40333/p2p/12D3KooWFqiV73ipQ1jpfVmCfLqBCp8G9PLH3zPkY9EhmdrSGA4H\
	--port=40337\
	--prometheus-port=10619\
	--rpc-port=10937\
	--ws-port=10948\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&

###############################################################################
### Give nodes some time to startup ###########################################
###############################################################################
sleep 20

###############################################################################
### Initialize header bridges #################################################
###############################################################################

# common variables
MILLAU_HOST=127.0.0.1
MILLAU_PORT=10944
RIALTO_HOST=127.0.0.1
RIALTO_PORT=9944
RELAY_BINARY_PATH=./bin/substrate-relay
RUST_LOG=bridge=trace,bridge-metrics=trace
export MILLAU_HOST MILLAU_PORT RIALTO_HOST RIALTO_PORT RELAY_BINARY_PATH RUST_LOG

# initialize Millau -> Rialto headers bridge
./run-with-log.sh initialize-millau-to-rialto "$RELAY_BINARY_PATH\
	init-bridge millau-to-rialto\
	--source-host=$MILLAU_HOST\
	--source-port=$MILLAU_PORT\
	--target-host=$RIALTO_HOST\
	--target-port=$RIALTO_PORT\
	--target-signer=//Alice"&

# initialize Rialto -> Millau headers bridge
./run-with-log.sh initialize-rialto-to-millau "$RELAY_BINARY_PATH\
	init-bridge rialto-to-millau\
	--source-host=$RIALTO_HOST\
	--source-port=$RIALTO_PORT\
	--target-host=$MILLAU_HOST\
	--target-port=$MILLAU_PORT\
	--target-signer=//Alice"&

# wait until transactions are mined
sleep 10

###############################################################################
### Start generating messages on Millau <-> Rialto lanes ######################
###############################################################################

# start generating Millau -> Rialto messages
./run-with-log.sh \
	millau-to-rialto-messages-generator\
	./millau-to-rialto-messages-generator.sh&

# start generating Rialto -> Millau messages
./run-with-log.sh \
	rialto-to-millau-messages-generator\
	./rialto-to-millau-messages-generator.sh&

# start generating tokens swap
./run-with-log.sh \
	token-swap-generator\
	./token-swap-generator.sh&

# start millau transactions resubmitter
./run-with-log.sh millau-to-rialto-messages-resubmitter "$RELAY_BINARY_PATH\
	resubmit-transactions millau\
	--target-host=$MILLAU_HOST\
	--target-port=10946\
	--target-signer=//Dave\
	--tip-limit 1000000000000\
	--tip-step 1000000000"&

###############################################################################
### Starting Millau -> Rialto relays ##########################################
###############################################################################

if [ -z "$USE_COMPLEX_MILLAU_RIALTO_RELAY" ]; then

# start millau-headers-to-rialto relay
./run-with-log.sh relay-millau-to-rialto "$RELAY_BINARY_PATH\
	relay-headers millau-to-rialto\
	--source-host=$MILLAU_HOST\
	--source-port=$MILLAU_PORT\
	--target-host=$RIALTO_HOST\
	--target-port=$RIALTO_PORT\
	--target-signer=//Charlie\
	--prometheus-port=9700"&

# start rialto-headers-to-millau relay
./run-with-log.sh relay-rialto-to-millau "$RELAY_BINARY_PATH\
	relay-headers rialto-to-millau\
	--source-host=$RIALTO_HOST\
	--source-port=$RIALTO_PORT\
	--target-host=$MILLAU_HOST\
	--target-port=$MILLAU_PORT\
	--target-signer=//Charlie\
	--prometheus-port=9701"&

# start millau-messages-to-rialto relay
./run-with-log.sh relay-millau-to-rialto-messages "$RELAY_BINARY_PATH\
	relay-messages millau-to-rialto\
	--source-host=$MILLAU_HOST\
	--source-port=$MILLAU_PORT\
	--source-signer=//Eve\
	--target-host=$RIALTO_HOST\
	--target-port=$RIALTO_PORT\
	--target-signer=//Eve\
	--prometheus-port=9702\
	--lane=00000000"&

# start rialto-messages-to-millau relay
./run-with-log.sh relay-rialto-to-millau-messages "$RELAY_BINARY_PATH\
	relay-messages rialto-to-millau\
	--source-host=$RIALTO_HOST\
	--source-port=$RIALTO_PORT\
	--source-signer=//Ferdie\
	--target-host=$MILLAU_HOST\
	--target-port=$MILLAU_PORT\
	--target-signer=//Ferdie\
	--prometheus-port=9703\
	--lane=00000000"&

else

# start millau-rialto headers+messages relay
./run-with-log.sh relay-millau-rialto "$RELAY_BINARY_PATH\
	relay-headers-and-messages millau-rialto\
	--millau-host=$MILLAU_HOST\
	--millau-port=$MILLAU_PORT\
	--millau-signer=//Charlie\
	--millau-transactions-mortality=64\
	--rialto-host=$RIALTO_HOST\
	--rialto-port=$RIALTO_PORT\
	--rialto-signer=//Charlie\
	--rialto-transactions-mortality=64\
	--lane=00000000\
	--lane=00000001\
	--lane=73776170\
	--prometheus-port=9700\
	--millau-messages-pallet-owner=//RialtoMessagesOwner\
	--rialto-messages-pallet-owner=//MillauMessagesOwner"&

# start rialto-to-millau messages relay for lane#2
./run-with-log.sh relay-rialto-to-millau-messages-00000002 "$RELAY_BINARY_PATH\
	relay-messages rialto-to-millau\
	--source-host=$RIALTO_HOST\
	--source-port=$RIALTO_PORT\
	--source-signer=//Eve\
	--target-host=$MILLAU_HOST\
	--target-port=$MILLAU_PORT\
	--target-signer=//Eve\
	--prometheus-port=9701\
	--lane=00000002"&

# start millau-to-rialto messages relay for lane#2
./run-with-log.sh relay-millau-to-rialto-messages-00000002 "$RELAY_BINARY_PATH\
	relay-messages millau-to-rialto\
	--source-host=$MILLAU_HOST\
	--source-port=$MILLAU_PORT\
	--source-signer=//Ferdie\
	--target-host=$RIALTO_HOST\
	--target-port=$RIALTO_PORT\
	--target-signer=//Ferdie\
	--prometheus-port=9702\
	--lane=00000002"&

fi

###############################################################################
### The rest is not executed if Westend -> Millau bridge is disabled ##########
###############################################################################

if [ -z "$DISABLE_WESTEND_TO_MILLAU" ]; then

# common variables
WESTEND_HOST=westend-rpc.polkadot.io
WESTEND_PORT=443

# initialize Westend -> Millau headers bridge
./run-with-log.sh initialize-westend-to-millau "$RELAY_BINARY_PATH\
	init-bridge westend-to-millau\
	--source-host=$WESTEND_HOST\
	--source-port=$WESTEND_PORT\
	--source-secure\
	--target-host=$MILLAU_HOST\
	--target-port=$MILLAU_PORT\
	--target-signer=//George"&

# wait until transactions are mined
sleep 20

# start westend-headers-to-millau relay
./run-with-log.sh relay-westend-to-millau "$RELAY_BINARY_PATH\
	relay-headers westend-to-millau\
	--source-host=$WESTEND_HOST\
	--source-port=$WESTEND_PORT\
	--source-secure\
	--target-host=$MILLAU_HOST\
	--target-port=$MILLAU_PORT\
	--target-signer=//George\
	--prometheus-port=9704"&
#	--target-transactions-mortality=4\

fi


fi