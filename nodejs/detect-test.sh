#!/bin/sh

TEST_SCRIPT=$(package_json scripts.test) ||
	{ echo "package.json does not specify a test script"; exit 1; }

[ "$TEST_SCRIPT" = "" ] &&
	{ echo "package.json:scripts.test is empty"; exit 1; }

