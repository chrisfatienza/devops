# This script will bulk ssh-key progation
#Author: Christopher Atienza

#Usage: /root/cfgmain/library/bulksshkeyusers.sh file1...

# Sample list
#
# file location: /root/cfgmain/bulk/<file>
# Content
# ldn2lx0131 srvctss2
# ldn2lx0134 svcqca
# ldn2lx0131 svcqca
# ldn2lx0134 srvctss2


bulklist=$@
bulklistfiler=`echo $bulklist | tr " " '\n' | sort | uniq |  tr '\n' " "`

hostheader=/root/cfgmain/bulk/hostheader

bulklistArray=( $bulklistfiler )

for i in ${!bulklistArray[@]} ; do

  echo Checking if file exist "element $i is ${bulklistArray[$i]}":
  
# Condition to check if server file and users exist
  if [ -f "${bulklistArray[$i]}" ]; then
	echo "${bulklistArray[$i]} exist with the following users:"

	for f in `cat ${bulklistArray[$i]} | awk '{print $2}'` ; do
		echo $f
	done | sort | uniq > ${bulklistArray[$i]}.user

	for user in `cat ${bulklistArray[$i]}.user` ; do
		usvrpath=/root/cfgmain/bulk/
		cat $hostheader > $usvrpath$user.svr
		grep $user ${bulklistArray[$i]} | awk '{print $1}' >> $usvrpath$user.svr
		echo
		ls $usvrpath$user.svr
		cat $usvrpath$user.svr

		ansible-playbook -i $usvrpath$user.svr /root/cfgmain/library/pushsshkey.yml --extra-vars "account=$user"
	done

  else
	echo "${bulklistArray[$i]} doest not exist"
  fi
	echo
done
