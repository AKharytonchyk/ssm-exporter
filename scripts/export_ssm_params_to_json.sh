#!/bin/bash

PREFIX="/test/param/"

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

retry 5 aws ssm describe-parameters --parameter-filters "Key=Name,Option=BeginsWith,Values=$PREFIX" --query "Parameters[*].Name" --output text >parameters.txt

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
