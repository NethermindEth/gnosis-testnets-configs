#!/bin/bash

set -eux

: "${RPC_URL:=http://localhost:8545}"

: "${STAKING_CONTRACT:=0x1100000000000000000000000000000000000001}"
: "${BLOCK_REWARD_CONTRACT=0x2000000000000000000000000000000000000001}"

# get staking token address from receipt
STAKING_TOKEN="$(forge create --json --rpc-url "$RPC_URL" \
	--keystore "$OWNER_KEYSTORE" --password "$PASSWORD" \
	--contracts "posdao-contracts/contracts" "posdao-contracts/contracts/ERC677BridgeTokenRewardable.sol:ERC677BridgeTokenRewardable" \
	--constructor-args "STAKE" "STAKE" 18 "1001001" | jq -r '.deployedTo')"

cast send --rpc-url "$RPC_URL" \
	--keystore "$OWNER_KEYSTORE" --password "$PASSWORD" \
	"$STAKING_TOKEN" "setBlockRewardContract(address)" "$BLOCK_REWARD_CONTRACT"

cast send --json --rpc-url "$RPC_URL" \
	--keystore "$OWNER_KEYSTORE" --password "$PASSWORD" \
	"$STAKING_TOKEN" "setStakingContract(address)" "$STAKING_CONTRACT"

cast send --rpc-url "$RPC_URL" \
	--keystore "$OWNER_KEYSTORE" --password "$PASSWORD" \
	"$STAKING_CONTRACT" "setErc677TokenContract(address)" "$STAKING_TOKEN"
