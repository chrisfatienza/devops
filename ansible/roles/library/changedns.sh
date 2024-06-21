#!/usr/bin/env bash

usage(){
  echo "Usage: $0 <remote_host> <ip_mapping_file>"
  echo "  remote_host: hostname or IP address of the remote host"
  echo "  ip_mapping_file: path to the IP mapping file"
  exit 1
}

help(){
  echo "This script updates the nameserver entries in /etc/resolv.conf on a remote host"
  echo ""
  echo "Arguments:"
  echo "  -h, --help  show this help message and exit"
  usage
}

if [ $# -ne 2 ]; then
  usage
fi

#while [[ $# -gt 0 ]]; do
# case "$1" in
while getopts 'h' OPTION; do
    case "$OPTION" in
    	h)
      		help
      		;;
    	*)
      		break
      		;;
    esac
done
:
remote_host=$1
ip_mapping_file=$2

if [ ! -f $ip_mapping_file ]; then
  echo "Error: IP mapping file $ip_mapping_file not found"
  usage
fi

if ! ping -c 1 $remote_host > /dev/null 2>&1; then
  echo "Error: Host $remote_host is not accessible"
  exit 1
fi

if ! ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no $remote_host true > /dev/null 2>&1; then
  echo "Error: Unable to connect to host $remote_host"
  exit 1
fi

while read -r old_ip new_ip; do
  if ! ssh $remote_host sed -i "s/$old_ip/$new_ip/g" /etc/resolv.conf > /dev/null 2>&1; then
    echo "Error: Unable to replace $old_ip with $new_ip on $remote_host"
  else
    echo "Replaced $old_ip with $new_ip on $remote_host"
  fi
done < "$ip_mapping_file"
