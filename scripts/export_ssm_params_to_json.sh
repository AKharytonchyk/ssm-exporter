#!/bin/bash

retry() {
  local retries=$1
  local command="${@:2}"
  local count=0
  local delay=1

  until $command; do
    exit=$?
    wait=$((delay ** count))
    count=$((count + 1))
    if [ $count -le $retries ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  return 0
}

show_help() {
  echo "Usage: $0 [-p | --pathTemplate <path>] [-h | --help]"
  echo
  echo "Options:"
  echo "  -p, --pathTemplate   Specify the path template for SSM parameters."
  echo "  -h, --help           Display this help message."
}

PREFIX=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -p | --pathTemplate)
    PREFIX="$2"
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo "Unknown parameter passed: $1"
    show_help
    exit 1
    ;;
  esac
  shift
done

if [ -z "$PREFIX" ]; then
  echo "No path template provided, pulling all parameters."
  retry 5 aws ssm describe-parameters --query "Parameters[*].Name" --output text >parameters.txt
else
  retry 5 aws ssm describe-parameters --parameter-filters "Key=Name,Option=BeginsWith,Values=$PREFIX" --query "Parameters[*].Name" --output text >parameters.txt
fi

echo "[" >parameters.json

first=true
for param in $(cat parameters.txt); do
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >>parameters.json
  fi
  retry 5 aws ssm get-parameter --name $param --with-decryption --query "Parameter" --output json >>parameters.json
done

echo "]" >>parameters.json
