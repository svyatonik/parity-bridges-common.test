#!/bin/bash
. ./prelude.sh
. ./build-millau-node.sh
. ./build-substrate-relay.sh

###############################################################################
### Millau (Substrate) chain startup ##########################################
###############################################################################

# TODO: Millau should use other authorities && other session management

# remove Millau databases
rm -rf data/millau-alice.db
rm -rf data/millau-bob.db
rm -rf data/millau-charlie.db
rm -rf data/millau-dave.db
rm -rf data/millau-eve.db

# start Millau nodes
RUST_LOG=runtime=trace ./run-with-log.sh millau-alice "./bin/millau-bridge-node\
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
RUST_LOG=runtime=trace ./run-with-log.sh millau-bob "./bin/millau-bridge-node\
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
RUST_LOG=runtime=trace ./run-with-log.sh millau-charlie "./bin/millau-bridge-node\
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
RUST_LOG=runtime=trace ./run-with-log.sh millau-dave "./bin/millau-bridge-node\
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
RUST_LOG=runtime=trace ./run-with-log.sh millau-eve "./bin/millau-bridge-node\
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
### Starting Millau -> Rialto relays (Rialto transactions are               ###
### signed by Bob)                                                          ###
###############################################################################

# common variables
MILLAU_HOST=127.0.0.1
MILLAU_PORT=10933
RIALTO_HOST=127.0.0.1
RIALTO_PORT=9933
RELAY_BINARY_PATH=./bin/substrate-relay
RUST_LOG=bridge=trace,runtime=trace
export MILLAU_HOST MILLAU_PORT RIALTO_HOST RIALTO_PORT RELAY_BINARY_PATH RUST_LOG

# start millau-headers-to-rialto relay
./run-with-log.sh relay-millau-to-rialto "./bin/substrate-relay\
	millau-headers-to-rialto\
	--millau-host=$MILLAU_HOST\
	--millau-port=$MILLAU_PORT\
	--rialto-host=$RIALTO_HOST\
	--rialto-port=$RIALTO_PORT\
	--rialto-signer=//Bob"&
