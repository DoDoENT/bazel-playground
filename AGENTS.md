## Build commands
- `bazel test //:host` - Run all host-tests 
- `bazel test //:wasm-all --config=wasm` - Run all WebAssembly tests.
- `bazel build //:android --config=android` - Build android tests.
- `bazel test //:android-emulator --config=android` - Runs android tests on emulator.
- `bazel test //:ios --config=ios_simulator` - Run iOS simulator tests (requires MacOS with Xcode).
- add `--config=release` to the above commands to build or test in release mode.

## Workflow
- Ensure host, android, and wasm tests are passing after making changes.
- If running on MacOS, ensure iOS simulator tests are passing after making changes.
- If making changes specific to a platform (e.g. Android), it's sufficient to run tests for that platform only.
