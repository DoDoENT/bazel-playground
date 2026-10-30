#!/bin/bash

set -xe

posluznik="%(posluznik)s"
wasm_mobile_binary="%(wasm_mobile_binary)s"
args="%(args)s"
chrome="%(chrome)s"

wasm_validate_enabled=%(wasm_validate_enabled)b
wasm_validate="%(wasm_validate)s"
wasm_validate_flags="%(wasm_validate_flags)s"

if [ "$wasm_validate_enabled" == "true" ]; then
    $wasm_validate $wasm_validate_flags "$wasm_mobile_binary"
fi

serve_path=`dirname "$wasm_mobile_binary"`
html_name=`basename "$wasm_mobile_binary" .wasm`.html

shard_args=()
if [[ -n "${TEST_TOTAL_SHARDS:-}" || -n "${TEST_SHARD_INDEX:-}" ]]; then
    if [[ ! "${TEST_TOTAL_SHARDS:-}" =~ ^[0-9]+$ || ! "${TEST_SHARD_INDEX:-}" =~ ^[0-9]+$ ]]; then
        echo "Invalid Bazel shard coordinates."
        exit 1
    fi
    shard_args=("--bazel-shard=${TEST_TOTAL_SHARDS},${TEST_SHARD_INDEX}")
fi
output=`$posluznik --input "$serve_path" --chrome-path "$chrome" --launch-chrome -- "$html_name" $args "${shard_args[@]}"`

if [[ -n "${TEST_SHARD_STATUS_FILE:-}" ]]; then
    if ! echo "$output" | grep -q 'BAZEL_SHARDING_READY'; then
        echo "WebAssembly test did not acknowledge shard support."
        echo "$output"
        exit 1
    fi
    touch "$TEST_SHARD_STATUS_FILE"
fi

if echo "$output" | grep -q "\[  FAILED  \]"; then
    echo "Some tests failed."
    echo "$output"
    exit 1
fi

if echo "$output" | grep -q "EXCEPTION THROWN"; then
    echo "Some tests failed."
    echo "$output"
    exit 1
fi
