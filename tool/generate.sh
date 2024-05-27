#!/bin/bash

# Make foreach_module script executable, in case it isn't yet
chmod u+x foreach_module.sh

# Run build_runner on every module
./foreach_module.sh 'dart run build_runner build --delete-conflicting-outputs'
