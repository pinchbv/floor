#!/bin/bash

# This script lists all Flutter module folders in this project. Next it iterates over them
# and runs the passed in command in every one of those folders.
# Example usage: ./foreach_module.sh 'dart analyze .'

if [ $# -eq 0 ]; then
  echo "No arguments supplied. Pass the desired command as a string argument.
  For example: ./foreach_module.sh 'dart analyze .'"
fi

# All Flutter module folders
folders=(
  example
  floor
  floor_annotation
  floor_common
  floor_ffi
  floor_generator
)

# Navigate up one level from where this script lives
cd ..

# Iterate over the modules
for folder in "${folders[@]}"; do
  # Navigate to the module folder, or continue to the next one if that fails
  cd "$folder" || continue;
  #  Run the passed in command
  $1
  # Navigate back up to the root
  cd ..
done
