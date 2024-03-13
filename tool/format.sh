#!/bin/bash

cd ..

cd floor
dart format .
cd ..

cd floor_annotation
dart  format .
cd ..

cd floor_generator
dart format .
cd ..

cd example
dart format .
