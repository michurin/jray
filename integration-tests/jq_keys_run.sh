#!/bin/sh

set -e

script_dir="${0%/*}"
sample='jq_keys_test.json'

echo "debug: script_dir=$script_dir"
echo "debug: jq=$(which jq)"
echo "debug: jq_verison=$(jq --version)"
echo "debug: go_version=$(go version)"

cd "$script_dir"

go build ..

cat "$sample" |
./jray |
sed 's/ = .*//' |
while IFS= read -r i
do
    ok="$(jq -r "$i" <"$sample")"
    echo "path: $i — $ok"
    test "ok" = "$ok" # it will stop on error, thanks set -e
done
