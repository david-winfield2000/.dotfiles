#!/bin/bash

processes=(
  "AeroSpace"
  "LinearMouse"
  "Maccy"
  "Ghostty"
)

for process in "${processes[@]}"; do
  pkill -x "$process" 2>/dev/null
done

osascript -e 'tell application "Karabiner-Elements" to quit'

# karabiner is a bit more complicated to quit
services=(
  "org.pqrs.service.agent.karabiner_console_user_server"
  "org.pqrs.service.agent.Karabiner-Menu"
  "org.pqrs.service.agent.Karabiner-NotificationWindow"
  "org.pqrs.service.agent.Karabiner-Core-Service-rev2"
)

for service in "${services[@]}"; do
  launchctl bootout "gui/$(id -u)/$service" 2>/dev/null
done
