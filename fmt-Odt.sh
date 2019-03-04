#!/usr/bin/zsh
TEMPDIR="/tmp/"
OUTFILE="/tmp/Test_output.odt"
TEMPLATE_DIR="Modular_Template"
TEMPLATE_MAIN="tempate_main.pp"
TEMPLATE_OUT="$TEMPDIR/host_template.opendocument"

# 0 Set some limits for user safety
ulimit -f $(( 1 * 2**21))   # 1 GB limit on files 1GB = 2^21 of 512-Byte blocks
limit datasize 1024m
limit stacksize 512m
limit cputime 60
limit memoryuse 2048m

# 1 Create a template file
pushd "$TEMPLATE_DIR"
/usr/bin/pp -import generate_list_styles.pp template_main.pp > $TEMPLATE_OUT
popd

echo "Created a template, using it for the document"

# 2 make a document
pp -import macro.pp main.pp |
pandoc  -s -f markdown+definition_lists \
	--data-dir="$(pwd)/Pandoc" \
	-t odt --metadata lang:ru \
	--lua-filter $(pwd)/Pandoc/odt-lists.lua \
	--verbose \
        --template="$TEMPLATE_OUT" \
	-o "$OUTFILE"

# -top-level-division=chapter
# --lua-filter Pandoc/task-list.lua \
