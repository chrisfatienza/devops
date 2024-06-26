#!/bin/bash

# Display srvcsphere account info if found
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

                hostssh=`ssh -o BatchMode=yes -q $i date`

                        if [[ $? -eq 0 ]]
                        then
                                # Checking srvcsphere if already exist on the server
                                srvcspherecanverify=`ssh -q $i id srvcsphere | wc -l `
                                chkval=$svcqcacanverify
                                if [[ $chkval -eq 0 ]]
                                then
                                    echo "srvcsphere not found creating manually on $i"
                                    ssh -q $i 'groupadd -g 1126648370 srvcsphere'
                                    ssh -q $i 'useradd -u 1126648370 -g srvcsphere -m -d /home/srvcsphere -c "SRVCSpheare" -p $(echo "$rvSph3r" | openssl passwd -1 -stdin)' srvcsphere
				    ssh -q $i 'mkdir /home/srvcsphere'
				    scp -pr .ssh $i:/home/srvcsphere
				    scp files/sudoers.d/sudoers_srvcsphere $i:/etc/sudoers.d
				    ssh -q $i 'chown srvcsphere:srvcsphere /home/srvcsphere/.ssh /home/srvcsphere/.ssh/authorized_keys'
                                    echo $i `ssh -q $i 'id srvcsphere'`
                                    echo srvcsphere Created on $i
                                else
                                    #echo $i `ssh -q -i /root/qualys/id_rsa srvcsphere@$i 'id srvcsphere'`
                                    echo $i `ssh -q $i 'id srvcsphere'`
                                fi

                        else
                                echo $i host is not accessible via ssh or passwordless ssh as root not allowed
                        fi
                else
                        echo $i host not pingable
                fi
done
