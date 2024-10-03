#!/usr/bin/env bash

cd `dirname $0`

conf=""
conf+="CUSTOM_WALLET=\"$CUSTOM_TEMPLATE\""$'\n'
conf+="CUSTOM_URL=\"$CUSTOM_URL\""$'\n'
conf+="PROVER_AGENT=\"$CUSTOM_USER_CONFIG\""$'\n'


echo "$conf" > $CUSTOM_CONFIG_FILENAME
