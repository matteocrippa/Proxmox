#!/usr/bin/env bash

# Copyright (c) 2024 tteck, matteocrippa
# License: MIT
# https://github.com/matteocrippa/Proxmox/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y samba avahi-daemon
msg_ok "Installed Dependencies"

msg_info "Configuring Samba for Time Machine"
# Create a backup user and group
useradd -M -d /nonexistent -s /usr/sbin/nologin timemachine
(echo "password"; echo "password") | smbpasswd -a -s timemachine

# Create a Time Machine share directory
mkdir -p /srv/samba/timemachine
chown -R timemachine:timemachine /srv/samba/timemachine

# Backup the original smb.conf file
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Add Samba configuration for Time Machine
cat <<EOF >> /etc/samba/smb.conf
[TimeMachine]
    path = /srv/samba/timemachine
    valid users = timemachine
    browsable = yes
    read only = no
    create mask = 0700
    directory mask = 0700
    spotlight = yes
    vfs objects = fruit streams_xattr
    fruit:time machine = yes
    fruit:encoding = native
    fruit:metadata = stream
    fruit:resource = file
EOF

# Restart Samba service to apply changes
systemctl restart smbd
msg_ok "Configured Samba for Time Machine"

msg_info "Configuring Avahi for network discovery"
cat <<EOF > /etc/avahi/services/timemachine.service
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
    <name replace-wildcards="yes">TimeMachine on %h</name>
    <service>
        <type>_afpovertcp._tcp</type>
        <port>548</port>
    </service>
    <service>
        <type>_smb._tcp</type>
        <port>445</port>
    </service>
</service-group>
EOF

systemctl restart avahi-daemon
msg_ok "Configured Avahi for network discovery"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
