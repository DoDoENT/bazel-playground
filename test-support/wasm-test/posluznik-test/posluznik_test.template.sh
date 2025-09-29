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

output=`$posluznik --input "$serve_path" --chrome-path "$chrome" --launch-chrome -- "$html_name" $args`

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
