#!/bin/sh

TEST_SCRIPT=$(node -e 'console.log(require("./package.json").scripts.test)') ||
	{ echo "package.json does not specify a test script"; exit 1; }

npm test

