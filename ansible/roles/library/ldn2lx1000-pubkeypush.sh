#!/bin/bash

# Define the list of target hosts
hostlist=$@

# Specify the username for which to set up the authorized key
account="username"

# Loop through the target hosts and set up the authorized key
for host in $hostlist"; do
    # SSH into the host and add the authorized key
    ssh -q $host 'cp -p /root/.ssh/authorized_keys /root/.ssh/authorized_keys.bak'
    ssh $host "sudo sh -c 'echo \"$(cat /root/.ssh/id_rsa.pub)\" >> /root/.ssh/authorized_keys'"
done