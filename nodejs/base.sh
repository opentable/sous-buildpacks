#!/bin/sh

set -eu

# Try to find the name of the start script from package.json
# since we know we have node available, why not use it here...
START_SCRIPT=$(node -e 'console.log(require("./package.json").scripts.start)')

