# My Bazel Playground

This repository contains macros that enable C++ build and unit testing on Mac, Linux, iOS, Android, and WebAssembly.

Examples are based on [bazel-examples](https://github.com/bazelbuild/examples) for C++ (Stage 3), but extended to also work on mobile devices.

## Query all targets:

```
bazel query //...
```

## Run all tests on host machine

```
bazel test //... --test_tag_filters=host
```

## Run all tests on attached iOS device

```
bazel test //... --test_tag_filters=ios --test_arg=--destination=platform=ios_device,id=<device_id> --ios_multi_cpus=arm64
```

## Run all tests on iOS Simulator

```
bazel test //... --test_tag_filters=ios 
```

