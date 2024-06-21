#!/usr/bin/env python3

import sys
import socket
import ipaddress
import subprocess

def is_valid_ip(address):
    try:
        ipaddress.ip_address(address)
        return True
    except ValueError:
        return False

def get_system_hostname():
    try:
        return subprocess.check_output(['uname', '-n'], universal_newlines=True).strip()
    except subprocess.CalledProcessError:
        return None

def check_dns_resolution(hostname, nameservers):
    working_nameservers = []
    not_working_nameservers = []
    invalid_nameservers = []

    for nameserver in nameservers:
        parts = nameserver.split("#")
        ip_address = parts[0].strip()

        if not ip_address:
            continue

        if not is_valid_ip(ip_address):
            invalid_nameservers.append(nameserver)
            continue

        try:
            socket.create_connection((ip_address, 53), timeout=5)
            socket.gethostbyname(hostname)
            working_nameservers.append(ip_address)
        except (socket.error, OSError):
            not_working_nameservers.append(ip_address)

    if not invalid_nameservers and not not_working_nameservers:
        return 0, f"OK - {len(working_nameservers)}/{len(nameservers)} nameserver(s) is/are working: {', '.join(working_nameservers)}"

    message = []
    if invalid_nameservers:
        message.append(f"{len(invalid_nameservers)}/{len(nameservers)} nameserver(s) are not valid: {', '.join(invalid_nameservers)}")
    if not_working_nameservers:
        message.append(f"CRITICAL - {len(not_working_nameservers)}/{len(nameservers)} nameserver(s) are not reachable: {', '.join(not_working_nameservers)}")
    if working_nameservers:
        message.append(f"OK - {len(working_nameservers)}/{len(nameservers)} nameserver(s) is/are working: {', '.join(working_nameservers)}")

    return 2, "WARNING - " + '\n'.join(message)

def get_nameservers():
    nameservers = []
    try:
        with open('/etc/resolv.conf', 'r') as file:
            for line in file:
                line = line.strip()
                if line.startswith('nameserver') and '#' in line:
                    parts = line.split('#')[0].split()
                    if len(parts) == 2:
                        nameservers.append(parts[1])
                elif line.startswith('nameserver') and not line.startswith('#'):
                    parts = line.split()
                    if len(parts) == 2:
                        nameservers.append(parts[1])

    except FileNotFoundError:
        pass  # Handle the case where /etc/resolv.conf doesn't exist
    return nameservers

if __name__ == '__main__':
    if len(sys.argv) == 2:
        hostname = sys.argv[1]
    else:
        hostname = get_system_hostname()
        if not hostname:
            print("CRITICAL - Unable to obtain system hostname.")
            sys.exit(2)

    nameservers = get_nameservers()

    if not nameservers:
        print("CRITICAL - No nameservers found in /etc/resolv.conf")
        sys.exit(2)

    status, message = check_dns_resolution(hostname, nameservers)
    print(message)
    sys.exit(status)

