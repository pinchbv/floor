#!/bin/bash

cd ..

cd flat
flutter packages pub get
cd ..

cd flat_annotation
flutter packages pub get
cd ..

cd flat_generator
flutter packages pub get
cd ..

cd example
flutter packages pub get
