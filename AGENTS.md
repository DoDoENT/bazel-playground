## Build commands
- `bazel test //:host` - Run all host-tests 
- `bazel test //:wasm-all --config=wasm` - Run all WebAssembly tests.
- `bazel build //:android --config=android` - Build android tests.
- `bazel test //:ios --config=ios_simulator` - Run iOS simulator tests (requires MacOS with Xcode).
- add `--config=release` to the above commands to build or test in release mode.

## Workflow
- Ensure host and wasm tests are passing after making changes.
- Ensure Android tests can be built after making changes

## Workflow
- Ensure host and wasm tests are passing after making changes.
- Ensure Android tests can be built after making changes
- If running on MacOS, ensure iOS simulator tests are passing after making changes.
