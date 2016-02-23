#!/bin/sh

set -eu

# package_json is a utility to get values out of package.json using
# dot notation. E.g. `package_json scripts.start` will return "hello"
# from the following package.json:
#
#     { "scripts": { "start": "hello" } }
#
# it generates some code that traverses the object hierarcy safely.
# It exits with exit code 1 if the value was not found, zero if it was.
package_json() {
	local JSONPATH="$1"
	local EXP="var p = require('./package.json'); a=''; function notfound() { console.log(a + ' not found in package.json'); process.exit(1); }"
	local IFS="."
	for SEGMENT in $JSONPATH; do
		#echo "Adding segment $SEGMENT"
		EXP="$EXP; a = a + '.$SEGMENT'; if (p.$SEGMENT) { p = p.$SEGMENT; } else { notfound(); }"
	done
	#echo "Final EXP: $EXP"
	node -e "$EXP; console.log(p)"
}

START_SCRIPT=$(package_json scripts.start)

