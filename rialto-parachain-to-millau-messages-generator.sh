#!/bin/bash
. ./prelude.sh

# THIS SCRIPT IS NOT INTENDED FOR USE IN PRODUCTION ENVIRONMENT
#
# This scripts periodically calls relay binary to generate RialtoParachain -> Millau
# messages.

set -eu

# Path to relay binary
RELAY_BINARY_PATH=./bin/substrate-relay
# RialtoParachain node host
RIALTO_PARACHAIN_HOST=127.0.0.1
# RialtoParachain node port
RIALTO_PARACHAIN_PORT=11949
# RialtoParachain signer
RIALTO_PARACHAIN_SIGNER=//Charlie
# Millau signer
MILLAU_SIGNER=//Alice
# Max delay before submitting transactions (s)
MAX_SUBMIT_DELAY_S=60
# Lane to send message over
LANE=00000000

# submit RialtoParachain to Millau message
submit_message() {
	MESSAGE_PARAMS="$*"
	$RELAY_BINARY_PATH 2>&1 send-message rialto-parachain-to-millau \
		--source-host=$RIALTO_PARACHAIN_HOST\
		--source-port=$RIALTO_PARACHAIN_PORT\
		--source-signer=$RIALTO_PARACHAIN_SIGNER\
		--target-signer=$MILLAU_SIGNER\
		--lane=$LANE\
		--origin Target \
		$MESSAGE_PARAMS
}

# give conversion rate updater some time to update Millau->RialtoParachain conversion rate in RialtoParachain
sleep 90

BATCH_TIME=0
while true
do
	# sleep some time
	SUBMIT_DELAY_S=`shuf -i 0-$MAX_SUBMIT_DELAY_S -n 1`
	echo "Sleeping $SUBMIT_DELAY_S seconds..."
	sleep $SUBMIT_DELAY_S
	date "+%Y-%m-%d %H:%M:%S"

	# prepare message to send
	MESSAGE="remark --remark-payload=01234567"

	# submit message
	echo "Sending message from RialtoParachain to Millau"
	submit_message $MESSAGE
done
