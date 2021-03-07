#!/bin/bash

cd ../floor
flutter packages pub run build_runner build --delete-conflicting-outputs --build-filter="test/integration/**/*.g.dart"
