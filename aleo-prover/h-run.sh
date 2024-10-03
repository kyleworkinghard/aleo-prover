#!/usr/bin/env bash

cd `dirname $0`

source colors
source h-manifest.conf
source $CUSTOM_CONFIG_FILENAME

mkdir -p $CUSTOM_LOG_BASENAME
export LD_LIBRARY_PATH=./:$LD_LIBRARY_PATH


./aleo-prover -a $PROVER_AGENT -w $CUSTOM_WALLET  -tls=true -p $CUSTOM_URL 2>&1 | tee --append $CUSTOM_LOG_BASENAME.log