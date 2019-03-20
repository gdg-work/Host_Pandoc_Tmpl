#!/usr/bin/zsh
TEMPDIR="/tmp/"

# 0 Set some limits for user safety
ulimit -f $(( 1 * 2**21))   # 1 GB limit on files 1GB = 2^21 of 512-Byte blocks
limit datasize 1024m
limit stacksize 512m
limit cputime 60
limit memoryuse 2048m


# 2 make a document
pp -import macro.pp main.pp |
pandoc  -s -f markdown \
	--data-dir="$(pwd)/Pandoc" \
	-t html --metadata lang:ru \
	--metadata pagetitle="A test" \
	--lua-filter $(pwd)/Pandoc/test.lua \
	--verbose

# -top-level-division=chapter
# --lua-filter $(pwd)/Pandoc/orig_odt_list.lua \
