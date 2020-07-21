#!/bin/bash

# This script auto generates the release notes by listing all
# the commit messages between the current branch HEAD and the
# commit that contained a different (previous) versionCode in
# the app/build.gradle file.
#
# Safe to execute from any folder inside a parent git repo.

set -u
set -e

# Includes utility functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# shellcheck source=/utils.sh
. "$DIR/utils.sh"

# Takes a versionCode as a single argument and evaluates
# the latest commit that contains a different versionCode.
#
# Assumptions:
#   - It does not check if the previous version code represents
#   a smaller number than the input version code.
#   - It tries to find commit diff that contains a line in the
#   format "versionCode <number>" in the app/build.gradle file.
#
# $1 - input version code
#
# Example:
#   findLastNonEqualVersion "590"
#
# Returns the SHA reference of the latest commit with previous versionCode
findLastNonEqualVersion() {
  if [ $# = 1 ] && [ -n "$1" ]; then
    baseDir=$(getBaseDir)
    firstWithCurrentVersion=$(git log --reverse -S"versionCode $1" --pretty=format:%H  -- "${baseDir}"/app/build.gradle | sed -n 1p)
    latestCommitWithPreviousVersion=$(git show --no-patch --pretty=format:%H "$firstWithCurrentVersion"^1)
    echo "$latestCommitWithPreviousVersion"
  else
    return 1 # Missing argument
  fi
}

# Takes the list of commits messages between two commit references
#
# $1 - starting commit reference to be included
# $2 - final commit reference to be included
#
# Examples:
#   getReleaseNotes "cbeb73a34c6422adcb09d87bfd0ab935e57cb0a1" "HEAD"
#   getReleaseNotes "59e03a655082ca4137c8b8e7a680d85db340fe49" "c76866e450ea28e665abd5d9cc723f3a73fc2816"
#
# Returns the commit messages between the starting commit reference
# and the final commit reference, limiting to one line per commit message.
getReleaseNotes() {
  if [ $# = 2 ] && [ -n "$1" ] && [ -n "$2" ] ; then
    releaseNotes=$(git log "$1".."$2" --format=%s)
    echo "$releaseNotes"
  else
    return 1 # Invalid Arguments
  fi
}

# Main flow
if [ $# -gt 0 ] ; then
  case $1 in
  -h | --help)
    echo "Usage: generate_release_notes [options]"
    echo "Option          Long Option             Description"
    echo "-h              --help                  Show this help screen"
    echo "-o [file]       --output [file]         Specifies the file to write the release notes"
    exit
    ;;
  -o | --output)
    fileOutput=$2
    ;;
  *)
    fileOutput=""
    ;;
  esac
else
  fileOutput=""
fi

versionCode=$(getVersionCode)
commitWithPreviousVersion=$(findLastNonEqualVersion "$versionCode")
releaseNotes=$(getReleaseNotes "$commitWithPreviousVersion" "HEAD")

if [ -n "$fileOutput" ] ; then
    echo "$releaseNotes" >| "$fileOutput"
else
  echo "$releaseNotes"
fi

