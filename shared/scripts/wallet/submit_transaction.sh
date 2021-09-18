#!/bin/bash

if [[ $# -ne 1 ]] ; then
    echo 'Usage: submit_transaction.sh <TX.SIGNED LOCATION>'
    exit 0
fi

TX_SIGNED_LOCATION=$1

# SUBMIT SIGNED TRANSACTION TO THE BLOCKCHAIN
cardano-cli transaction submit \
    --tx-file $TX_SIGNED_LOCATION \
    --testnet-magic 1097911063 
