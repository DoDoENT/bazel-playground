#!/bin/bash

set -xe

adb="%(adb)s"
# handle the case when script is not invoked by bazel rule
# if [[ ! -f "$adb" ]]; then
#     if [[ -z "$ANDROID_HOME" ]]; then
#         echo "Error: ANDROID_HOME is not set."
#         exit 1
#     fi
#     adb="$ANDROID_HOME/platform-tools/adb"
# fi
apkanalyzer="$ANDROID_HOME/cmdline-tools/latest/bin/apkanalyzer"

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

device=""
if [[ -n "$device_id" ]]; then
    device="-s $device_id"
fi

test_host_app_id="%(test_host_app_id)s"

# handle the case when script is not invoked by bazel rule
# if [[ "$test_host_app_id" == "%(test_host_app_id)s" ]]; then
#     test_host_app_id=$($apkanalyzer manifest application-id "$test_host_apk")
# fi

instrumentation_app_id="%(instrumentation_app_id)s"

# handle the case when script is not invoked by bazel rule
# if [[ "$instrumentation_app_id" == "%(instrumentation_app_id)s" ]]; then
#     instrumentation_app_id=$($apkanalyzer manifest application-id "$instrumentation_apk")
# fi

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
