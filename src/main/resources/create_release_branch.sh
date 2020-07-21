#!/bin/bash

# This script creates a release branch and a release tag from
# the latest commit in the currently checked out branch (HEAD).
# In case of errors, the script will rollback any changes and
# checkout the master branch.
#
# The release branch name will follow the format:
#   release/<major version>.<minor version>
#
# The tag name will follow the format:
#   ReleaseInternal_<version name>
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

# Takes a versionName as a single argument and returns the
# release branch name in the format release/<major.minor>
#
# Assumptions:
#   - The versionName in the input is in the format: major.minor.patch
#
# $1 - input version name
#
# Example:
#   getReleaseBranchName "1.36.0" -> outputs: release/1.36
#
# Returns the release branch name
getReleaseBranchName() {
  local versionName
  local releaseVersion
  if [ $# = 1 ] && [ -n "$1" ]; then
    versionName="$1"
    IFS='.' read -r -a majMinPatch <<< "$versionName"
    releaseVersion="${majMinPatch[0]}.${majMinPatch[1]}"
    echo "release/$releaseVersion"
  else
    exit 1 # Missing argument
  fi
}

# Takes a branch name as a single argument and checks if the branch
# already exists locally or remotely.
#
# $1 - input branch name
#
# Example:
#   checkIfBranchExists "release/1.36"
#
# Returns:
#   0 - if the branch already exists
#   1 - if the branch does not exist
checkIfBranchExists() {
  local branchName
  local branchSha
  if [ $# = 1 ] && [ -n "$1" ]; then
    git fetch --all
    branchName="$1"
    branchSha=$(git rev-parse --verify --quiet "$branchName")
    if [ -n "$branchSha" ]; then
      return 0 # Branch already exists
    else
      return 1 # Branch does not exist
    fi
  else
    exit 1 # Missing argument
  fi
}

# Takes a release branch name as a single argument
# and creates if it doesn't exist yet.
#
# $1 - input release branch name
#
# Example:
#   createReleaseBranchLocally "release/1.36"
#
#
# Returns:
#   0 - if the branch was created
#   1 - if the branch was already existing
createReleaseBranchLocally() {
  local releaseBranchName
  if [ $# = 1 ] && [ -n "$1" ]; then
    releaseBranchName="$1"
    if ! checkIfBranchExists "$releaseBranchName"; then
      git branch "$releaseBranchName"
      return 0 # Branch created locally
    else
      return 1 # Branch already existed. No need to create.
    fi
  else
    exit 1 # Missing argument
  fi
}

# Takes a tag name as a single argument and creates
# a tag if it doesn't exist
#
# $1 - input tag name
#
# Example:
#   createTag "Release_1.36.0"
#
# Returns:
#   0 - if the tag was created
#   1 - if the tag was already existing
createTag() {
  local tagName
  if [ $# = 1 ] && [ -n "$1" ]; then
    tagName="$1"
    git fetch --tags
    if ! git tag -a "$tagName" -m "$tagName"; then
      return 1 # Error creating tag
    else
      return 0 # Tag created
    fi
  else
    exit 1 # Missing argument
  fi
}

# Takes a tag name and a branch name as inputs and makes
# a rollback by locally deleting them.
#
# $1 - tag name to be deleted
# $2 - branch name to be deleted
#
# Example:
#   rollback "Release_1.36.0" "release/1.36"
rollback() {
  local tagName
  local releaseBranchName
  local originalBranch
  if [ $# = 3 ] && [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
    tagName="$1"
    releaseBranchName="$2"
    originalBranch="$3"
    git tag -d "$tagName"
    git checkout "$originalBranch"
    git branch -d "$releaseBranchName"
  else
    exit 1 # Invalid arguments
  fi
}

# Main flow
versionName=$(getVersionName)
releaseBranchName=$(getReleaseBranchName "$versionName")
originalBranch=$(getCurrentBranchName)

echo "Create release branch"
if ! createReleaseBranchLocally "$releaseBranchName"; then
  echo "Error while creating branch $releaseBranchName."
  exit 1
fi

echo "Create internal release tag"
tagName="Release_$versionName"
if ! createTag "$tagName"; then
  echo "Error while creating tag $tagName."
  exit 1
fi

echo "Push internal release tag"
if ! git push -u origin "$tagName"; then
  echo "Failed to push tag: $tagName. Rolling back."
  rollback "$tagName" "$releaseBranchName" "$originalBranch"
  exit 1
fi

echo "Push release branch"
git push -u origin "$releaseBranchName"

echo "Created release branch $releaseBranchName and tag $tagName"
