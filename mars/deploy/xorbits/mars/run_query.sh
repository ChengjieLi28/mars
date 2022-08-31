#!/bin/bash

set -e

function usage() {
  echo "Usage: $0 [-p SCRIPT_PATH] [-e ENDPOINT] [-q QUERIES] [-f DATA_FOLDER] [-a]"
  exit 0
}

use_arrow_dtype="false"
queries="None"

while getopts 'p:e:q:f:a' OPT; do
  case $OPT in
    p) query_script_file="$OPTARG";;
    e) endpoint="$OPTARG";;
    q) queries="$OPTARG";;
    f) folder="$OPTARG";;
    a) use_arrow_dtype="true";;
    ?) usage;;
  esac
done

function check_file_exist() {
  if [ ! -f "$1" ]; then
    echo "$1 does not exit!"
    exit 1
  fi
}

check_file_exist "$query_script_file"

if [ "$queries" != "None" ]; then
  python "$query_script_file" \
        --folder "$folder" \
        --endpoint "$endpoint" \
        --query "$queries" \
        --use-arrow-dtype "$use_arrow_dtype"
else
  python "$query_script_file" \
        --folder "$folder" \
        --endpoint "$endpoint" \
        --use-arrow-dtype "$use_arrow_dtype"
fi
