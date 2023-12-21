#!/bin/sh

command=$2

if [ "$command" = "started" ]; then
  echo "setting up host cpu pinning"
  systemctl set-property --runtime -- system.slice AllowedCPUs=8-31,40-63
  systemctl set-property --runtime -- user.slice AllowedCPUs=8-31,40-63
  systemctl set-property --runtime -- init.scope AllowedCPUs=8-31,40-63
elif [ "$command" = "release" ]; then
  echo "restoring host cpu access"
  systemctl set-property --runtime -- system.slice AllowedCPUs=0-63
  systemctl set-property --runtime -- user.slice AllowedCPUs=0-63
  systemctl set-property --runtime -- init.scope AllowedCPUs=0-63
fi

