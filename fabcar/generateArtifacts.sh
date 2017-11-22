#!/bin/bash
#
# Copyright jinwoochu
# email : chaindevchu@gmail.com or cjw0672@naver.com
# If you have any questions, please email me
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

starttime=$(date +%s)

# launch network; create channel and join peer to channel
cd ../basic-network
./generate.sh

printf "\nTotal setup execution time : $(($(date +%s) - starttime)) secs ...\n\n\n"
