#!/bin/sh

PWD=`readlink -f $0`
PWD=`dirname "${PWD}"`
cd ${PWD}

source ./functions.sh

error "data_depth(test)"
