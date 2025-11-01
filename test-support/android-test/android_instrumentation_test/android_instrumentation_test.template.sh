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

# test_host_apk is not mandatory - we also want to support running tests that are entirely in the instrumentation APK
have_test_host_apk=true
if [[ ! -f "$test_host_apk" ]]; then
    have_test_host_apk=false
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

if [[ -z "$device_id" ]]; then
    echo "Warning: --device_id not given. Will use ADB without the '-s <device_id>' parameter, thus expecting that only single Android device is visible."
    device=""
else
    device="-s $device_id"
fi


if [[ "$have_test_host_apk" = true ]]; then
    test_host_app_id=$($aapt2 dump packagename "$test_host_apk")
fi
instrumentation_app_id=$($aapt2 dump packagename "$instrumentation_apk")

# install both APKs
if [[ "$have_test_host_apk" = true ]]; then
    "$adb" $device install-multi-package -r -t -g "$test_host_apk" "$instrumentation_apk"
else
    "$adb" $device install -r -t -g "$instrumentation_apk"
fi

# clear the logcat
"$adb" $device logcat -c

# run the instrumentation test
output=$("$adb" $device shell am instrument -r -w $instrumentation_app_id/androidx.test.runner.AndroidJUnitRunner)

log_output=$($adb $device logcat -d)

# uninstall the APKs
if [[ "$have_test_host_apk" = true ]]; then
    "$adb" $device uninstall "$test_host_app_id"
fi
"$adb" $device uninstall "$instrumentation_app_id" || true # Ignore if uninstall fails, as some devices immediately remove the app after the test run

# check if outputs contains errors
if echo "$output" | grep -q "FAILURES"; then
    echo "Instrumentation test failed: has test failures."
    echo "$output"
    exit 1
fi
if echo "$log_output" | grep "Fatal signal" | grep -v -q "Fatal signal 31"; then
    echo "Instrumentation test failed: has fatal signals in logcat."
    echo "$output"
    exit 1
fi
