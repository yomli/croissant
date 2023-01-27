#!/usr/bin/env bash
set -uo pipefail

INPUT="_loader.css"
# NOW=$(date +"%Y%m%d")
NOW=$(date +"%s")

while read LINE <&3
do
	# Only do this on @import lines
	if [[ ${LINE:0:7} == "@import" ]]
	then
		# Skip @import
		part1=${LINE##*@import }
		# Skip url() part
		part1=${part1##*url(}
		# Skip '' or "" part
		part1=${part1##\'}
		part1=${part1##\"}
		# Skip the end
		part2="${part1%%.css*}.css"

		cat $part2 >> croissant-$NOW.css
		echo $part2 >> croissant-build-$NOW.txt
	fi

done 3< "$INPUT"

if [[ -f "croissant-$NOW.css" ]]
then
	if dpkg -l minify;
	then
		minify croissant-$NOW.css > croissant-$NOW.min.css
	else
		# This command removes comments from CSS and Javascript files using sed.
		# Courtesy of https://github.com/CMDann/CSSJSMinify
		cat croissant-$NOW.css | sed -e "s|/\*\(\\\\\)\?\*/|/~\1~/|g" -e "s|/\*[^*]*\*\+\([^/][^*]*\*\+\)*/||g" -e "s|\([^:/]\)//.*$|\1|" -e "s|^//.*$||" | tr '\n' ' ' | sed -e "s|/\*[^*]*\*\+\([^/][^*]*\*\+\)*/||g" -e "s|/\~\(\\\\\)\?\~/|/*\1*/|g" -e "s|\s\+| |g" -e "s| \([{;:,]\)|\1|g" -e "s|\([{;:,]\) |\1|g" > croissant-$NOW.min.css
	fi
fi

exit 0
