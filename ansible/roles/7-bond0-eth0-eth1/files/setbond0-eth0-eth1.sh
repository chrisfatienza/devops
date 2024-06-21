#!/bin/bash

for i in eth0 eth1
do 
	echo $i
	cat /tmp/bond-ethdefault | sed "s/ETHDEV/$i/g" > /etc/sysconfig/network-scripts/ifcfg-$i
done

#cat /tmp/bond-bond0default |sed "s/hostIP/`hostname -I | awk '{print $1}'`/g" | sed "s/hostGW/`hostname -I | awk '{print $1}' | cut -d "." -f 1-3`/g" | sed "s/ethMAC/`ip a s dev eth0 |grep "link/ether" > /etc/sysconfig/network-scripts/ifcfg-bond0

cat /tmp/bond-bond0default |sed "s/hostIP/`hostname -I | awk '{print $1}'`/g" | sed "s/hostGW/`hostname -I | cut -d \. -f 1-3 | awk '{print $1}'`/g" > /etc/sysconfig/network-scripts/ifcfg-bond0

ip a s
