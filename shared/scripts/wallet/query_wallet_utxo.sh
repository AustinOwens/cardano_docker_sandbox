#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Usage: query_wallet_utxo.sh WALLET_NAME'
    exit 0
fi

WALLET_NAME=$1

cardano-cli query utxo \
    --testnet-magic 1097911063 \
    --address $(cat ./keys/$WALLET_NAME.addr)
