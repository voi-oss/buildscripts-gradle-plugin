#!/bin/bash

# This script bumps executes a version bump by:
#   - Incrementing the version code by 10
#   - Incrementing the minor segment of the version name by 1
#
# The script assumes that the version name follows the SemVer
# convention (major.minor.patch)
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
versionName=$(getVersionName)
versionCode=$(getVersionCode)
newCode=$((versionCode+10))
newSemverVersion=$("$DIR"/semver.sh bump minor "$versionName")

git checkout master

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  sed -E -i "" "s/versionCode [0-9]*/versionCode $newCode/" "${baseDir}"/app/build.gradle
  sed -E -i "" "s/versionName \"[\.0-9]*\"/versionName \"$newSemverVersion\"/" "${baseDir}"/app/build.gradle
else
  # Other unix
  sed -i -E "s/versionCode [0-9]*/versionCode $newCode/" "${baseDir}"/app/build.gradle
  sed -i -E "s/versionName \"[\.0-9]*\"/versionName \"$newSemverVersion\"/" "${baseDir}"/app/build.gradle
fi

git add "${baseDir}"/app/build.gradle
git commit -m "Version bump $newSemverVersion ($newCode)"
git push