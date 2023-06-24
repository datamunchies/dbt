#!/bin/sh

# Exit the script if any command fails
set -e

# Check if 'whoami' command is available
if ! command -v whoami >/dev/null 2>&1; then
  echo "'whoami' command is not available. Exiting."
  exit 1
fi

USER=$(whoami)

echo "Running as $USER"

# Check if 'dbt' command is available
if ! command -v dbt >/dev/null 2>&1; then
  echo "'dbt' command is not available. Exiting."
  exit 1
fi

echo "Checking dbt installation in PATH"

DBT_LOCATION=$(which dbt)

# Check if 'dbt' command succeeded
if [ $? -ne 0 ]; then
  echo "Failed to find 'dbt' in PATH. Exiting."
  exit 1
fi

echo "Running dbt --version"

DBT_VERSION=$($DBT_LOCATION --version)

# Check if 'dbt --version' command succeeded
if [ $? -ne 0 ]; then
  echo "Failed to run 'dbt --version'. Exiting."
  exit 1
fi
