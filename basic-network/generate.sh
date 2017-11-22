#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=mychannel

# remove previous crypto material and config transactions
rm -fr config/*
sudo rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi


## change PRIVATE KEY
# Copy the template to the file that will be modified to add the private key
cp docker-compose-template.yml docker-compose.yml

# The next steps will replace the template's contents with the
# actual values of the private key file names for the CA.
CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/org1.example.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed -i "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yml

CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/org2.example.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed -i "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yml



# generate genesis block for orderer
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi





# generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./config/channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
