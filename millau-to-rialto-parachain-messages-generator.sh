#!/bin/bash
. ./prelude.sh

# THIS SCRIPT IS NOT INTENDED FOR USE IN PRODUCTION ENVIRONMENT
#
# This scripts periodically calls relay binary to generate Millau -> RialtoParachain
# messages.

set -eu

# Path to relay binary
RELAY_BINARY_PATH=./bin/substrate-relay
# Millau node host
MILLAU_HOST=127.0.0.1
# Millau node port
MILLAU_PORT=10946
# Millau signer
MILLAU_SIGNER=//Dave
# RialtoParachain signer
RIALTO_PARACHAIN_SIGNER=//Dave
# Max delay before submitting transactions (s)
MAX_SUBMIT_DELAY_S=60
# Lane to send message over
LANE=00000000

# submit Millau to RialtoParachain message
submit_message() {
	MESSAGE_PARAMS="$*"
	$RELAY_BINARY_PATH 2>&1 send-message millau-to-rialto-parachain \
		--source-host=$MILLAU_HOST\
		--source-port=$MILLAU_PORT\
		--source-signer=$MILLAU_SIGNER\
		--target-signer=$RIALTO_PARACHAIN_SIGNER\
		--lane=$LANE\
		--origin Target \
		$MESSAGE_PARAMS
}

# give conversion rate updater some time to update RialtoParachain->Millau conversion rate in Millau
sleep 90

BATCH_TIME=0
while true
do
	SUBMIT_DELAY_S=`shuf -i 0-$MAX_SUBMIT_DELAY_S -n 1`
	# sleep some time
	echo "Sleeping $SUBMIT_DELAY_S seconds..."
	sleep $SUBMIT_DELAY_S
	date "+%Y-%m-%d %H:%M:%S"

	# prepare message to send
	MESSAGE="remark --remark-payload=01234567"

	# submit message
	echo "Sending message from Millau to RialtoParachain"
	submit_message $MESSAGE
done
