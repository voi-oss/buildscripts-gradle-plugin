#!/bin/bash

# Reads base directory referenced by git
getBaseDir() {
  baseDir=$(gitDir=$(git rev-parse --git-dir) && cd "$gitDir" && cd .. && pwd)
  echo "$baseDir"
}

# Reads the name of the current git branch
getCurrentBranchName() {
  currentBranch=$(git rev-parse --abbrev-ref HEAD)
  echo "$currentBranch"
}

# Reads the version code from app/build.gradle file.
#
# Assumptions:
#   - It tries to find a line in the format " versionCode <number>"
#   in the app/build.gradle file.
#
# Returns the version code.
getVersionCode() {
  baseDir=$(getBaseDir)
  fullVersionCode=$(grep " versionCode " "${baseDir}"/app/build.gradle | awk '{print $2}' | tr -d \''"\')
  echo "$fullVersionCode"
}

# Reads the version name from app/build.gradle file.
#
# Assumptions:
#   - It tries to find a line in the format " versionName <semVer>"
#   in the app/build.gradle file.
#
# Returns the version name.
getVersionName() {
  baseDir=$(getBaseDir)
  fullVersionName=$(grep " versionName " "${baseDir}"/app/build.gradle | awk '{print $2}' | tr -d \''"\')
  echo "$fullVersionName"
}