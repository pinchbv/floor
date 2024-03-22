#!/bin/bash

cd ../floor_common
flutter packages pub run build_runner build --delete-conflicting-outputs
