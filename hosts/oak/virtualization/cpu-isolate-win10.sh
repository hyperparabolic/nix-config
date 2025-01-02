#!/usr/bin/env bash

guest=$1
command=$2

if [ "$guest" != "win10" ]; then
  echo "cpu-isolate-win10.sh ignoring other guest"
  exit 0
fi

if [ "$command" = "started" ]; then
  echo "cpu-isolate-win10.sh setting up host cpu isolation"
  systemctl set-property --runtime -- system.slice AllowedCPUs=8-31,40-63
  systemctl set-property --runtime -- user.slice AllowedCPUs=8-31,40-63
  systemctl set-property --runtime -- init.scope AllowedCPUs=8-31,40-63
elif [ "$command" = "release" ]; then
  echo "cpu-isolate-win10.sh restoring host cpu access"
  systemctl set-property --runtime -- system.slice AllowedCPUs=0-63
  systemctl set-property --runtime -- user.slice AllowedCPUs=0-63
  systemctl set-property --runtime -- init.scope AllowedCPUs=0-63
fi
