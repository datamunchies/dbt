#!/bin/sh

set -e

WHICH_DBT=/usr/local/bin/dbt

echo "Checking dbt installation in PATH"

if ! command -v "$WHICH_DBT" >/dev/null 2>&1; then
    echo "'dbt' command not available. Exiting"
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "Failed to find 'dbt'. Exiting"
    exit 1
fi

DBT_VERSION=$("$WHICH_DBT" --version)

if [ $? -ne 0 ]; then
    echo "Failed to run 'dbt --version'. Exiting"
    exit 1
fi
