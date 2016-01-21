#!/usr/bin/env bash

source ../file.sh

function test_realpath ()
{
    echo "$(cd "$(dirname "$0")" && pwd -P)"
    realpath "../number.sh"
    realpath "tata.sh"
    realpath "../toto/tata.sh"
    realpath "/Users/hgouchet/Documents/RV/bash-primitive/tests/rv.sh"
    realpath
}

test_realpath