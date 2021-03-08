#!/bin/bash

cd ..

cd floor
flutter analyze
cd ..

cd floor_annotation
dartanalyzer --fatal-infos --fatal-warnings .
cd ..

cd floor_generator
dartanalyzer --fatal-infos --fatal-warnings .
cd ..

cd example
flutter analyze
