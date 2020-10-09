#!/bin/bash
curl --location --request POST 'http://localhost:10933' --header 'Content-Type: application/json' --data-raw '{"jsonrpc": "2.0", "method": "chain_getBlockHash", "params": [0], "id": 1}' 2>/dev/null | sed -n --expression='s/.*"result":"\([^"]*\)".*/\1/p'
