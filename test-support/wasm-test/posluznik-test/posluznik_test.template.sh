#!/bin/bash

set -xe

posluznik="%(posluznik)s"
wasm_mobile_binary="%(wasm_mobile_binary)s"
args="%(args)s"

serve_path=`dirname "$wasm_mobile_binary"`
html_name=`basename "$wasm_mobile_binary" .wasm`.html

output=`$posluznik --input "$serve_path" --launch-chrome -- "$html_name" $args`

if echo "$output" | grep -q "\[  FAILED  \]"; then
    echo "Some tests failed."
    echo "$output"
    exit 1
fi
