#!/bin/bash

cd ../example
flutter packages pub run build_runner build --delete-conflicting-outputs

cd ../floor/example
flutter packages pub run build_runner build --delete-conflicting-outputs
