#!/bin/sh

BUILD_DIR="$PWD/target"

# Ensure we are in the root of the project in case this project is a multi-module build
cd $BASE_DIR/$REPO_DIR

mvn clean package

mv "$BUILD_DIR/*-jar-with-dependencies.jar" "$ARTIFACT_DIR"
