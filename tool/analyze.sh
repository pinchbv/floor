#!/bin/bash

cd ..

cd floor
flutter analyze
cd ..

cd floor_annotation
dart analyze --fatal-infos --fatal-warnings .
cd ..

cd floor_generator
dart analyze --fatal-infos --fatal-warnings .
cd ..

cd example
flutter analyze
