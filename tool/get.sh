#!/bin/bash

cd ..

cd floor
flutter packages pub get
cd ..

cd floor_annotation
pub get
cd ..

cd floor_generator
pub get
