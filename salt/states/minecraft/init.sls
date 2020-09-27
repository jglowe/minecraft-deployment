java:
  pkg.installed:
    {% if grains['os_family'] == 'RedHat' %}
    - name: java-1.8.0-openjdk-headless
    {% elif grains['os_family'] == 'Arch' %}
    - name: jre8-openjdk-headless
    {% endif %}

jq:
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

  service.running:
    - enable: True
    - reload: True
    - int_delay: 20 
    - require:
      - user: minecraft
      - group: minecraft

      {% if grains['os_family'] == 'RedHat' %}
      - pkg: java-1.8.0-openjdk-headless
      {% elif grains['os_family'] == 'Arch' %}
      - pkg: jre8-openjdk-headless
      {% endif %}

      - file: /usr/lib/systemd/system/minecraft.service
      - file: /home/minecraft/server.properties
      - file: /home/minecraft/ops.json
      - file: /home/minecraft/whitelist.json
      - file: /home/minecraft/minecraft_server_{{ pillar['minecraft_version'] }}.jar

    - watch:
      - file: /usr/lib/systemd/system/minecraft.service
      - file: /home/minecraft/server.properties
      - file: /home/minecraft/ops.json
      - file: /home/minecraft/whitelist.json
      - file: /home/minecraft/minecraft_server_{{ pillar['minecraft_version'] }}.jar

download minecraft:
  file.managed:
    - name: /home/minecraft/minecraft_server_{{ pillar['minecraft_version'] }}.jar
    - source: {{ salt['minecraft_server_data.url'](pillar['minecraft_version']) }}
    - source_hash: {{ salt['minecraft_server_data.hash'](pillar['minecraft_version']) }}

/usr/lib/systemd/system/minecraft.service:
  file.managed:
    - source: salt://minecraft/files/minecraft.service.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/home/minecraft/eula.txt:
  file.managed:
    - source: salt://minecraft/files/eula.txt
    - user: minecraft
    - group: minecraft

/home/minecraft/server.properties:
  file.managed:
    - source: salt://minecraft/files/server.properties.j2
    - user: minecraft
    - group: minecraft
    - mode: 644
    - template: jinja

/home/minecraft/ops.json:
  file.managed:
    - contents: {{ pillar['ops'] }}
    - user: minecraft
    - group: minecraft
    - mode: 644
    - renderer: json

/home/minecraft/whitelist.json:
  file.managed:
    - contents: "{{ pillar['whitelist'] }}"
    - user: minecraft
    - group: minecraft
    - mode: 644
    - renderer: json

