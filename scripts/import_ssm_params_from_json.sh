#!/bin/bash

if ! command -v jq &>/dev/null; then
  echo "jq could not be found, please install jq to proceed"
  exit 1
fi

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

params=$(jq -c '.[]' parameters.json)
for param in $params; do
  name=$(echo $param | jq -r '.Name')
  type=$(echo $param | jq -r '.Type')
  value=$(echo $param | jq -r '.Value')
  description=$(echo $param | jq -r '.Description // empty')
  key_id=$(echo $param | jq -r '.KeyId // empty')
  tags=$(echo $param | jq -r '.Tags // empty')

  description_arg=""
  if [ -n "$description" ]; then
    description_arg="--description \"$description\""
  fi

  key_id_arg=""
  if [ -n "$key_id" ]; then
    key_id_arg="--key-id $key_id"
  fi

  tags_arg=""
  if [ -n "$tags" ]; then
    tags_arg="--tags $tags"
  fi

  if [ "$type" == "SecureString" ]; then
    retry 5 aws ssm put-parameter --name "$name" --type "$type" --value "$value" $description_arg $key_id_arg --overwrite >/dev/null
  else
    retry 5 aws ssm put-parameter --name "$name" --type "$type" --value "$value" $description_arg --overwrite >/dev/null
  fi

  if [ -n "$tags" ]; then
    retry 5 aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "$name" --tags "$tags" >/dev/null
  fi
done
