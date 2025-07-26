#!/bin/bash

set -xe

adb="%(adb)s"
aapt2="%(aapt2)s"

test_host_apk="%(test_host_apk)s"
instrumentation_apk="%(instrumentation_apk)s"
device_id=""

while [[ $# -gt 0 ]]; do
  arg="$1"
  case $arg in
    --test_host_apk=*)
      test_host_apk=("${arg##*=}")
      ;;
    --instrumentation_apk=*)
      instrumentation_apk=("${arg##*=}")
      ;;
    --device_id=*)
      device_id=("${arg##*=}")
      ;;
  esac
  shift
done

if [[ ! -f "$test_host_apk" ]]; then
    echo "Error: $test_host_apk does not exist."
    exit 1
fi
if [[ ! -f "$instrumentation_apk" ]]; then
    echo "Error: $instrumentation_apk does not exist."
    exit 1
fi
if [[ ! -f "$adb" ]]; then
    echo "Error: $adb does not exist."
    exit 1
fi
if [[ ! -f "$aapt2" ]]; then
    echo "Error: $aapt2 does not exist."
    exit 1
fi

device=""
if [[ -n "$device_id" ]]; then
    device="-s $device_id"
fi

test_host_app_id=$($aapt2 dump packagename "$test_host_apk")
instrumentation_app_id=$($aapt2 dump packagename "$instrumentation_apk")

# install both APKs
"$adb" $device install-multi-package "$test_host_apk" "$instrumentation_apk"

# clear the logcat
"$adb" $device logcat -c

# run the instrumentation test
output=$("$adb" $device shell am instrument -r -w $instrumentation_app_id/androidx.test.runner.AndroidJUnitRunner)

log_output=$($adb $device logcat -d)

# uninstall the APKs
"$adb" $device uninstall "$test_host_app_id"
"$adb" $device uninstall "$instrumentation_app_id"

# check if outputs contains errors
if echo "$output" | grep -q "FAILURES"; then
    echo "Instrumentation test failed."
    echo "$output"
    exit 1
fi
