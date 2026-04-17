#!/bin/bash

set -e

mkdir -p "$BUILD_WORKSPACE_DIRECTORY/%(OUTPUT_DIR)s"

files=( %(FILES_TO_EJECT)a )

STRIP_PREFIX="%(STRIP_PREFIX)s"
# Ensure STRIP_PREFIX ends with a slash if it's not empty 
# This prevents accidentally stripping partial directory names
if [[ -n "$STRIP_PREFIX" && "$STRIP_PREFIX" != */ ]]; then
    STRIP_PREFIX="${STRIP_PREFIX}/"
fi

for file in "${files[@]}"; do
    file_path="$file"
    
    # 1. Normalize paths from external repositories
    if [[ "$file_path" == ../* ]]; then
        file_path="${file_path#../}"   # Strip the leading '../'
        file_path="${file_path#*/}"    # Strip the repo name (everything up to the next '/')
    elif [[ "$file_path" == external/* ]]; then
        file_path="${file_path#external/}" 
        file_path="${file_path#*/}"    
    fi
    
    # 2. Strip the user-provided prefix
    if [[ -n "$STRIP_PREFIX" ]]; then
        file_path="${file_path#$STRIP_PREFIX}"
    fi
    
    # 3. Resolve the final destination
    dest="$BUILD_WORKSPACE_DIRECTORY/%(OUTPUT_DIR)s/$file_path"
    
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
    chmod 644 "$dest"
done
