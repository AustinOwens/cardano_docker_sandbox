#!/bin/bash

# Check to see if anything is in /mnt/shared. If there is, make all content in 
# /mnt/shared/ symbolically link to /root for quicker development
[ "$(ls -A /mnt/shared)" ] && ln -sf /mnt/shared/* /root

# Execute CMD in Dockerfile or user specified command passed in over 
# 'docker run' or configured in docker compose yaml file.
exec "$@"
