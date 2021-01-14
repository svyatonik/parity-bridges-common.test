#!/bin/bash

# THIS SCRIPT IS NOT INTENDED FOR USE IN PRODUCTION ENVIRONMENT
#
# This scripts periodically calls relay binary to generate Rialto -> Millau
# messages.

set -eu

# Path to relay binary
RELAY_BINARY_PATH=./bin/substrate-relay
# Rialto node host
RIALTO_HOST=127.0.0.1
# Rialto node port
RIALTO_PORT=9946
# Rialto signer
RIALTO_SIGNER=//Dave
# Millau signer
MILLAU_SIGNER=//Dave
# Max delay before submitting transactions (s)
MAX_SUBMIT_DELAY_S=60
# Lane to send message over
LANE=00000000

while true
do
	# sleep some time
	SUBMIT_DELAY_S=`shuf -i 0-$MAX_SUBMIT_DELAY_S -n 1`
	echo "Sleeping $SUBMIT_DELAY_S seconds..."
	sleep $SUBMIT_DELAY_S

	# prepare message to send
	MESSAGE=remark

	# prepare fee to pay
	FEE=100000000

	# submit message
	echo "Sending message from Rialto to Millau"
	$RELAY_BINARY_PATH 2>&1 submit-rialto-to-millau-message \
		--rialto-host=$RIALTO_HOST\
		--rialto-port=$RIALTO_PORT\
		--rialto-signer=$RIALTO_SIGNER\
		--millau-signer=$MILLAU_SIGNER\
		--lane=$LANE\
		--origin Target \
		$MESSAGE
done
