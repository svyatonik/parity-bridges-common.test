#!/bin/bash
SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
GENESIS_HASH=`$SCRIPT_DIR/millau-genesis-hash.sh`
REQUEST_BODY="{\"jsonrpc\": \"2.0\", \"method\": \"chain_getHeader\", \"params\": [\"$GENESIS_HASH\"], \"id\": 1}"
curl --location --request POST 'http://localhost:10933' --header 'Content-Type: application/json' --data-raw "$REQUEST_BODY"