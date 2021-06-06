# {% if grains['os_family'] == 'RedHat' %}
# epel-release:
#   pkg.installed:
#     - name: epel-release
# {% endif %}

cronie:
  pkg:
    - installed

polkit:
  pkg:
    - installed

java:
  pkg.installed:
    {% if grains['os_family'] == 'RedHat' %}
    - name: java-1.8.0-openjdk-headless
    {% elif grains['os_family'] == 'Arch' %}
    - name: jre8-openjdk-headless
    {% endif %}

pysrcds:
  pip:
    - installed

rclone:
  pkg:
    - installed

minecraft:
  group:
    - present
  user.present:
    - shell: /bin/bash
    - home: /home/minecraft
    - groups:
      - minecraft

download minecraft:
  file.managed:
    - name: ~minecraft/minecraft_server_{{ pillar['minecraft_version'] }}.jar
    - source: {{ salt['minecraft_server_data.url'](pillar['minecraft_version']) }}
    - source_hash: {{ salt['minecraft_server_data.hash'](pillar['minecraft_version']) }}

/usr/lib/systemd/system/minecraft.service:
  file.managed:
    - source: salt://minecraft/files/minecraft.service.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja

# Allows the minecraft user to manage the minecraft.service
/etc/polkit-1/rules.d/48-manage-minecraft.rules:
  file.managed:
    - source: salt://minecraft/files/48-manage-minecraft.rules
    - user: root
    - group: root
    - mode: 644

~minecraft/bin:
  file.directory:
    - user: minecraft
    - group: minecraft
    - dir_mode: 755
    - file_mode: 644

~minecraft/backup:
  file.directory:
    - user: minecraft
    - group: minecraft
    - dir_mode: 755
    - file_mode: 644

~minecraft/bin/rcon.py:
  file.managed:
    - source: salt://minecraft/files/rcon.py
    - user: minecraft
    - group: minecraft
    - mode: 755

~minecraft/bin/backup.sh:
  file.managed:
    - source: salt://minecraft/files/backup.sh
    - user: minecraft
    - group: minecraft
    - mode: 755
    - template: jinja

~minecraft/eula.txt:
  file.managed:
    - source: salt://minecraft/files/eula.txt
    - user: minecraft
    - group: minecraft

~minecraft/server.properties:
  file.managed:
    - source: salt://minecraft/files/server.properties.j2
    - user: minecraft
    - group: minecraft
    - mode: 644
    - template: jinja

~minecraft/ops.json:
  file.managed:
    - contents: {{ pillar['ops'] | json | json }}
    - user: minecraft
    - group: minecraft
    - mode: 644
    - renderer: json

~minecraft/whitelist.json:
  file.managed:
    - contents: {{ pillar['whitelist'] | json | json }}
    - user: minecraft
    - group: minecraft
    - mode: 644
    - renderer: json

backup cron:
  cron.present:
    - name: ~minecraft/bin/backup.sh
    - user: minecraft
    - hour: 1
    - minute: 0

minecraft service:
  service.running:
    - name: minecraft
    - enable: True
    - reload: True
    - int_delay: 60
    - require:
      - user: minecraft
      - group: minecraft

      {% if grains['os_family'] == 'RedHat' %}
      - pkg: java-1.8.0-openjdk-headless
      {% elif grains['os_family'] == 'Arch' %}
      - pkg: jre8-openjdk-headless
      {% endif %}

      - file: /usr/lib/systemd/system/minecraft.service
      - file: ~minecraft/server.properties
      - file: ~minecraft/ops.json
      - file: ~minecraft/whitelist.json
      - file: ~minecraft/minecraft_server_{{ pillar['minecraft_version'] }}.jar

    - watch:
      - file: /usr/lib/systemd/system/minecraft.service
      - file: ~minecraft/server.properties
      - file: ~minecraft/ops.json
      - file: ~minecraft/whitelist.json
      - file: ~minecraft/minecraft_server_{{ pillar['minecraft_version'] }}.jar

