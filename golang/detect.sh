#!/bin/sh

# Check we have any .go file, 
(ls *.go 2>&1>/dev/null) ||
	{ echo "No files match *.go"; exit 1; }

# and that one of them has a main function.
(grep 'func main()' *.go 2>&1>/dev/null) ||
	{ echo "no 'func main()' found"; exit 1; }


