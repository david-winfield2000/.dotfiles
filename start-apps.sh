#!/bin/bash

apps=(
  "AeroSpace"
  "LinearMouse"
  "Maccy"
  "Ghostty"
  "Karabiner-Elements"
)

for app in "${apps[@]}"; do
  if [ -d "/Applications/$app.app" ]; then
    open -a "$app"
  fi
done
