#!/bin/bash
. ./prelude.sh

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
MILLAU_SIGNER=//Alice
# Max delay before submitting transactions (s)
MAX_SUBMIT_DELAY_S=60
# Lane to send message over
LANE=00000000
# Maximal number of unconfirmed messages at the target chain (Millau)
MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE=1024

# submit Rialto to Millau message
submit_message() {
	MESSAGE_PARAMS="$*"
	$RELAY_BINARY_PATH 2>&1 send-message rialto-to-millau \
		--source-host=$RIALTO_HOST\
		--source-port=$RIALTO_PORT\
		--source-signer=$RIALTO_SIGNER\
		--target-signer=$MILLAU_SIGNER\
		--lane=$LANE\
		--origin Target \
		$MESSAGE_PARAMS
}

# submit Rialto to Millau message at lane#1
submit_message_at_lane_1() {
	MESSAGE_PARAMS="$*"
	$RELAY_BINARY_PATH 2>&1 send-message rialto-to-millau \
		--source-host=$RIALTO_HOST\
		--source-port=$RIALTO_PORT\
		--source-signer=$RIALTO_SIGNER\
		--target-signer=$MILLAU_SIGNER\
		--lane=00000001\
		--origin Target\
		--dispatch-fee-payment=at-target-chain\
		--dispatch-weight=max\
		$MESSAGE_PARAMS

	$RELAY_BINARY_PATH 2>&1 send-message rialto-to-millau \
		--source-host=$RIALTO_HOST\
		--source-port=$RIALTO_PORT\
		--source-signer=$RIALTO_SIGNER\
		--target-signer=$MILLAU_SIGNER\
		--lane=00000001\
		--origin Target\
		--dispatch-fee-payment=at-source-chain\
		--dispatch-weight=max\
		$MESSAGE_PARAMS
}

# give conversion rate updater some time to update Millau->Rialto conversion rate in Rialto
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
	echo "Sending message from Rialto to Millau"
	submit_message $MESSAGE
	submit_message_at_lane_1 $MESSAGE

	if [ ! -z "$GENERATE_LARGE_MESSAGES" ]; then

		# submit messages with maximal size. chance ~10%
		if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
			MESSAGES_COUNT=`shuf -i 1-6 -n 1`
			echo "Sending $MESSAGES_COUNT maximal size messages from Rialto to Millau"
			for i in $(seq 1 $MESSAGES_COUNT);
			do
				submit_message remark --remark-size=max
			done
		fi

		# submit messages with maximal dispatch weight. chance ~10%
		if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
			MESSAGES_COUNT=`shuf -i 1-6 -n 1`
			echo "Sending $MESSAGES_COUNT maximal dispatch weight messages from Rialto to Millau"
			for i in $(seq 1 $MESSAGES_COUNT);
			do
				submit_message --dispatch-weight=max remark
			done
		fi

		# submit messages with both maximal size and dispatch weight. chance ~10%
		if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
			MESSAGES_COUNT=`shuf -i 1-3 -n 1`
			echo "Sending $MESSAGES_COUNT maximal size + dispatch weight messages from Rialto to Millau"
			for i in $(seq 1 $MESSAGES_COUNT);
			do
				submit_message --dispatch-weight=max remark --remark-size=max
			done
		fi

		# submit a lot of regular messages. chance ~10%, but at most once per 30m
		if [ $SECONDS -ge $BATCH_TIME ]; then
			if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
				BATCH_TIME=$((SECONDS + 1800))

				echo "Sending $MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE simple messages from Rialto to Millau"
				for i in $(seq 1 $MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE);
				do
					submit_message remark
				done
			fi
		fi

	fi
done
