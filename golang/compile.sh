#!/bin/sh

BINARY_NAME="$(./command.sh)"

go build -o "$ARTIFACT_PATH/$BINARY_NAME" ||
	die "compilation failed"


