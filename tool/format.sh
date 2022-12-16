#!/bin/bash

cd ..

cd floor
flutter format .
cd ..

cd floor_annotation
dart  format .
cd ..

cd floor_generator
dart format .
cd ..

cd example
flutter format .
