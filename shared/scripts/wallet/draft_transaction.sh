#!/bin/bash

if [[ $# -ne 3 ]] ; then
    echo 'Usage:.raw_transaction.sh <FROM_WALLET_NAME> <TO_WALLET_NAME> <ADA_AMOUNT>'
    exit 0
fi

# Make folder to store all our temporary transaction files
TRANSACTION_PATH=./tmp_transaction
mkdir -p $TRANSACTION_PATH

FROM_WALLET_NAME=$1
TO_WALLET_NAME=$2
ADA_AMOUNT=$3

TRANSACTION=$( ./query_wallet_utxo.sh $FROM_WALLET_NAME )
printf "\n$FROM_WALLET_NAME TRANSACTIONS:\n$TRANSACTION\n"

LATEST_TRANSACTION=$( printf "$TRANSACTION" | awk 'NR==3{print $1 "#" $2}' )
printf "\nUSING LATEST TRANSACTION TO GRAB HASH:\n$LATEST_TRANSACTION\n"

CURRENT_BALANCE=$( printf "$TRANSACTION" | awk 'NR==3{print $3}' )
printf "\nCURRENT_BALANCE:\n$CURRENT_BALANCE lovelace\n"

# BUILD RAW TRANSACTION TO CALCULATE FEE
# --tx-in : This specifices the UTXO input that the transaction will use, you 
# can add as many UTXO input as you want by adding multiple --tx-in in the 
# cardano-cli arguments as long as they have a unique TxHash and TxIdx within 
# all your inputs.
# 
# --tx-out : This specifies the target wallet address, assets and quantity to 
# be sent to. You can add as many UTXO outputs as you want as long as the total
#  UTXO input can satisfy the assets and quantity specified by the output.
# 
# --fee : This specifies the fee amount of the transaction in lovelace.
# 
# --out-file : This is the path to the transaction file that will be generated.
cardano-cli transaction build-raw \
    --tx-in $LATEST_TRANSACTION \
    --tx-out $(cat ./keys/$FROM_WALLET_NAME.addr)+0 \
    --tx-out $(cat ./keys/$TO_WALLET_NAME.addr)+0 \
    --alonzo-era \
    --fee 0 \
    --out-file $TRANSACTION_PATH/tx.raw

printf "\nTX RAW:\n$(cat $TRANSACTION_PATH/tx.raw)\n"

# GET ON-CHAIN PROTOCOL PARAMETERS
cardano-cli query protocol-parameters \
    --testnet-magic 1097911063 \
    --out-file $TRANSACTION_PATH/protocol.json

# CALCULATE FEE
# --witness-count : How many signing keys required for this transaction to be 
# valid. If the UTXO input involved in this transaction will only be coming 
# from a single wallet, only 1 key needs to sign the transaction.
#
# --protocol-params-file : We need to pass in the on-chain protocol parameters 
# because the transaction fee calculation results will change depending on 
# them.
cardano-cli transaction calculate-min-fee \
    --tx-body-file $TRANSACTION_PATH/tx.raw \
    --tx-in-count 1 \
    --tx-out-count 2 \
    --witness-count 1 \
    --testnet-magic 1097911063 \
    --protocol-params-file $TRANSACTION_PATH/protocol.json > \
    $TRANSACTION_PATH/fee.txt

FEE=$( cat $TRANSACTION_PATH/fee.txt | awk '{print $1}' )
printf "\nFEE:\n$FEE Lovelace\n"

cardano-cli transaction build-raw \
    --tx-in $LATEST_TRANSACTION \
    --tx-out $(cat ./keys/$FROM_WALLET_NAME.addr)+$(($CURRENT_BALANCE-$ADA_AMOUNT*1000000-$FEE)) \
    --tx-out $(cat ./keys/$TO_WALLET_NAME.addr)+$(($ADA_AMOUNT*1000000)) \
    --alonzo-era \
    --fee $FEE \
    --out-file $TRANSACTION_PATH/tx.raw

printf "\nTRANSACTIONS OUT:"
printf "\n$FROM_WALLET_NAME tx-out: $CURRENT_BALANCE - $ADA_AMOUNT*1000000 - $FEE = $(($CURRENT_BALANCE-$ADA_AMOUNT*1000000-$FEE))"
printf "\n$TO_WALLET_NAME tx-out: $(($ADA_AMOUNT*1000000))\n"

printf "\nTX RAW USING FEE:\n$(cat $TRANSACTION_PATH/tx.raw)\n"

# SIGN THE TRANSACTION
# --signing-key-file : This argument tells the cardano-cli that we will use 
# a specific .skey to sign the transaction.
#
# Now that we have the transaction file, we must sign the transaction in-order 
# to prove that we are the owner of the input UTXO that was used.
cardano-cli transaction sign \
    --tx-body-file $TRANSACTION_PATH/tx.raw \
    --signing-key-file ./keys/$FROM_WALLET_NAME.skey \
    --testnet-magic 1097911063 \
    --out-file $TRANSACTION_PATH/tx.signed

printf "\nTX SIGNED: $(cat $TRANSACTION_PATH/tx.signed)\n"

printf "\nFINAL BALANCE AFTER TRANSACTION IS SUBMITTED:\n"

echo "$FROM_WALLET_NAME:" \
"$(($CURRENT_BALANCE-$FEE-$(($ADA_AMOUNT*1000000)))) Lovelace"

printf "\nRUN THE FOLLOWING TO SUBMIT THIS TRANSACTION TO THE BLOCKCHAIN:\n" 
printf "./submit_transaction.sh $TRANSACTION_PATH/tx.signed\n\n"
