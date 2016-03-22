#!/bin/bash

cleanup(){
  local filter="$1"

  for index in $(indexes "$filter"); do
    delete_index "$index"
  done
}

delete_index(){
  local index="$1"

  curl \
    --silent \
    -X DELETE \
    "${ES_URI}/${index}"
}

indexes(){
  local filter="$1"

  curl --silent "${ES_URI}/_cat/indices?v" \
  | awk '{print $3}' \
  | grep "$filter"
}

list(){
  local filter="$1"

  for index in $(indexes "$filter"); do
    echo "$index"
  done
}

usage(){
  echo ""
  echo "env ES_URI=<https://es.com> ./elastic-cleanup.sh <command> <filter-regex>"
  echo "  command is one of list/cleanup"
  echo ""
}

main() {
  local cmd="$1"
  local filter="$2"

  if [ -z "$ES_URI" -o -z "$cmd" -o -z "$filter" ]; then
    echo "Missing either a command, filter, or ES_URI"
    echo "cowardly refusing to do anything"
    usage
    exit 1
  fi

  if [ "$cmd" == "list" ]; then
    list "$filter"
    exit 0
  fi

  if [ "$cmd" == "cleanup" ]; then
    cleanup "$filter"
    exit 0
  fi

  usage
  exit 1
}
main $@
