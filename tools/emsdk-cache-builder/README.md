Emscripten cache builder
========================

By default, Emscripten ships only with precompiled cache which doesn't support LTO. However, if you want to use LTO, you will need to build the cache yourself. Emscripten's bazel toolchain has [a documentation](https://github.com/emscripten-core/emsdk/blob/main/bazel/README.md) on how to do that, but the problem with that is that you then only get the LTO-enabled cache.

If you want to have both the default cache and the LTO-enabled cache to support both build types, you will need to use this script to build a custom cache that includes both.

This script is used for that. It will generate the `emsdk-cache.tar.gz` file that you can upload to your artifact server (e.g. Artifactory, Gitea, etc.) and then use it for for our Emscripten builds.

# Instructions

1. In `MODULE.bazel`, set the desired Emscripten version by changing the line:

```
bazel_dep(name = "emsdk", version = "4.0.16")
```

2. Optionally, update also the `rules_cc` version in the same file if needed.

3. Position yourself in the `tools/emsdk-cache-builder` directory.

4. Run the script:

```
./generate-emsdk-cache.sh`
```

5. The script will create the `emsdk-cache.tar.gz` file in the current directory.

6. Deploy that `emsdk-cache.tar.gz` to your server (artifactory, gitea, etc.) and make sure it's accessible via a URL. Also, obtain the SHA-256 checksum of the file.

7. In the main `MODULE.bazel`, update the Emscripten to the same version for which you built the cache, and add the checksum as follows:

8. In the main `MODULE.bazel`, find the line that specifies the prebuilt cache URL and update it so that it points to the URL of the newly uploaded file.

9. Update the same function to also include the SHA-256 checksum you noted earlier.

10. Finally, commit and push the changes to the repository.
