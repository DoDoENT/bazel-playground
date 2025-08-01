# My Bazel Playground

This repository contains macros that enable C++ build and unit testing on Mac, Linux, iOS, Android, and WebAssembly.

Examples are based on [bazel-examples](https://github.com/bazelbuild/examples) for C++ (Stage 3), but extended to also work on mobile devices.

## Query all targets:

```
bazel query //...
```

## Run all tests on host machine

```
bazel test //:host 
```

## Run all tests on attached iOS device

```
bazel test //:ios --test_arg=--destination=platform=ios_device,id=<device_id> --config=ios_device
```

## Run all tests on attached Android device

```
bazel test //:android --test_arg=--device_id=<device_id> --config=android
```

## Run all WebAssembly tests on Node.JS

```
bazel test //:wasm-all --config=wasm
```
