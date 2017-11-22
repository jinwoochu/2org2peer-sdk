#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

# Shut down the Docker containers for the system tests.
chaincode=$(docker ps -f name=dev-peer* -q)

if [ "$chaincode" != "" ]; then
 docker rm -f $chaincode	
fi

docker-compose -f docker-compose.yml kill && docker-compose -f docker-compose.yml down
rm -rf docker-compose.yml


# remove the local state
rm -f ~/.hfc-key-store/*

# remove chaincode docker images

image=$(docker images dev-* -q)

if [ "$images" != "" ]; then
 docker rmi -f $images
fi

# Your system is now clean
