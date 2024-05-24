#!/bin/bash

folders=(
  example
  floor
  floor_annotation
  floor_common
  floor_ffi
  floor_generator
)

cd ..

for folder in "${folders[@]}"
do
  cd "$folder" || exit;
  dart format .
  cd ..
done
