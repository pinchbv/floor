#!/bin/bash

# Make foreach_module script executable, in case it isn't yet
chmod u+x foreach_module.sh

# Run flutter packages pub get on every module
./foreach_module.sh 'flutter packages pub get'
