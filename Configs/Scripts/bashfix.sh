#!/usr/bin/env bash
bashrc="$HOME/.config/bash/bashrc"
ogbash="$HOME/.bashrc"

if [[ -f "$ogbash" ]]; then
  mv "$ogbash" "${ogbash}-$(date +"%H:%M:%S-%A-%d-%B-%Y").bak"
  cat > "$ogbash" << EOF
  if [ -f "$bashrc" ]; then
    . "$bashrc"
  fi
EOF
fi
