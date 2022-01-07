#!/bin/bash

# This script uses phraseapp command line interface to
# pull the latest translations from the given project
# configuration.
#
# The script assumes that the phraseapp configuration file
# is located in the root git directory (.phraseapp.yml).
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
fileName="phraseapp"
if [ ! -f "$baseDir/$fileName" ]; then
  echo "Downloading phraseapp-cli"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -L -O https://github.com/phrase/phraseapp-client/releases/download/1.17.1/phraseapp_macosx_amd64
    mv phraseapp_macosx_amd64 "$baseDir/$fileName"
  else
    curl -L -O https://github.com/phrase/phraseapp-client/releases/download/1.17.1/phraseapp_linux_amd64
    mv phraseapp_linux_amd64 "$baseDir/$fileName"
  fi
fi

chmod +x "$baseDir/$fileName"
cd "$baseDir"

configFile=".phraseapp.yml"
if [ ! -f "$configFile" ]; then
    echo "Error. Missing configuration file: $configFile"
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  "$fileName" pull
else
  ./"$fileName" pull
fi
