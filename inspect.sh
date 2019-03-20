#!/usr/bin/bash
TEMPFILE=/tmp/content.xml
DOCUMENT=$1

if [[ -z "$DOCUMENT" ]];
then
	echo "You need to specify a document to inspect"
	exit 0
fi

# -- cleanup
[[ -f $TEMPFILE ]] && rm $TEMPFILE

# extract one file from archive, lint it and save to temporary file. Then edit it with VIM
7z x -so "$DOCUMENT" content.xml | 
	xmllint --format - |
	sgrep -o "%r\n" '"<office:body>".."</office:body>"' |
	pygmentize

exit 0
