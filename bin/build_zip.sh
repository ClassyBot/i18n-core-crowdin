#!/usr/bin/env bash

# Exit on error
set -e

cd "$(dirname "$0")"
cd ..

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	SED_COMMAND="sed"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	SED_COMMAND="gsed"
else
	echo "Sorry, this script hasn't been tested on your OS platform"
	exit 1
fi

locales="$1"

if [ -z "$locales" ]; then
	echo "Locale variable not set!" >&2
	echo "Usage : $0 LOCALE_CODE" >&2
	exit 1
fi

mkdir -p zips
dir="./translations"

cd "$dir"

# clear any existing *.mo files
echo 'Removing existing MO files for locale'
mofiles=""
for f in *${locales}.mo; do
	rm "${f}" || true
done

# create a list of all available locales
echo 'Creating list of PO files for locale'
pofiles=""
for f in *${locales}.po; do
	pofiles+="${f} "
done

# make *.mo files for all *.po files
echo ''
echo 'Creating mo files'
for n in ${pofiles[@]};
do
	wp i18n make-mo "${n}"
done

pomofiles=""
for f in *${locales}.{po,mo}; do
	pomofiles+="${f} "
done

echo ''
echo 'Creating zip file'
for n in ${pomofiles[@]};
do
	zip "../zips/$locales.zip" "$n"
done

# report zip file name and creation date/time
echo ''
echo "$locales.zip created"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	stat -c '%.19z' en_GB.zip
elif [[ "$OSTYPE" == "darwin"* ]]; then
	stat -f %SB -t '%Y-%m-%d %H:%M:%S' "../zips/$locales.zip"
fi

# human readable to minified
# gsed -r s'|^\s*||' < translations-hr.json | gsed -r s'|:\s|:|' | tr -d '\n'> translations.json
# $SED_COMMAND -r s'|^\s*||' < translations-hr.json | $SED_COMMAND -r s'|:\s|:|' | tr -d '\n'> translations.json