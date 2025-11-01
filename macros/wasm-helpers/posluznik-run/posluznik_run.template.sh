#!/bin/bash

set -xe

posluznik="%(posluznik)s"
wasm_mobile_binary="%(wasm_mobile_binary)s"
args="%(args)s"

serve_path=`dirname "$wasm_mobile_binary"`
html_name=`basename "$wasm_mobile_binary" .wasm`.html

$posluznik --input "$serve_path" -- "$html_name" $args

