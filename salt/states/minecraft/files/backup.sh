#!/bin/bash

IP={% if grains['os_family'] == 'RedHat' %}{{ grains['ip4_interfaces']['eth0'][0] }}{% elif grains['os_family'] == 'Arch' %}{{ grains['ipv4'][0] }}{% endif %}

if systemctl is-active --quiet minecraft; then
	~minecraft/bin/rcon.py 'say "Starging backup..."' $IP
	~minecraft/bin/rcon.py 'save-off' $IP
fi

pushd ~minecraft

tar -zcf "backup/world.$(date -u +"%Y-%m-%dT%H:%M:%S%Z").tar.gz" world

pushd backup
# Keep only 5 backups
ls -tp | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}
popd

rclone sync backup GoogleDrive:backup

popd

if systemctl is-active --quiet minecraft; then
	~minecraft/bin/rcon.py 'save-on' $IP
	~minecraft/bin/rcon.py 'save-all' $IP
fi

