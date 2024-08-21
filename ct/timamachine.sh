#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/matteocrippa/Proxmox/feature/timemachine/misc/build.func)
# Copyright (c) 2024 tteck, matteocrippa
# License: MIT
# https://github.com/matteocrippa/Proxmox/LICENSE

function header_info {
clear
cat <<"EOF"
  _______                __  ___           __    _          
 /_  __(_)___ ___  ___  /  |/  /___ ______/ /_  (_)___  ___ 
  / / / / __ `__ \/ _ \/ /|_/ / __ `/ ___/ __ \/ / __ \/ _ \
 / / / / / / / / /  __/ /  / / /_/ / /__/ / / / / / / /  __/
/_/ /_/_/ /_/ /_/\___/_/  /_/\__,_/\___/_/ /_/_/_/ /_/\___/ 
                                                            
EOF
}
header_info
echo -e "Loading..."
APP="TimeMachine"
var_disk="2"
var_cpu="1"
var_ram="1024"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

# function edit_shared_folder() {
# header_info
# echo "Editing the Time Machine shared folder..."

# read -p "Enter the new mount point (e.g., /mnt/pxe): " new_mount
# if [ -d "$new_mount" ]; then
#     sed -i "s|/srv/samba/timemachine|$new_mount|g" /etc/samba/smb.conf
#     mkdir -p "$new_mount"
#     chown -R timemachine:timemachine "$new_mount"
#     systemctl restart smbd
#     msg_ok "Updated shared folder path to $new_mount"
# else
#     msg_error "Directory $new_mount does not exist."
# fi
# }

function update_script() {
header_info
if [[ ! -d /srv/samba/timemachine ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}smb://${IP}/TimeMachine${CL} \n"
