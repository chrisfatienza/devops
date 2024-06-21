#!/bin/bash

# Display secscan-a account info if found
# Add qualys account automatically if not found
# Check if server is accessible via ssh as root or if server is pingable
# Exit if password prompt found during ssh (quickie exit to move to the next server)
# Filter if server or IP resolvable

host=$@
for i in $host
do
        #echo Checking if $i is pingable
        hostchk=`ping -c1 $i`
                if [[ $? -eq 0 ]]
                then

                hostssh=`ssh -o BatchMode=yes -o StrictHostKeyChecking=no -q $i date`

                        if [[ $? -eq 0 ]]
                        then
				echo $i: `ssh -q $i  'cat /etc/resolv.conf |egrep -v "^#"'` 
                        else
                                echo $i: host is not accessible via ssh or passwordless ssh as root not allowed
                        fi
                else
                        echo $i: host not pingable
                fi
done
