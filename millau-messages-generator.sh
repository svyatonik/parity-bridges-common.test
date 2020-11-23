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

while true
do
	# sleep some time
	SUBMIT_DELAY_S=`shuf -i 0-$MAX_SUBMIT_DELAY_S -n 1`
	echo "Sleeping $SUBMIT_DELAY_S seconds..."
	sleep $SUBMIT_DELAY_S

	# prepare message to send
	MESSAGE=Remark

	# prepare fee to pay
	FEE=100000000

	# submit message
	echo "Sending message from Millau to Rialto"
	$RELAY_BINARY_PATH 2>&1 submit-millau-to-rialto-message \
		--millau-host=$MILLAU_HOST\
		--millau-port=$MILLAU_PORT\
		--millau-signer=$MILLAU_SIGNER\
		--rialto-signer=$RIALTO_SIGNER\
		--lane=$LANE\
		--message=$MESSAGE\
		--fee=$FEE
done
