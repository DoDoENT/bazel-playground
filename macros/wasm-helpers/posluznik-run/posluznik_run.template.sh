#!/bin/bash

set -xe

posluznik="%(posluznik)s"
wasm_mobile_binary="%(wasm_mobile_binary)s"
args="%(args)s"

serve_path=`dirname "$wasm_mobile_binary"`
html_name=`basename "$wasm_mobile_binary" .wasm`.html

$posluznik --input "$serve_path" -- "$html_name" $args

shard_args=()
if [[ -n "${TEST_TOTAL_SHARDS:-}" || -n "${TEST_SHARD_INDEX:-}" ]]; then
    if [[ ! "${TEST_TOTAL_SHARDS:-}" =~ ^[0-9]+$ || ! "${TEST_SHARD_INDEX:-}" =~ ^[0-9]+$ ]]; then
        echo "Invalid Bazel shard coordinates."
        exit 1
    fi
    shard_args=("--bazel-shard=${TEST_TOTAL_SHARDS},${TEST_SHARD_INDEX}")
fi
output=`$posluznik --input "$serve_path" --chrome-path "$chrome" --launch-chrome -- "$html_name" $args "${shard_args[@]}"` || {
    status=$?
    echo "posluznik failed with exit status $status."
    echo "$output"
    exit $status
}

if [[ -n "${TEST_SHARD_STATUS_FILE:-}" ]]; then
    if ! echo "$output" | grep -q 'MB_BAZEL_SHARDING_READY'; then
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
