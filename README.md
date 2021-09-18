# Cardano Docker Sandbox
A bare-bones sandbox for developing with Cardano tools/utilities. Includes latest code from Alonzo fork.

THIS IS ONLY A SANDBOX AND NOT MEANT FOR PRODUCTION USE

# What's Included
Currently, only `cardano-node`, `cardano-cli`, and `cardano-wallet` utilities are included. I plan on adding more Cardano utilities soon.

# Dependencies 
[Docker 20.10.8+](https://docs.docker.com/get-docker/)

# How to Install and Run
**Step 1:**

```
git clone https://github.com/AustinOwens/cardano_docker_sandbox.git
```

**Step 2:**

```
cd cardano_docker_sandbox
```

**Step 3:**

```
./up.sh
```

That's it!

# How It Works
As the Docker container starts building, it will fetch the official Cardano source code that contain various tools/utilities for interacting and making transactions with the blockchain. 

When the container starts, you will be thrown into the containers bash shell and a cardano node instance will automatically start syncing to the **Testnet** blockchain in the background (it can take a while to fully sync with the blockchain). The node instance redirects its output to a node.txt file. If you want to see the cardano node output, run the following command:

```
tail -f /root/cardano_node_data/node.log
```

While still in the container, you can ran the Cardano utilities like you'd expect. For example:

```
cardano-cli query tip --testnet-magic 1097911063
```

Output:
```
{
    "epoch": 155,
    "hash": "17d4d085a6e9f320c7c7f667528669ba2922c20cf96c2ad1f43d730bdaa7687b",
    "slot": 37008207,
    "block": 2903536,
    "era": "Alonzo",
    "syncProgress": "100.00"
}
```

If you `exit` from the bash shell from within the container, the container will continue to run with the node instance still actively syncing with the blockchain.

From your host you can call helper scripts like this (I plan on adding more to this folder):

```
docker compose exec node /root/scripts/blockchain_status/query_tip.sh
```

Output:
```
{
    "epoch": 155,
    "hash": "17d4d085a6e9f320c7c7f667528669ba2922c20cf96c2ad1f43d730bdaa7687b",
    "slot": 37008207,
    "block": 2903536,
    "era": "Alonzo",
    "syncProgress": "100.00"
}
```

or use the Cardano utilities directly like this:

```
docker compose exec node /root/.local/bin/cardano-cli query tip --testnet-magic 1097911063
```

Output:
```
{
    "epoch": 155,
    "hash": "17d4d085a6e9f320c7c7f667528669ba2922c20cf96c2ad1f43d730bdaa7687b",
    "slot": 37008207,
    "block": 2903536,
    "era": "Alonzo",
    "syncProgress": "100.00"
}
```

To stop the container, run the following command from host: 

```
./down.sh
```

If the container is stopped, the Cardano node exits gracefully. When the docker container starts running again, it will resume where it left off when syncing with the blockchain. 

This is an ephemeral container, meaning that the container can be stopped, destroyed, rebuilt and/or replaced while still maintaining its state and proper functionality from the last time the container was ran. It does this by storing the database (that the Cardano node builds up while syncing to the blockchain) to the mounted 'shared' directory between the host and the container. That way if the container is destroyed, another one can come along and take its place right where it left off.

The Dockerfile primarily follows the installation instructions from [Cardano's Developer Portal](https://developers.cardano.org/docs/get-started/installing-cardano-node) with some subtle differences (e.g. getting more recent source code from the official Cardano repos).


# Useful Scripts
## /root/scripts/blockchain_status/query_tip.sh

Queries the tip of the blockchain (as shown in above examples). 

## /root/scripts/wallet/generate_wallet.sh `<WALLET_NAME>`

Generates a wallet for you (creates a `<WALLET_NAME>`.addr, `<WALLET_NAME>`.skey, and `<WALLET_NAME>`.vkey files).

Example:

```
root@6418f6038a32:~/scripts/wallet# ls
generate_wallet.sh  query_wallet_utxo.sh
root@6418f6038a32:~/scripts/wallet# ./generate_wallet.sh my_wallet
Generating my_wallet wallet...
Done.
root@6418f6038a32:~/scripts/wallet# ls
generate_wallet.sh  keys  query_wallet_utxo.sh
root@6418f6038a32:~/scripts/wallet# ls keys/
my_wallet.addr  my_wallet.skey  my_wallet.vkey
root@6418f6038a32:~/scripts/wallet# cat keys/my_wallet.addr
addr_test1vqe4uxcyghw65v4f4k3j4uucluumfkjhj2ah2rwmazv2kuqy9uz5r
```


## /root/scripts/wallet/query_wallet_utxo.sh `<WALLET_NAME>`

Queries the wallet UTXO (Unspent Transaction Output).

Example:

```
root@6418f6038a32:~/scripts/wallet# ./query_wallet_utxo.sh my_wallet
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
root@6418f6038a32:~/scripts/wallet# ./query_wallet_utxo.sh test_wallet_1
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
5bb08d2c2c2eb71acd261ebcb7899011f4cc97a0284795cbb0a9fcde935eb752     0        1000000000 lovelace + TxOutDatumHashNone
```


## /root/scripts/blockchain_status/query_protocol_params.sh

Queries protocol parameters.

Example:

```
root@e90b732c4887:~/scripts/blockchain_status# ./query_protocol_params.sh
{
    "txFeePerByte": 44,
    "minUTxOValue": null,
    "stakePoolDeposit": 500000000,
    "utxoCostPerWord": 34482,
    "decentralization": 0,
    "poolRetireMaxEpoch": 18,
    "extraPraosEntropy": null,
    "collateralPercentage": 150,
    "stakePoolTargetNum": 500,
    "maxBlockBodySize": 65536,
    "maxTxSize": 16384,
    "treasuryCut": 0.2,
    "minPoolCost": 340000000,
    "maxCollateralInputs": 3,
    "maxValueSize": 5000,
    "maxBlockExecutionUnits": {
        "memory": 50000000,
        "steps": 40000000000
    },
    "maxBlockHeaderSize": 1100,
    "costModels": {
        "PlutusScriptV1": {
            "sha2_256-memory-arguments": 4,
            "equalsString-cpu-arguments-constant": 1000,
            "cekDelayCost-exBudgetMemory": 100,
            "lessThanEqualsByteString-cpu-arguments-intercept": 103599,
            "divideInteger-memory-arguments-minimum": 1,
            "appendByteString-cpu-arguments-slope": 621,
            "blake2b-cpu-arguments-slope": 29175,

                  .
                  .
                  .

```

# Have a feature request or found a bug?

Please use the GitHub issue tracker to let me know.
