#!/bin/bash
curl --location --request POST 'http://localhost:9933' --header 'Content-Type: application/json' --data-raw '{"jsonrpc": "2.0", "method": "state_getStorage", "params": ["0xcd710b30bd2eab0352ddcc26417aa1941b3c252fcb29d88eff4f3de5de4476c363f5a4efb16ffa83d0070000"], "id": 1}' 2>/dev/null