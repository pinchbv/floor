#!/bin/bash

cd ..

cd floor
flutter packages pub upgrade
cd ..

cd floor_annotation
flutter packages pub upgrade
cd ..

cd floor_generator
flutter packages pub upgrade
cd ..

cd example
flutter packages pub upgrade
