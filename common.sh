#!/bin/sh

set -eu

log() { echo "$@" >&2; }
die() { log "$@"; exit 1; }

requireSet() {
	[ -n "${1+x}" ] || die "Required variable $1 not set."
}

requireNonempty() {
	requireSet "$1" && [ -n "$1" ] || die "Required non-empty variable $1 is empty."
}

# check inputs

# - PROJ_NAME is the name of this project, mainly used for cosmetic purposes
# - PROJ_VERSION is the semver version of this project, also mainly for
#     cosmetic purposes.
# - BASE_DIR is the absolute directory path which contains the REPO_DIR
# - REPO_DIR is the relative directory path of the repo root directory
#     inside BASE_DIR. This directory contains a snapshot of the entire
#     repository.
# - REPO_WORK_DIR is the relative directory inside REPO_DIR where the build was
#     invoked by the user. It can be empty "" meaning the user was inside the
#     repository base directory directly, or can be of the form "dirname" or "dirname/subdir"
# - ARTIFACT_DIR is the absolute directory path where raw artifacts should be placed
requireNonempty PROJ_NAME
requireNonempty PROJ_VERSION
requireSet      PROJ_REVISION
requireNonempty PROJ_DIRTY
requireNonempty BASE_DIR      
requireNonempty REPO_DIR      
requireSet      REPO_WORKDIR 
requireNonempty ARTIFACT_DIR  

( [ "$PROJ_DIRTY" = "YES" || [ "$PROJ_DIRTY" = "NO" ] ) ||
	die "PROJ_DIRTY was '$PROJ_DIRTY', expected 'YES' or 'NO'"
[ -d "$BASE_DIR" ] ||
	die "no directory at BASE_DIR ($BASE_DIR)"
[ -d "$BASE_DIR/$REPO_DIR" ] ||
	die "no directory at REPO_DIR ($REPO_DIR)"
[ -d "$BASE_DIR/$REPO_DIR/$REPO_WORKDIR" ] ||
	die "no directory at BASE_DIR/REPO_DIR/REPO_WORKDIR ($BASE_DIR/$REPO_DIR/$REPO_WORKDIR)"
[ -d "$ARTIFACT_DIR" ] ||
	die "no directory at ARTIFACT_DIR ($ARTIFACT_DIR)"

