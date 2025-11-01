# Note: Calculate SRI checksums with (example for linux64):
# curl -L https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.154/linux64/chrome-headless-shell-linux64.zip | sha256 | xxd -r -p | base64
# Please add new versions to the beginning of the dictionary to make it easier to find the latest version.
# For most purposes, linux64 and mac-arm64 are sufficient, but other platforms can be included as well.
# Discover the latest version here: https://googlechromelabs.github.io/chrome-for-testing/

CHROME_VERSIONS = {
    "141": {
        "version": "141.0.7390.78",
        "linux64-integrity": "sha256-LBFykydu+HSsHsttASi+tOuS5bfWs3uTrsY7rzItlkA=",
        "mac-arm64-integrity": "sha256-ZEXgxKiL98vnQYA88+x0tEcsgEv/q0kU0seb/nTX2Yo=",
    },
    "140": {
        "version": "140.0.7339.207",
        "linux64-integrity": "sha256-Ofy2rN9ELlVgvDzdbsCnsxdJmKl2HzkcFWpNJt9aCxk=",
        "mac-arm64-integrity": "sha256-BBjDN9U6EtwJCFJ/zQR4oTVJehR6M65qORE6FsZP6fM=",
    },
    "139": {
        "version": "139.0.7258.154",
        "linux64-integrity": "sha256-hVHcuJZzmAYWUosK82l2I5ML7GLvsGAUpUzZYacZlJc=",
        "mac-arm64-integrity": "sha256-sLr7DCOZbO1plOfrMnyIHqDU9IA0JCRs5873Df7wzFY=",
        "mac-x64-integrity": "sha256-TqsKUov8CgC5k164o3xRVHBRRjkgYOekTHRPFsKTun8=",
        "win32-integrity": "sha256-op8qXLbgZ4sLbZTB4tYFoOxEH4qKIJRPhF2O4UWGGhY=",
        "win64-integrity": "sha256-FDrHTm26Ai7P6+/3CtOZBg/+wDSNk63Fwx2eQCCrcCw=",
    },
}
