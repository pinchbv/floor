#!/bin/bash

cd ..

cd floor
flutter packages pub get
cd ..

cd floor_annotation
flutter packages pub get
cd ..

cd floor_generator
flutter packages pub get
