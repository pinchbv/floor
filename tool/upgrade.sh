#!/bin/bash

cd ..

cd floor
flutter packages pub upgrade
cd ..

cd floor_annotation
pub upgrade
cd ..

cd floor_generator
pub upgrade
