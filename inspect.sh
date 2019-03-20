#!/usr/bin/bash
TEMPFILE=/tmp/content.xml
# -- clenup
[[ -f $TEMPFILE ]] && rm $TEMPFILE
# extract one file from archive, lint it and save to temporary file. Then edit it with VIM
# 7z x -so /tmp/Test_output.odt content.xml | xmllint --format - > $TEMPFILE && nvim -Rn $TEMPFILE
7z x -so /tmp/test.odt content.xml | 
	xmllint --format - |
	sgrep -o "%r\n" '"<office:body>".."</office:body>"' |
	pygmentize
