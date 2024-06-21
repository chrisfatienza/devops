#!/bin/sh
#  check switch port speed setting for Solaris sparc
#
PATH=/usr/sbin:/usr/local/sbin:$PATH
export PATH
echo "Available interfaces are"
netstat -i | egrep -v "^Name|^lo0|^Kernel|^Iface|^lo" | awk '{ print $1 }' | cut -d: -f1 | sort | uniq
 
  if [ "$1" != '' ]; then
    INTERFACE=`echo $1`
    tcpdump -nn -v -i $INTERFACE -s 1500 -c 1 'ether[20:2] == 0x2000' |grep length |grep -v AVV |grep -v unknown > /tmp/cdp.$INTERFACE
    DUPLEX=`grep -w Duplex /tmp/cdp.$INTERFACE | cut -f3 -d ":"`
    PORTINFO=`grep -w Port /tmp/cdp.$INTERFACE | cut -f3 -d ":"|cut -f2 -d"'"`
    PORT_TYPE=`echo $PORTINFO| tr -d '[0-9]'|cut -f1 -d"/"`
    PORT_NUM=`echo $PORTINFO |tr -d '[a-z]'|tr -d '[A-Z]'`
    VLAN=`grep -w VLAN /tmp/cdp.$INTERFACE | cut -f3 -d ":"`
    SWITCH=`grep -w Device /tmp/cdp.$INTERFACE | cut -f3 -d ":"|cut -f2 -d "'"`
    MODEL=`grep -w Platform /tmp/cdp.$INTERFACE | cut -f3 -d ":"|cut -f2 -d "'"`
    IPADDR=`grep -w Address /tmp/cdp.$INTERFACE | cut -f3 -d ":"|awk '{print $3}'`
    echo "SWITCH    = "$SWITCH
    echo "MODEL     = "$MODEL
    echo "IPADDR    = "$IPADDR
    echo "VLAN      ="$VLAN
    echo "PORT TYPE = "$PORT_TYPE
    echo "PORT      = "$PORT_NUM
    echo "DUPLEX    ="$DUPLEX
    rm /tmp/cdp.$INTERFACE
  else
    echo "Usage: `basename "$0"` {hme0|bge0|dmfe0|ce0|qfe0|eth0}"
    exit 0
  fi
