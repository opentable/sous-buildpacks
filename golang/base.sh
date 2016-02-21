#!/bin/sh

set -eu

# Check dependencies
command -v go 2>&1>/dev/null || die "go not found in path"

# Check go major and minor version numbers
GO_MM_VERSION=$(go version | grep -o 'go[0-9]\.[0-9]\+')
[ -n "$GO_MAJOR_MINOR_VERSION" ] || die "unable to determine go version"

GO_MAJOR_VERSION=$(echo $GO_MM_VERSION | cut -d. -f1 | grep -o '[0-9]\+')
GO_MINOR_VERSION=$(echo $GO_MM_VERSION | cut -d. -f2)

( [ "$GO_MAJOR_VERSION" = "1" ] && [ "$GO_MINOR_VERSION" -gt 5 ] ) ||
	die "go version $GO_MM_VERSION not supported, want ^1.6"

# Set up the standard GOPATH directory structure
cd "$BASE_DIR" && mkdir src && mv "$REPO_DIR" "src/$REPO_DIR"

# Enter the expected working directory.
cd "src/$REPO_DIR/$REPO_WORKDIR"

# Set some environment variables
GOPATH="$BASE_DIR"
BINARY_NAME="$PROJ_NAME-$PROJ_VERSION-$PROJ_REVISION"

# Generate any code defined in this project or its dependencies
go generate ./... || { echo "go generate failed"; exit 1; }

