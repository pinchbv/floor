#!/bin/bash

if [ -z "$PKG" ]; then
  echo -e '\033[31mPKG environment variable must be set!\033[0m'
  exit 1
fi

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

cd $PKG;

EXIT_CODE=0

escapedPath="$(echo $PKG | sed 's/\//\\\//g')"

while (( "$#" )); do
  TASK=$1
  case $TASK in
  dartanalyzer) echo
    pub upgrade || exit $?
    echo -e '\033[1mTASK: dartanalyzer\033[22m'
    echo -e 'dartanalyzer --fatal-infos --fatal-warnings .'
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?
    ;;
  dartfmt) echo
    pub upgrade || exit $?
    echo -e '\033[1mTASK: dartfmt\033[22m'
    echo -e 'dartfmt -n --set-exit-if-changed .'
    dartfmt -n --set-exit-if-changed . || EXIT_CODE=$?
    ;;
  test) echo
    pub upgrade || exit $?
    echo -e '\033[1mTASK: test\033[22m'
    echo -e 'pub run test'
    nohup pub global run coverage:collect_coverage --port=8111 -o coverage.json --resume-isolates --wait-paused &
    dart --pause-isolates-on-exit --enable-vm-service=8111 "test/all_tests.dart" || EXIT_CODE=$?
    pub global run coverage:format_coverage --packages=.packages -i coverage.json --report-on lib --lcov --out lcov.info
    if [ -f "lcov.info" ]
    then
      sed "s/^SF:.*lib/SF:$escapedPath\/lib/g" lcov.info >> "../lcov.info"
      rm lcov.info
    else
      echo "lcov.info file not found"
      EXIT_CODE=1
    fi
    rm -f coverage.json
    ;;
  flutter_analyze) echo
    echo -e '\033[1mTASK: flutter analyze\033[22m'
    echo -e 'flutter analyze'
    flutter analyze || EXIT_CODE=$?
    ;;
  flutter_test) echo
    flutter packages get || exit $?
    echo -e '\033[1mTASK: flutter test\033[22m'
    echo -e 'flutter test'
    flutter test --coverage || EXIT_CODE=$?
    if [ -d "coverage" ]; then
      sed "s/^SF:lib/SF:$escapedPath\/lib/g" coverage/lcov.info >> "../lcov.info"
      rm -rf "coverage"
    fi
    ;;
  *) echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    EXIT_CODE=1
    ;;
  esac

  shift
done

exit $EXIT_CODE
