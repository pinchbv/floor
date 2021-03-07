#!/bin/bash

cd ../floor
flutter packages pub run build_runner build --delete-conflicting-outputs
# TODO #375 ignore mock files --build-filter=test/integration/autoincrement/autoinc_test.dart
