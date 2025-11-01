#!/bin/bash

# First built a dummy WASM project to populate the emsdk cache

bazel build //:dummy_wasm

BAZEL_OUTPUT=$(bazel info output_base)

rm -rf emsdk-cache emsdk-cache.tar.gz || true
mkdir -p emsdk-cache

output_dir="$(pwd)/emsdk-cache"

# NOTE: The script assumes either arm64 Mac or Intel Linux.

if [[ "$OSTYPE" == "darwin"* ]]; then
    suffix="mac_arm64"
else
    suffix="linux"
fi

pushd "$BAZEL_OUTPUT/external/emsdk++emscripten_deps+emscripten_bin_$suffix/emscripten/cache"

cp -r sysroot sysroot_install.stamp "$output_dir/"

popd

pushd "$BAZEL_OUTPUT/external/emsdk++emscripten_cache+emscripten_cache/cache"

cp -r sysroot sysroot_install.stamp "$output_dir/"

popd

tar czf emsdk-cache.tar.gz emsdk-cache

rm -rf emsdk-cache
bazel clean
bazel shutdown
