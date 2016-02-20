#!/bin/sh

set -eu

# Set up the standard GOPATH directory structure
cd "$BASE_DIR" && mkdir src && mv "$REPO_DIR" "src/$REPO_DIR"

# Enter the expected working directory.
cd "src/$REPO_DIR/$REPO_WORKDIR"

# Set some environment variables
GOPATH="$BASE_DIR"
BINARY_NAME="$PROJ_NAME-$PROJ_VERSION-$PROJ_REVISION"

# Generate any code defined in this project or its dependencies
go generate ./... || { echo "go generate failed"; exit 1; }

