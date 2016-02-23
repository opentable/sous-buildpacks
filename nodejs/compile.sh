#!/bin/sh

npm install --production || { echo "npm install failed"; exit 1; }

BUILD_DIR=$PWD

cd ..

# The source plus built dependencies make up the artifact.
mv "$BUILD_DIR" "$ARTIFACT_DIR"
