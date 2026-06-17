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

# Use an array for the ADB command to prevent quoting/word-splitting issues
adb_cmd=("$adb")
if [[ -z "$device_id" ]]; then
    echo "Warning: --device_id not given. Will expect only a single Android device is visible."
else
    adb_cmd+=("-s" "$device_id")
fi


if [[ "$have_test_host_apk" = true ]]; then
    test_host_app_id=$($aapt2 dump packagename "$test_host_apk")
fi
instrumentation_app_id=$($aapt2 dump packagename "$instrumentation_apk")

# --- REUSABLE CLEANUP FUNCTION ---
cleanup_package() {
    local pkg_id="$1"
    "${adb_cmd[@]}" shell am force-stop "$pkg_id" || true
    "${adb_cmd[@]}" shell pm uninstall --user all "$pkg_id" || true
    "${adb_cmd[@]}" uninstall "$pkg_id" || true

    # Verify removal to prevent UID ghosting on subsequent runs
    if "${adb_cmd[@]}" shell pm path "$pkg_id" | grep -q "package:"; then
        echo "Warning: $pkg_id still exists in PackageManager database. Forcing deep clear..."
        "${adb_cmd[@]}" shell pm clear "$pkg_id" || true
        "${adb_cmd[@]}" shell pm uninstall --user all "$pkg_id" || true
    fi
}

# uninstall the previous installations, if they existed. This should avoid errors like "package could not be assigned a valid UID"
if [[ "$have_test_host_apk" = true ]]; then
    cleanup_package "$test_host_app_id"
fi
cleanup_package "$instrumentation_app_id"

# --- INSTALLATION WITH RETRY LOGIC ---
install_success=false
max_retries=3
retry_count=0

# Turn off exit-on-error temporarily so a locked PackageManager doesn't kill the CI job
set +e

while [ $retry_count -lt $max_retries ]; do
    if [[ "$have_test_host_apk" = true ]]; then
        "${adb_cmd[@]}" install-multi-package -r -t -g "$test_host_apk" "$instrumentation_apk"
    else
        "${adb_cmd[@]}" install -r -t -g "$instrumentation_apk"
    fi

    if [ $? -eq 0 ]; then
        install_success=true
        break
    fi

    echo "Install failed (likely PackageManager contention). Retrying in 5s... ($((max_retries - retry_count - 1)) attempts left)"
    sleep 5
    ((retry_count++))
done

# Turn exit-on-error back on
set -e

if [ "$install_success" = false ]; then
    echo "Error: Installation failed after $max_retries attempts. Aborting."
    exit 1
fi

# Give the PackageManager a moment to sync the new UID to the kernel before testing
sleep 1

# clear the logcat
"${adb_cmd[@]}" logcat -c

# run the instrumentation test
output=$("${adb_cmd[@]}" shell am instrument -r -w "$instrumentation_app_id/androidx.test.runner.AndroidJUnitRunner")

log_output=$("${adb_cmd[@]}" logcat -d)

# uninstall the APKs
if [[ "$have_test_host_apk" = true ]]; then
    cleanup_package "$test_host_app_id"
fi
cleanup_package "$instrumentation_app_id"

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
