#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

timedatectl set-timezone 'America/Chicago'

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

if [[ -z "$(grep -w "100000" /proc/self/uid_map)" ]]; then
  msg_info "Setting Up Hardware Acceleration"
  $STD wget -P /tmp/ https://us.download.nvidia.com/XFree86/Linux-x86_64/530.41.03/NVIDIA-Linux-x86_64-530.41.03.run
  $STD chmod +x /tmp/NVIDIA-Linux-x86_64-530.41.03.run
  $STD /tmp/NVIDIA-Linux-x86_64-530.41.03.run --check
  $STD /tmp/NVIDIA-Linux-x86_64-530.41.03.run --no-kernel-module --silent
  msg_ok "Set Up Hardware Acceleration"
fi

msg_info "Setting Up Plex Media Server Repository"
$STD apt-key add <(curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key)
sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://downloads.plex.tv/repo/deb/ public main" > /etc/apt/sources.list.d/plexmediaserver.list'
msg_ok "Set Up Plex Media Server Repository"

msg_info "Installing Plex Media Server"
$STD apt-get update
$STD apt-get -o Dpkg::Options::="--force-confold" install -y plexmediaserver
msg_ok "Installed Plex Media Server"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
