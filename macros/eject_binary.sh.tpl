#!/bin/bash

set -e

OUTPUT_DIR="${1:-%(OUTPUT_DIR)s}"
if [[ "$OUTPUT_DIR" != /* ]]; then
    OUTPUT_DIR="$BUILD_WORKSPACE_DIRECTORY/$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

files=( %(FILES_TO_EJECT)a )

should_unpack_archives=%(UNPACK_ARCHIVES)s

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
    dest="$OUTPUT_DIR/$file_path"

    if [[ "$should_unpack_archives" == "True" && ("$file" == *.zip || "$file" == *.tar.gz) ]]; then
        dest_dir="$OUTPUT_DIR/$file_path"
        dest_dir="${dest_dir%.tar.gz}"
        dest_dir="${dest_dir%.zip}"
        mkdir -p "$dest_dir"
        if [[ "$file" == *.zip ]]; then
            unzip -q "$file" -d "$dest_dir"
        elif [[ "$file" == *.tar.gz ]]; then
            tar -xzf "$file" -C "$dest_dir"
        fi
    else
        mkdir -p "$(dirname "$dest")"
        if [[ -d "$file" ]]; then
            cp -r "$file" "$dest"
        else
            cp "$file" "$dest"
            chmod 644 "$dest"
        fi
    fi
done
