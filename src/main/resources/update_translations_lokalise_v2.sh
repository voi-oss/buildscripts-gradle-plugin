#!/bin/bash

# This script uses lokalise2 command line interface to
# pull the latest translations from the given project
# configuration.
# See https://github.com/lokalise/lokalise-cli-2-go
#
# The script assumes that the configuration file
# is located in the root git directory (config.yml).
#
# Safe to execute from any folder inside a parent git repo.

set -u
set -e

# Includes utility functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# shellcheck source=/utils.sh
. "$DIR/utils.sh"

# Main flow
baseDir=$(getBaseDir)
fileName="lokalise2"
if [ ! -f "$baseDir/$fileName" ]; then
  echo "Downloading lokalise2 cli"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -L -O https://github.com/lokalise/lokalise-cli-2-go/releases/latest/download/lokalise2_darwin_x86_64.tar.gz
    tar -xvzf lokalise2_darwin_x86_64.tar.gz -C "$baseDir"
  else
    curl -L -O https://github.com/lokalise/lokalise-cli-2-go/releases/latest/download/lokalise2_linux_x86_64.tar.gz
    tar -xvzf lokalise2_linux_x86_64.tar.gz -C "$baseDir"
  fi
fi

cd "$baseDir"

configFile="config.yml"
if [ ! -f "$configFile" ]; then
    echo "Error. Missing configuration file: $configFile"
    exit 1
fi

./"$fileName" file download --format xml --indentation 4sp --export-empty-as skip --unzip-to app/src/main/res