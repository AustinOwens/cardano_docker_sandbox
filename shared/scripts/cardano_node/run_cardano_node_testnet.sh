#!/bin/bash

trap 'echo Signalling for shutdown of Cardano node...; kill -SIGINT "${CARDANO_NODE_PID}"; wait "${CARDANO_NODE_PID}"' SIGTERM SIGINT

cardano-node run \
    --config $CARDANO_CONFIG_PATH/testnet-config.json \
    --database-path $CARDANO_DB_PATH \
    --socket-path $CARDANO_DB_PATH/node.socket \
    --host-addr 172.17.0.2 \
    --port 1337 \
    --topology $CARDANO_CONFIG_PATH/testnet-topology.json > /root/cardano_node_data/node.log 2>&1 &

CARDANO_NODE_PID="$!"

wait "${CARDANO_NODE_PID}"
