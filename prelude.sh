#!/bin/bash

set -e

BRIDGES_REPO_PATH=../parity-bridges-common
OPEN_ETHEREUM_REPO_PATH=../parity

SKIP_WASM_BUILD=1
DISABLE_RIALTO_POA=1
DISABLE_WESTEND_TO_MILLAU=1
GENERATE_LARGE_MESSAGES=
USE_COMPLEX_MILLAU_RIALTO_RELAY=1
# following two variables must be changed at once: either to ("", "debug") or to ("--release", "release")
BUILD_TYPE=
BUILD_FOLDER=debug
