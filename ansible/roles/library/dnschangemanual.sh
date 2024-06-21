#!/usr/bin/bash

#Backup existing /etc/resolve.conf

host=$@

for i in $host
do
	back1st=`ssh -q $i 'cp -pn /etc/resolv.conf /etc/resolv.conf.CHG0116440'`
	echo Checking server $i:
		for f in 10.1.43.186 10.1.59.12 10.1.43.196 10.1.24.104 10.1.43.193 10.1.59.11 10.1.59.13 10.137.36.31 10.137.36.33 10.137.36.32 10.137.36.18 10.137.36.19
		do
			echo $f
			chkhostDNS=`ssh -q $i "cat /etc/resolv.conf |grep $f" |awk '{print $2}'`

				if [[ $chkhostDNS == '10.1.43.186' ]] || [[ $chkhostDNS == 10.1.59.12 ]] || [[ $chkhostDNS == '10.1.43.196' ]] || [[ $chkhostDNS == 10.1.24.104 ]]
				then
					DNSIP="10.160.72.83"
					echo $chkhostDNS new DNS UP is $DNSIP
					ssh -q $i 'sed -i 's/$f/$DNSIP/'g /etc/resolv.conf'
				else
					if [[ $chkhostDNS == '10.1.43.193' ]] || [[ $chkhostDNS == '10.1.59.11' ]] || [[ $chkhostDNS == '10.1.59.13' ]]
                                        then
						DNSIP="10.161.72.28"
						echo $chkhostDNS new DNS IP is $DNSIP
                                                ssh -q $i 'sed -i 's/$f/$DNSIP/'g /etc/resolv.conf'
                                        else
                                               	if [[ $chkhostDNS == '10.137.36.31' ]] || [[ $chkhostDNS == '10.137.36.33' ]]
						then
							DNSIP="10.161.72.10"
							echo $chkhostDNS new DNS IP is $DNSIP
                                                       	ssh -q $i 'sed -i 's/$f/$DNSIP/'g /etc/resolv.conf'
						else
							if [[ $chkhostDNS == '10.137.36.32' ]]
							then
								DNSIP="10.160.72.10"
                                                        	echo $chkhostDNS new DNS IP is $DNSIP
                                                        	ssh -q $i 'sed -i 's/$f/$DNSIP/'g /etc/resolv.conf'
							else
                                                       		if [[ $chkhostDNS == '10.137.36.18' ]]
                                                        	then
                                                                	DNSIP="10.160.72.84"
                                                                	echo $chkhostDNS new DNS IP is $DNSIP
                                                                	ssh -q $i 'sed -i 's/$f/$DNSIP/'g /etc/resolv.conf'
								else
									if [[ $chkhostDNS == '10.137.36.19' ]]
                                                                	then
                                                                        	DNSIP="10.161.72.29"
                                                                        	echo $chkhostDNS new DNS IP is $DNSIP
                                                                        	ssh -q $i "sed -i 's/$f/$DNSIP/'g /etc/resolv.conf"
                                                       	 		else
										echo $chkhostDNS not found
									fi
								fi
							fi
						fi
					fi
				fi
		done
done
