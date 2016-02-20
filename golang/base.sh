#!/bin/sh

set -eu

cd "$BASE_DIR" && mkdir src && mv "$REPO_DIR" "src/$REPO_DIR"
cd "src/$REPO_DIR/$REPO_WORKDIR"

GOPATH="$BASE_DIR" go generate ./... ||
	die "go generate failed"

