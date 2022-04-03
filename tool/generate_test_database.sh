#!/bin/bash

cd ../flat
flutter packages pub run build_runner build --delete-conflicting-outputs
