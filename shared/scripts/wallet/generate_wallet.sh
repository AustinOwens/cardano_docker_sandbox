#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Usage: generate_wallet.sh WALLET_NAME'
    exit 0
fi

WALLET_NAME=$1

echo "Generating $WALLET_NAME wallet..."

# MAKE KEYS DIRECTORY
mkdir -p ./keys

# GENERATE PAYMENT KEY-PAIR
# --verification-key-file : points to the path where you want to save the vkey
# file
# --signing-key-file : points to the path where you want to save the skey file
#
# The .vkey is a public verification key used to derive a Cardano wallet 
# address, a wallet address is basically the hash string value that you 
# share to other users to provide them a way to send ADA / tADA or other 
# assets in the Cardano blockchain into your wallet.
#
# The .skey is a private signing key used to sign/approve transactions for your
# wallet. As you can imagine, it is very important to not expose this file to 
# the public and must be kept secure.
cardano-cli address key-gen \
	--verification-key-file ./keys/$WALLET_NAME.vkey \
	--signing-key-file ./keys/$WALLET_NAME.skey

# GENERATE WALLET ADDRESS
# --payment-verification-key-file : The path to the vkey file to be used for 
# the derivation.
# --out-file : The path to save the wallet address file.
# --testnet-magic : The NetworkMagic of the network that where you want to 
# use the wallet address.
#
# The .addr file contains the derived wallet address from your vkey file. 
# It should look something like this:
#
# addr_test1vz95zjvtwm9u9mc83uzsfj55tzwf99fgeyt3gmwm9gdw2xgwrvsa5
#
# mainnet addresses are prefixed with the string value addr1.
# testnet addresses are prefixed with the string value addr_test1.
cardano-cli address build \
    --payment-verification-key-file ./keys/$WALLET_NAME.vkey \
    --out-file ./keys/$WALLET_NAME.addr \
    --testnet-magic 1097911063

echo "Done."
