#!/bin/bash

# Make foreach_module script executable, in case it isn't yet
chmod u+x foreach_module.sh

# Run dart format . on every module
./foreach_module.sh 'dart format .'
