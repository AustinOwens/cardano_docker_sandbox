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
git clone https://github.com/AustinOwens/cardano_sandbox.git
```

**Step 2:**

```
cd cardano_docker_sandbox
```

**Step 3:**

```
./up
```

That's it!

# How It Works
As the Docker container starts building, it will fetch the official Cardano source code that contain various tools/utilities for interacting and making transactions with the blockchain. 

When the container starts, you will be thrown into the containers bash shell and a cardano node instance will automatically start syncing to the **Testnet** blockchain in the background (it can take a while to fully sync with the blockchain). The node instance redirects its output to a node.txt file. If you want to see the cardano node output, run the following command:

```
tail -f /root/node.txt
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
docker compose exec node /root/cardano-data/scripts/query_tip.sh
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
./down
```

If the container is stopped, the Cardano node exits gracefully. When the docker container starts running again, it will resume where it left off when syncing with the blockchain. 

This is an ephemeral container, meaning that the container can be stopped, destroyed, rebuilt and/or replaced while still maintaining its state and proper functionality from the last time the container was ran. It does this by storing the database (that the Cardano node builds up while syncing to the blockchain) to the mounted 'shared' directory between the host and the container. That way if the container is destroyed, another one can come along and take its place right where it left off.

The Dockerfile primarily follows the installation instructions from [Cardano's Developer Portal](https://developers.cardano.org/docs/get-started/installing-cardano-node) with some subtle differences (e.g. getting more recent source code from the official Cardano repos).


# Have a feature request or found a bug?

Please use the GitHub issue tracker to let me know.
