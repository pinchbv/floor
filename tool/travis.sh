#!/bin/bash

if [ -z "$PKG" ]; then
  echo -e '\033[31mPKG environment variable must be set!\033[0m'
  exit 1
fi

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

#escapedPath="$(echo $PWD | sed 's/\//\\\//g')"
escapedPath="$(echo $PWD)"
# TODO remove this
echo "Escaped path: $escapedPath"

pushd $PKG

EXIT_CODE=0

#escapedPathAfter="$(echo $PWD | sed 's/\//\\\//g')"
escapedPathAfter="$(echo $PWD)"
echo "Path after: $escapedPathAfter"


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
    if [ -f "lcov.info" ]; then
      # combine line coverage info from package tests to a common file
#      sed "s/^SF:.*lib/SF:$escapedPathAfter\/lib/g" lcov.info >> ${escapedPath}/lcov.info
      lcov.info >> ${escapedPath}/lcov.info
      rm lcov.info
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
      # combine line coverage info from package tests to a common file
#      sed "s/^SF:lib/SF:$escapedPathAfter\/lib/g" coverage/lcov.info >> ${escapedPath}/lcov.info
      coverage/lcov.info >> ${escapedPath}/lcov.info
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
