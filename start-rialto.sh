#!/bin/bash
. ./prelude.sh
. ./build-rialto-node.sh
. ./build-ethereum-relay.sh

###############################################################################
### Rialto (Substrate) chain startup ##########################################
###############################################################################

RUST_LOG=bridge=trace,runtime=trace,bridge-metrics=info,pallet_substrate_bridge=trace,pallet_bridge_call_dispatch=trace,pallet_message_lane=trace,pallet_message_lane_rpc=trace,jsonrpc_ws_server=trace,parity_ws=trace
export RUST_LOG

# remove Rialto databases
rm -rf data/rialto-alice.db
rm -rf data/rialto-bob.db
rm -rf data/rialto-charlie.db
rm -rf data/rialto-dave.db
rm -rf data/rialto-eve.db

# start Rialto nodes
./run-with-log.sh rialto-alice "./bin/rialto-bridge-node\
	--alice\
	--base-path=data/rialto-alice.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30334/p2p/12D3KooWSEpHJj29HEzgPFcRYVc5X3sEuP3KgiUoqJNCet51NiMX\
	--node-key=79cf382988364291a7968ae7825c01f68c50d679796a8983237d07fe0ccf363b\
	--port=30333\
	--prometheus-port=9615\
	--rpc-port=9933\
	--ws-port=9944\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh rialto-bob "./bin/rialto-bridge-node\
	--bob\
	--base-path=data/rialto-bob.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWMF6JvV319a7kJn5pqkKbhR3fcM2cvK5vCbYZHeQhYzFE\
	--node-key=4f9d0146dd9b7b3bf5a8089e3880023d1df92057f89e96e07bb4d8c2ead75bbd\
	--port=30334\
	--prometheus-port=9616\
	--rpc-port=9934\
	--ws-port=9945\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh rialto-charlie "./bin/rialto-bridge-node\
	--charlie\
	--base-path=data/rialto-charlie.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWMF6JvV319a7kJn5pqkKbhR3fcM2cvK5vCbYZHeQhYzFE\
	--port=30335\
	--prometheus-port=9617\
	--rpc-port=9935\
	--ws-port=9946\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh rialto-dave "./bin/rialto-bridge-node\
	--dave\
	--base-path=data/rialto-dave.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWMF6JvV319a7kJn5pqkKbhR3fcM2cvK5vCbYZHeQhYzFE\
	--port=30336\
	--prometheus-port=9618\
	--rpc-port=9936\
	--ws-port=9947\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&
./run-with-log.sh rialto-eve "./bin/rialto-bridge-node\
	--eve\
	--base-path=data/rialto-eve.db\
	--bootnodes=/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWMF6JvV319a7kJn5pqkKbhR3fcM2cvK5vCbYZHeQhYzFE\
	--port=30337\
	--prometheus-port=9619\
	--rpc-port=9937\
	--ws-port=9948\
	--execution=Native\
	--chain=local\
	--rpc-cors=all\
	--unsafe-rpc-external\
	--unsafe-ws-external"&

###############################################################################
### The rest is not executed if RialtoPoa <-> Rialto bridge is disabled #######
###############################################################################

if [ -z "$DISABLE_RIALTO_POA" ]; then

###############################################################################
### PoA chain startup #########################################################
###############################################################################

# remove PoA databases
rm -rf data/poa-arthur.db
rm -rf data/poa-bertha.db
rm -rf data/poa-carlos.db

# copy files required for PoA nodes
echo password >data/password
mkdir -p data/poa-arthur.db/keys
mkdir -p data/poa-bertha.db/keys
mkdir -p data/poa-carlos.db/keys
cp $BRIDGES_REPO_PATH/deployments/bridges/poa-rialto/poa-config/keys/BridgePoa/arthur.json data/poa-arthur.db/keys
cp $BRIDGES_REPO_PATH/deployments/bridges/poa-rialto/poa-config/keys/BridgePoa/bertha.json data/poa-bertha.db/keys
cp $BRIDGES_REPO_PATH/deployments/bridges/poa-rialto/poa-config/keys/BridgePoa/carlos.json data/poa-carlos.db/keys
yes | cp -rf $BRIDGES_REPO_PATH/deployments/bridges/poa-rialto/poa-config/poa.json data
echo "enode://543d0874df46dff238d62547160f9d11e3d21897d7041bbbe46a04d2ee56d9eaf108f2133c0403159624f7647198e224d0755d23ad0e1a50c0912973af6e8a8a@127.0.0.1:30303" >data/reserved
echo "enode://710de70733e88a24032e53054985f7239e37351f5f3335a468a1a78a3026e9f090356973b00262c346a6608403df2c7107fc4def2cfe4995ea18a41292b9384f@127.0.0.1:30304" >>data/reserved
echo "enode://943525f415b9482f1c49bd39eb979e4e2b406f4137450b0553bffa5cba2928e25ff89ef70f7325aad8a75dbb5955eaecc1aee7ac55d66bcaaa07c8ea58adb23a@127.0.0.1:30305" >>data/reserved

# start PoA nodes
RUST_LOG=bridge-builtin=trace ./run-with-log.sh poa-arthur "./bin/parity\
	--base-path=data/poa-arthur.db\
	--engine-signer=0x005e714f896a8b7cede9d38688c1a81de72a58e4\
	--node-key=arthur\
	--port=30303\
	--jsonrpc-port=8545\
	--chain=data/poa.json\
	--force-sealing\
	--jsonrpc-apis=all\
	--ws-port=8646\
	--password=data/password\
	--reserved-peers=data/reserved\
	--unsafe-expose"&
RUST_LOG=bridge-builtin=trace ./run-with-log.sh poa-bertha "./bin/parity\
	--base-path=data/poa-bertha.db\
	--engine-signer=0x007594304039c2937a12220338aab821d819f5a4\
	--node-key=bertha\
	--port=30304\
	--jsonrpc-port=8546\
	--chain=data/poa.json\
	--force-sealing\
	--jsonrpc-apis=all\
	--ws-port=8647\
	--password=data/password\
	--reserved-peers=data/reserved\
	--unsafe-expose"&
RUST_LOG=bridge-builtin=trace ./run-with-log.sh poa-carlos "./bin/parity\
	--base-path=data/poa-carlos.db\
	--engine-signer=0x004e7a39907f090e19b0b80a277e77b72b22e269\
	--node-key=carlos\
	--port=30305\
	--jsonrpc-port=8547\
	--chain=data/poa.json\
	--force-sealing\
	--jsonrpc-apis=all\
	--ws-port=8648\
	--password=data/password\
	--reserved-peers=data/reserved\
	--unsafe-expose"&

###############################################################################
### Give nodes some time to startup ###########################################
###############################################################################
sleep 20

###############################################################################
### Starting PoA -> Rialto relays (eth transactions are signed by Bertha)   ###
###############################################################################

# common variables
ETH_HOST=127.0.0.1
RELAY_BINARY_PATH=./bin/ethereum-poa-relay
RUST_LOG=bridge=trace,runtime=trace,bridge-metrics=info
export ETH_HOST RELAY_BINARY_PATH RUST_LOG

# start eth2sub headers relay
./run-with-log.sh relay-eth-to-sub "./bin/ethereum-poa-relay\
	eth-to-sub\
	--sub-port=9944\
	--eth-port=8646\
	--sub-signer=//Alice\
	--prometheus-port=9650"&

# start generating exchange transactions on PoA nodes
./run-with-log.sh \
	poa-exchange-tx-generator\
	./poa-exchange-tx-generator.sh&

# start relaying exchange transactions from PoA to Substrate
./run-with-log.sh relay-eth-exchange-sub "./bin/ethereum-poa-relay\
	eth-exchange-sub\
	--sub-port=9944\
	--eth-port=8646\
	--sub-signer=//Bob\
	--prometheus-port=9651"&

###############################################################################
### Starting Rialto -> PoA relays (eth transactions are signed by Artur)    ###
###############################################################################

# deploy bridge contract on PoA chain
./run-with-log.sh relay-eth-deploy-contract "./bin/ethereum-poa-relay\
	eth-deploy-contract\
	--sub-port=9944\
	--eth-port=8646\
	--eth-chain-id 105\
	--eth-signer 0399dbd15cf6ee8250895a1f3873eb1e10e23ca18e8ed0726c63c4aea356e87d"

# wait until block with transaction is mined
sleep 20

# start sub2eth headers relay
./run-with-log.sh relay-sub-to-eth "./bin/ethereum-poa-relay\
	sub-to-eth\
	--sub-port=9944\
	--eth-port=8646\
	--eth-chain-id 105\
	--eth-contract c9a61fb29e971d1dabfd98657969882ef5d0beee\
	--eth-signer 0399dbd15cf6ee8250895a1f3873eb1e10e23ca18e8ed0726c63c4aea356e87d\
	--prometheus-port=9653"&

fi
