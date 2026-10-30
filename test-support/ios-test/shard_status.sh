#!/bin/bash

if [[ -n "${TEST_SHARD_STATUS_FILE:-}" ]]; then
    touch "$TEST_SHARD_STATUS_FILE"
fi
