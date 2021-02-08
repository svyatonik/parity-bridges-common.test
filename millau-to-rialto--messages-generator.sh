#!/bin/bash

# THIS SCRIPT IS NOT INTENDED FOR USE IN PRODUCTION ENVIRONMENT
#
# This scripts periodically calls relay binary to generate Millau -> Rialto
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
# Rialto signer
RIALTO_SIGNER=//Dave
# Max delay before submitting transactions (s)
MAX_SUBMIT_DELAY_S=60
# Lane to send message over
LANE=00000000
# Maximal number of unconfirmed messages at the target chain (Millau)
MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE=128

# submit Millau to Rialto message
submit_message() {
	$RELAY_BINARY_PATH 2>&1 submit-millau-to-rialto-message \
		--millau-host=$MILLAU_HOST\
		--millau-port=$MILLAU_PORT\
		--millau-signer=$MILLAU_SIGNER\
		--rialto-signer=$RIALTO_SIGNER\
		--lane=$LANE\
		--origin Target \
		$1
}

while true
do
	# sleep some time
	SUBMIT_DELAY_S=`shuf -i 0-$MAX_SUBMIT_DELAY_S -n 1`
	echo "Sleeping $SUBMIT_DELAY_S seconds..."
	sleep $SUBMIT_DELAY_S

	# prepare message to send
	MESSAGE=remark

	# submit message
	echo "Sending message from Millau to Rialto"
	submit_message $MESSAGE

	# submit messages with maximal size. chance ~10%
	if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
		MESSAGES_COUNT=`shuf -i 1-6 -n 1`
		echo "Sending $MESSAGES_COUNT maximal size messages from Millau to Rialto"
		for i in $(seq 1 $MESSAGES_COUNT);
		do
			submit_message maximal-size-remark
		done
	fi

	# submit messages with maximal dispatch weight. chance ~10%
	if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
		MESSAGES_COUNT=`shuf -i 1-6 -n 1`
		echo "Sending $MESSAGES_COUNT maximal dispatch weight messages from Millau to Rialto"
		for i in $(seq 1 $MESSAGES_COUNT);
		do
			submit_message maximal-weight-fill-block
		done
	fi

	# submit messages with maximal dispatch weight. chance ~10%
	if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
		echo "Sending $MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE simple messages from Millau to Rialto"
		for i in $(seq 1 $MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE);
		do
			submit_message remark
		done
	fi
done
