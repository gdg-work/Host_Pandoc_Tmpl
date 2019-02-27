#!/bin/sh
TEMPDIR="/tmp/"
OUTFILE="/tmp/Report.odt"
TEMPLATE_DIR="Modular_Template"
TEMPLATE_MAIN="tempate_main.pp"
TEMPLATE_OUT="$TEMPDIR/host.opendocument"

# 1 Create a template file
pushd "$TEMPLATE_DIR"
/usr/bin/pp -import template_list_style.pp template_main.pp > $TEMPLATE_OUT
popd

echo "Created a template, using it for the document"

# 2 make a document
pp -import macro.pp main.pp |
pandoc  -s -f markdown+definition_lists \
	-t odt --metadata lang:ru \
	--lua-filter Pandoc/odt-lists.lua \
        --template="$TEMPLATE_OUT" \
	--verbose \
	--data-dir="$(pwd)/Pandoc" \
	-o "$OUTFILE" \ 
	report_1.md

# -top-level-division=chapter
# --template="$TEMPLATE_OUT" \
