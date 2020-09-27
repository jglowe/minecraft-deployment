#!/bin/env python3

import argparse
from srcds.rcon import RconConnection

def send_command(command: str, ip: str, port : int, password: str):
    connection = RconConnection(ip, port=port, password=password, single_packet_mode=True)
    response = connection.exec_command(command)
    print(response)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run rcon commands to minecraft')

    parser.add_argument('command', type=str, help='The command to send')
    parser.add_argument('ip', type=str, help='The IP the server is being served with')
    parser.add_argument('--port', type=int, help='The rcon port', default=25575)
    parser.add_argument('--password', type=str, help='The rcon password',
                         default="does_not_matter_because_firewall_blocks_incoming_connections")

    args = parser.parse_args()
    send_command(args.command, args.ip, args.port, args.password)
