#!/usr/bin/env bash

set -xeuo pipefail

adb="%(adb)s"
aapt2="%(aapt2)s"
emulator="%(emulator)s"
mksd="%(mksd)s"
test_host_apk="%(test_host_apk)s"
instrumentation_apk="%(instrumentation_apk)s"
instrumentation_runner="%(instrumentation_runner)s"
system_image_source_properties="%(system_image_source_properties)s"
device_id=""
emulator_port=""
emulator_port_explicit=false

while [[ $# -gt 0 ]]; do
  arg="$1"
  case "$arg" in
    --device_id=*)
      device_id="${arg##*=}"
      ;;
    --emulator_port=*)
      emulator_port="${arg##*=}"
      emulator_port_explicit=true
      ;;
    --instrumentation_apk=*)
      instrumentation_apk="${arg##*=}"
      ;;
    --test_host_apk=*)
      test_host_apk="${arg##*=}"
      ;;
  esac
  shift
done

resolve_runfile() {
  local path="$1"
  if [[ -z "$path" ]]; then
    return 1
  elif [[ -e "$path" ]]; then
    printf '%s\n' "$path"
  elif [[ -n "${RUNFILES_DIR:-}" && -e "${RUNFILES_DIR}/$path" ]]; then
    printf '%s\n' "${RUNFILES_DIR}/$path"
  elif [[ -n "${TEST_SRCDIR:-}" && -n "${TEST_WORKSPACE:-}" && -e "${TEST_SRCDIR}/${TEST_WORKSPACE}/$path" ]]; then
    printf '%s\n' "${TEST_SRCDIR}/${TEST_WORKSPACE}/$path"
  elif [[ -n "${TEST_SRCDIR:-}" && -e "${TEST_SRCDIR}/$path" ]]; then
    printf '%s\n' "${TEST_SRCDIR}/$path"
  else
    echo "missing runfile: $path" >&2
    exit 1
  fi
}

adb="$(resolve_runfile "$adb")"
aapt2="$(resolve_runfile "$aapt2")"
emulator="$(resolve_runfile "$emulator")"
mksd="$(resolve_runfile "$mksd")"
instrumentation_apk="$(resolve_runfile "$instrumentation_apk")"
system_image_source_properties="$(resolve_runfile "$system_image_source_properties")"
if [[ -n "$test_host_apk" ]]; then
  test_host_apk="$(resolve_runfile "$test_host_apk")"
fi

system_image_dir="$(cd "$(dirname "$system_image_source_properties")" && pwd)"
test_tmpdir="${TEST_TMPDIR:-$(mktemp -d)}"
port_lock_root="${ANDROID_EMULATOR_PORT_LOCK_ROOT:-/tmp/bazel-android-emulator-ports}"
adb_server_port="${ADB_SERVER_PORT:-}"
modem_simulator_port=""
emulator_pid=""
allocated_port_locks=()
adb_cmd=()

is_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

is_port_available() {
  local port="$1"
  if ! is_integer "$port"; then
    return 1
  fi
  if (echo >"/dev/tcp/127.0.0.1/${port}") >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

reserve_port() {
  local port="$1"
  local lock_dir="${port_lock_root}/${port}.lock"
  mkdir -p "$port_lock_root"
  if mkdir "$lock_dir" 2>/dev/null; then
    printf '%s\n' "$$" >"${lock_dir}/pid"
    allocated_port_locks+=("$lock_dir")
    return 0
  fi
  if [[ -f "${lock_dir}/pid" ]]; then
    local lock_pid
    lock_pid="$(cat "${lock_dir}/pid")"
    if is_integer "$lock_pid" && ! kill -0 "$lock_pid" >/dev/null 2>&1; then
      rm -f "${lock_dir}/pid"
      rmdir "$lock_dir" >/dev/null 2>&1 || true
      if mkdir "$lock_dir" 2>/dev/null; then
        printf '%s\n' "$$" >"${lock_dir}/pid"
        allocated_port_locks+=("$lock_dir")
        return 0
      fi
    fi
  fi
  return 1
}

release_port() {
  local port="$1"
  local lock_dir="${port_lock_root}/${port}.lock"
  local kept_locks=()
  local existing_lock
  rm -f "${lock_dir}/pid"
  rmdir "$lock_dir" >/dev/null 2>&1 || true
  for existing_lock in "${allocated_port_locks[@]}"; do
    if [[ "$existing_lock" != "$lock_dir" ]]; then
      kept_locks+=("$existing_lock")
    fi
  done
  allocated_port_locks=("${kept_locks[@]}")
}

release_port_locks() {
  local lock_dir
  for lock_dir in "${allocated_port_locks[@]}"; do
    rm -f "${lock_dir}/pid"
    rmdir "$lock_dir" >/dev/null 2>&1 || true
  done
}

choose_adb_server_port() {
  local offset port
  # Search the ephemeral range first. If a Bazel sandbox does not isolate host
  # networking, the lock prevents this script from racing with another copy.
  for offset in $(seq 0 16383); do
    port=$((49152 + (($$ + offset) % 16384)))
    if is_port_available "$port" && reserve_port "$port"; then
      adb_server_port="$port"
      return
    fi
  done
  echo "Failed to find an available adb server port." >&2
  exit 1
}

choose_modem_simulator_port() {
  local offset port
  for offset in $(seq 0 16383); do
    port=$((49152 + (($$ + 4096 + offset) % 16384)))
    if is_port_available "$port" && reserve_port "$port"; then
      modem_simulator_port="$port"
      return
    fi
  done
  echo "Failed to find an available emulator modem simulator port." >&2
  exit 1
}

choose_emulator_port() {
  local requested="$1"
  local port offset adb_port
  if [[ -n "$requested" ]]; then
    if ! is_integer "$requested" || ((requested % 2 != 0 || requested < 5554 || requested > 5584)); then
      echo "Invalid --emulator_port. Expected an even integer in the 5554..5584 range, got: $requested" >&2
      exit 1
    fi
    adb_port=$((requested + 1))
    if is_port_available "$requested" && is_port_available "$adb_port" && reserve_port "$requested"; then
      if reserve_port "$adb_port"; then
        emulator_port="$requested"
        return
      fi
      release_port "$requested"
    fi
    echo "Requested emulator port pair is not available: ${requested}/${adb_port}" >&2
    exit 1
  fi
  for offset in $(seq 0 15); do
    port=$((5554 + 2 * (($$ + offset) % 16)))
    adb_port=$((port + 1))
    if is_port_available "$port" && is_port_available "$adb_port" && reserve_port "$port"; then
      if reserve_port "$adb_port"; then
        emulator_port="$port"
        return
      fi
      release_port "$port"
    fi
  done
  echo "Failed to find an available emulator port pair." >&2
  exit 1
}

print_emulator_log() {
  if [[ -f "${test_tmpdir}/emulator.log" ]]; then
    tail -200 "${test_tmpdir}/emulator.log" >&2
  fi
}

cleanup_package() {
  local pkg_id="$1"
  "${adb_cmd[@]}" shell am force-stop "$pkg_id" >/dev/null 2>&1 || true
  "${adb_cmd[@]}" shell pm uninstall --user all "$pkg_id" >/dev/null 2>&1 || true
  "${adb_cmd[@]}" uninstall "$pkg_id" >/dev/null 2>&1 || true

  if "${adb_cmd[@]}" shell pm path "$pkg_id" 2>/dev/null | grep -q "package:"; then
    echo "Warning: $pkg_id still exists in PackageManager database. Forcing deep clear..." >&2
    "${adb_cmd[@]}" shell pm clear "$pkg_id" >/dev/null 2>&1 || true
    "${adb_cmd[@]}" shell pm uninstall --user all "$pkg_id" >/dev/null 2>&1 || true
  fi
}

cleanup() {
  set +e
  if ((${#adb_cmd[@]} == 0)); then
    release_port_locks
    return
  fi
  if [[ -n "${instrumentation_app_id:-}" ]]; then
    cleanup_package "$instrumentation_app_id"
  fi
  if [[ -n "${test_host_app_id:-}" ]]; then
    cleanup_package "$test_host_app_id"
  fi
  if [[ -n "$emulator_pid" ]]; then
    "${adb_cmd[@]}" emu kill >/dev/null 2>&1
    wait "$emulator_pid" >/dev/null 2>&1
  fi
  if [[ -n "$adb_server_port" ]]; then
    env ADB_SERVER_PORT="$adb_server_port" "$adb" kill-server >/dev/null 2>&1
  fi
  release_port_locks
}
trap cleanup EXIT

source_property() {
  sed -n "s/^$1=//p" "$system_image_source_properties" | head -1
}

if [[ -z "$adb_server_port" ]]; then
  choose_adb_server_port
elif ! is_integer "$adb_server_port"; then
  echo "Invalid ADB_SERVER_PORT: $adb_server_port" >&2
  exit 1
fi
choose_modem_simulator_port

if [[ -z "$device_id" ]]; then
  if [[ "$emulator_port_explicit" == true ]]; then
    choose_emulator_port "$emulator_port"
  else
    choose_emulator_port ""
  fi
  device_id="emulator-${emulator_port}"
  sdcard="${test_tmpdir}/sdcard.img"
  "$mksd" 64M "$sdcard" >/dev/null
  system_image_abi="$(source_property "SystemImage.Abi")"
  api_level="$(source_property "AndroidVersion.ApiLevel")"
  tag_id="$(source_property "SystemImage.TagId")"
  tag_display="$(source_property "SystemImage.TagDisplay")"
  case "$system_image_abi" in
    arm64-v8a)
      cpu_arch="arm64"
      ;;
    armeabi-v7a)
      cpu_arch="arm"
      ;;
    *)
      cpu_arch="$system_image_abi"
      ;;
  esac

  avd_name="hermetic-emulator-test"
  avd_home="${test_tmpdir}/avd"
  avd_dir="${avd_home}/${avd_name}.avd"
  mkdir -p "$avd_dir"
  cat >"${avd_home}/${avd_name}.ini" <<EOF
avd.ini.encoding=UTF-8
path=$avd_dir
path.rel=avd/${avd_name}.avd
target=android-${api_level}
EOF
  cat >"${avd_dir}/config.ini" <<EOF
AvdId=$avd_name
PlayStore.enabled=false
abi.type=$system_image_abi
avd.ini.displayname=$avd_name
disk.dataPartition.size=2048M
hw.cpu.arch=$cpu_arch
hw.cpu.ncore=2
hw.gpu.enabled=yes
hw.gpu.mode=swiftshader_indirect
hw.keyboard=yes
hw.lcd.density=420
hw.lcd.height=1920
hw.lcd.width=1080
hw.ramSize=2048
image.sysdir.1=${system_image_dir}/
runtime.network.latency=none
runtime.network.speed=full
sdcard.path=$sdcard
skin.dynamic=yes
tag.display=$tag_display
tag.id=$tag_id
target=android-${api_level}
EOF

  env \
    ADB_SERVER_PORT="$adb_server_port" \
    ANDROID_AVD_HOME="$avd_home" \
    ANDROID_SDK_HOME="${test_tmpdir}/sdk-home" \
    "$emulator" \
      -avd "$avd_name" \
      -port "$emulator_port" \
      -no-window \
      -no-audio \
      -no-boot-anim \
      -no-metrics \
      -no-snapshot \
      -no-snapshot-save \
      -wipe-data \
      -modem-simulator-port "$modem_simulator_port" \
      -gpu swiftshader_indirect \
      >"${test_tmpdir}/emulator.log" 2>&1 &
  emulator_pid="$!"
fi

adb_cmd=(env ADB_SERVER_PORT="$adb_server_port" "$adb" -s "$device_id")

device_connected=false
for _ in $(seq 1 90); do
  if "${adb_cmd[@]}" get-state >/dev/null 2>&1; then
    device_connected=true
    break
  fi
  if [[ -n "$emulator_pid" ]] && ! kill -0 "$emulator_pid" >/dev/null 2>&1; then
    echo "Emulator exited before adb connected." >&2
    print_emulator_log
    exit 1
  fi
  sleep 1
done
if [[ "$device_connected" != true ]]; then
  echo "Emulator did not connect to adb." >&2
  print_emulator_log
  exit 1
fi

boot_completed=false
for _ in $(seq 1 180); do
  if [[ "$("${adb_cmd[@]}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
    boot_completed=true
    break
  fi
  sleep 1
done
if [[ "$boot_completed" != true ]]; then
  echo "Emulator did not finish booting." >&2
  print_emulator_log
  exit 1
fi

package_manager_ready=false
for _ in $(seq 1 60); do
  if "${adb_cmd[@]}" shell pm list packages >/dev/null 2>&1; then
    package_manager_ready=true
    break
  fi
  sleep 1
done
if [[ "$package_manager_ready" != true ]]; then
  echo "Emulator PackageManager did not become ready." >&2
  print_emulator_log
  exit 1
fi

have_test_host_apk=false
if [[ -n "$test_host_apk" && -f "$test_host_apk" ]]; then
  have_test_host_apk=true
  test_host_app_id="$("$aapt2" dump packagename "$test_host_apk")"
fi
instrumentation_app_id="$("$aapt2" dump packagename "$instrumentation_apk")"

if [[ "$have_test_host_apk" == true ]]; then
  cleanup_package "$test_host_app_id"
fi
cleanup_package "$instrumentation_app_id"

install_success=false
max_install_retries=5
set +e
for retry_count in $(seq 1 "$max_install_retries"); do
  if [[ "$have_test_host_apk" == true ]]; then
    "${adb_cmd[@]}" install -r -t -g "$test_host_apk"
    test_host_install_status=$?
    if [[ "$test_host_install_status" -eq 0 ]]; then
      "${adb_cmd[@]}" install -r -t -g "$instrumentation_apk"
      instrumentation_install_status=$?
    else
      instrumentation_install_status=1
    fi
  else
    "${adb_cmd[@]}" install -r -t -g "$instrumentation_apk"
    instrumentation_install_status=$?
    test_host_install_status=0
  fi

  if [[ "$test_host_install_status" -eq 0 && "$instrumentation_install_status" -eq 0 ]]; then
    install_success=true
    break
  fi

  echo "Install failed. Retrying in 5s... ($((max_install_retries - retry_count)) attempts left)" >&2
  if [[ "$have_test_host_apk" == true ]]; then
    cleanup_package "$test_host_app_id"
  fi
  cleanup_package "$instrumentation_app_id"
  sleep 5
done
set -e

if [[ "$install_success" != true ]]; then
  echo "Installation failed after ${max_install_retries} attempts." >&2
  print_emulator_log
  exit 1
fi

if [[ "$have_test_host_apk" == true ]]; then
  "${adb_cmd[@]}" shell pm path "$test_host_app_id"
fi
"${adb_cmd[@]}" shell pm path "$instrumentation_app_id"

"${adb_cmd[@]}" logcat -c
set +e
output="$("${adb_cmd[@]}" shell am instrument -r -w "${instrumentation_app_id}/${instrumentation_runner}" 2>&1)"
instrumentation_status=$?
set -e
log_output="$("${adb_cmd[@]}" logcat -d)"

if [[ "$instrumentation_status" -ne 0 ]]; then
  echo "$output"
  echo "$log_output"
  exit "$instrumentation_status"
fi
if echo "$output" | grep -q "FAILURES"; then
  echo "$output"
  exit 1
fi
if echo "$log_output" | grep "Fatal signal" | grep -v -q "Fatal signal 31"; then
  echo "$log_output"
  exit 1
fi
