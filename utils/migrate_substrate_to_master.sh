#!/bin/bash

# One-liner to migrate from Substrate 2.0/0.8 to given Substrate commit
# Usage: ./migrate_substrate_to_master.sh 31733d5075bdba62df00975df0463a56fadbcaa1
set -xeu

COMMIT=$1

PREFIXES=("sp-" "sc-" "frame-" "pallet-" "substrate-")
for PREFIX in "${PREFIXES[@]}"
do
	WITH_FEATURES_REGEX="s/^$PREFIX(.*)(\s*)=(.*)version = \"(0\.8|2\.0)\"(.*)/$PREFIX\1\2=\3\git = \"https:\/\/github.com\/paritytech\/substrate.git\", rev = \"$COMMIT\" \5/g"
	find . -type f -name 'Cargo.toml' -exec sed -r -i -e "$WITH_FEATURES_REGEX" {} \;

	PLAIN_REGEX="s/^$PREFIX(.*)(\s*)=(\s*)\"(0\.8|2\.0)\"/$PREFIX\1\2=\3\{ git = \"https:\/\/github.com\/paritytech\/substrate.git\", rev = \"$COMMIT\" \}/g"
	find . -type f -name 'Cargo.toml' -exec sed -r -i -e "$PLAIN_REGEX" {} \;
done
