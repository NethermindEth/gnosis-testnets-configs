#!/bin/bash

set -eux

DIR=$1 # first argument should be network directory

source "$DIR/spec.env"

: "${KEYSTORE:=$DIR/keystore}"

: "${RPC_URL:=http://localhost:8545}"

: "${STAKING_CONTRACT:=0x1100000000000000000000000000000000000001}"
: "${BLOCK_REWARD_CONTRACT=0x2000000000000000000000000000000000000001}"

# get staking token address from receipt
STAKING_TOKEN="$(forge create --json --rpc-url "$RPC_URL" \
	--keystore "$KEYSTORE" --password "$PASSWORD" --from "$OWNER" \
	--contracts "posdao-contracts/contracts" "posdao-contracts/contracts/ERC677BridgeTokenRewardable.sol:ERC677BridgeTokenRewardable" \
	--constructor-args "STAKE" "STAKE" 18 "1001001" | jq -r '.deployedTo')"

cast send --rpc-url "$RPC_URL" \
	--keystore "$KEYSTORE" --password "$PASSWORD" --from "$OWNER" \
	"$STAKING_TOKEN" "setBlockRewardContract(address)" "$BLOCK_REWARD_CONTRACT"

cast send --json --rpc-url "$RPC_URL" \
	--keystore "$KEYSTORE" --password "$PASSWORD" --from "$OWNER" \
	"$STAKING_TOKEN" "setStakingContract(address)" "$STAKING_CONTRACT"

cast send --rpc-url "$RPC_URL" \
	--keystore "$KEYSTORE" --password "$PASSWORD" --from "$OWNER" \
	"$STAKING_CONTRACT" "setErc677TokenContract(address)" "$STAKING_TOKEN"
