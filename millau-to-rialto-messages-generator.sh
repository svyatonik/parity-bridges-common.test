#!/bin/bash
. ./prelude.sh

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
# Maximal number of unconfirmed messages at the target chain (Rialto)
MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE=128

# submit Millau to Rialto message
submit_message() {
	MESSAGE_PARAMS="$*"
	$RELAY_BINARY_PATH 2>&1 send-message millau-to-rialto \
		--source-host=$MILLAU_HOST\
		--source-port=$MILLAU_PORT\
		--source-signer=$MILLAU_SIGNER\
		--target-signer=$RIALTO_SIGNER\
		--lane=$LANE\
		--origin Target \
		$MESSAGE_PARAMS
}

# submit Millau to Rialto message to lane#1
submit_message_at_lane_1() {
	MESSAGE_PARAMS="$*"
	$RELAY_BINARY_PATH 2>&1 send-message millau-to-rialto \
		--source-host=$MILLAU_HOST\
		--source-port=$MILLAU_PORT\
		--source-signer=$MILLAU_SIGNER\
		--target-signer=$RIALTO_SIGNER\
		--lane=00000001\
		--origin Target\
		--dispatch-fee-payment=at-target-chain\
		--dispatch-weight=max\
		$MESSAGE_PARAMS

	$RELAY_BINARY_PATH 2>&1 send-message millau-to-rialto \
		--source-host=$MILLAU_HOST\
		--source-port=$MILLAU_PORT\
		--source-signer=$MILLAU_SIGNER\
		--target-signer=$RIALTO_SIGNER\
		--lane=00000001\
		--origin Target\
		--dispatch-fee-payment=at-source-chain\
		--dispatch-weight=max\
		$MESSAGE_PARAMS
}

COUNTER=0

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
	echo "Sending message from Millau to Rialto ($COUNTER)"
	submit_message --conversion-rate-override metric $MESSAGE
	submit_message_at_lane_1 --conversion-rate-override metric $MESSAGE

	if [ ! -z "$GENERATE_LARGE_MESSAGES" ]; then

		# submit messages with maximal size. chance ~10%
		if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
			MESSAGES_COUNT=`shuf -i 1-6 -n 1`
			echo "Sending $MESSAGES_COUNT maximal size messages from Millau to Rialto ($((COUNTER + 1)))"
			for i in $(seq 1 $MESSAGES_COUNT);
			do
				COUNTER=$(( COUNTER + 1 ))
				submit_message --conversion-rate-override metric remark --remark-size=max
			done
		fi

		# submit messages with maximal dispatch weight. chance ~10%
		if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
			MESSAGES_COUNT=`shuf -i 1-6 -n 1`
			echo "Sending $MESSAGES_COUNT maximal dispatch weight messages from Millau to Rialto ($((COUNTER + 1)))"
			for i in $(seq 1 $MESSAGES_COUNT);
			do
				COUNTER=$(( COUNTER + 1 ))
				submit_message --dispatch-weight=max --conversion-rate-override metric remark
			done
		fi

		# submit messages with both maximal size and dispatch weight. chance ~10%
		if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
			MESSAGES_COUNT=`shuf -i 1-3 -n 1`
			echo "Sending $MESSAGES_COUNT maximal size + dispatch weight messages from Millau to Rialto ($((COUNTER + 1)))"
			for i in $(seq 1 $MESSAGES_COUNT);
			do
				COUNTER=$(( COUNTER + 1 ))
				submit_message --dispatch-weight=max --conversion-rate-override metric remark --remark-size=max
			done
		fi

		# submit a lot of regular messages. chance ~10%, but at most once per 30m
		if [ $SECONDS -ge $BATCH_TIME ]; then
			if [ `shuf -i 0-100 -n 1` -lt 10 ]; then
				BATCH_TIME=$((SECONDS + 1800))

				echo "Sending $MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE simple messages from Millau to Rialto ($((COUNTER + 1)))"
				COUNTER=$(( COUNTER + 1 ))

				SEND_MESSAGE_OUTPUT=$(submit_message --conversion-rate-override metric remark)
				echo $SEND_MESSAGE_OUTPUT
				ACTUAL_CONVERSION_RATE_REGEX="conversion rate override: ([0-9\.]+)"
				if [[ $SEND_MESSAGE_OUTPUT =~ $ACTUAL_CONVERSION_RATE_REGEX ]]; then
					ACTUAL_CONVERSION_RATE=${BASH_REMATCH[1]}
				else
					echo "Unable to find conversion rate in send-message output"
					exit 1
				fi

				for i in $(seq 2 $MAX_UNCONFIRMED_MESSAGES_AT_INBOUND_LANE);
				do
					COUNTER=$(( COUNTER + 1 ))
					echo "   Sending message #$COUNTER"
					submit_message --conversion-rate-override $ACTUAL_CONVERSION_RATE remark
				done
			fi
		fi

	fi
done
