#! /bin/bash
# ----------------------------------------------------------------------
# Filename: update_motd.sh
# ----------------------------------------------------------------------
# Created by: David Stedman
# Creation Date: 08 Jan 2020
# ----------------------------------------------------------------------
# Description: Update /etc/motd with details from the A2RM CMDB
# ----------------------------------------------------------------------
# Usage: update_motd.sh
#
#
# ----------------------------------------------------------------------
# Calls:
#
#
# ----------------------------------------------------------------------
# Called by: cron or systemd timer
#
# ----------------------------------------------------------------------
# CHANGE HISTORY:
# ----------------------------------------------------------------------
# DATE(dd/mm/ccyy) BY(login)      Nature of Change (+ Change request no)
# ----------------------------------------------------------------------
#  08/01/2020      dstedman-a      Initial version
#  20/01/2020     dstedman-a      Migrated to direct URL for a2rm
# ----------------------------------------------------------------------
# Setup Variables
# ----------------------------------------------------------------------

# The following should be Solaris-proof:
CHOST=`uname -n | cut -f1 -d '.'`

# Temp files for the output from A2RM
HTMP=/tmp/host_motd_$$
MTMP=/tmp/new_motd_$$
ATMP=/tmp/app_motd_$$
APTMP=/tmp/app_par_motd_$$

DE_CMD="grep -qi "derived_environment\":" ${HTMP}"
AI_CMD="grep -qi "app_instances\":"  ${HTMP}"
LN_CMD="grep -qi "building\":" ${HTMP}"
OS_CMD="grep -qi "os\":" ${HTMP}"
OSVER_CMD="grep -qi "osver\":" ${HTMP}"
RAM_CMD="grep -qi "ram\":" ${HTMP}"
CPU_CMD="grep -qi "cpucount\":" ${HTMP}"
CPU_CORE_CMD="grep -qi "cpucore\":" ${HTMP}"
SER_CMD="grep -qi "serial_no\":" ${HTMP}"

CRIT_CMD="grep -qi "criticality\":" ${APTMP}" 
APP_CMD="grep -qi "\"application_name\"\:" ${ATMP}" 
BUS_CMD="grep -qi "business_owner\":" ${ATMP}" 
SUP_CMD="grep -qi "support_team\":" ${ATMP}" 
DL_CMD="grep -qi "support_team_dl\":" ${ATMP}" 

IS_ORPHAN=0

MOTD="/etc/motd"
MOTD_LAST="/etc/motd.last"


# ----------------------------------------------------------------------
# LOG functions
# ----------------------------------------------------------------------


LOG_DATE() {
echo "`date +%Y%m%d-%H:%M:%S`:$@" >> /root/update_motd.log
}

LOG_INFO() {
LOG_DATE "INFO: $@"
}

LOG_ERROR() {
LOG_DATE "ERROR: $@"
}

# ----------------------------------------------------------------------
# Write to new motd file
# ----------------------------------------------------------------------
WRITE_TMP() {
	echo "$@" >> $MTMP
}

# ----------------------------------------------------------------------
# Function to encode spaces etc for querying the application_instances API
# ----------------------------------------------------------------------
urlencode() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-\w]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}

# ----------------------------------------------------------------------
# Get the details for an application instance
# ----------------------------------------------------------------------
get_app_details() {
 		 aname=`urlencode "${HAPP}"`
#  		 echo ${aname}
  		 curl --connect-timeout 10 -s -X GET -u 'readonly:readonly' https://api.a2rm.tpicapcloud.com/app/application_instances?name=${aname} | python -m json.tool > ${ATMP}


		$APP_CMD
		if [ $? -eq 0 ]
       		 	then
				APP_PAR=`grep -i "\"application_name\"\:" ${ATMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`
				LOG_INFO "Found parent application name ${APP_PAR} for ${HAPP}"
 		 		parname=`urlencode "${APP_PAR}"`
#				echo ${parname}
  		 		curl --connect-timeout 10 -s -X GET -u 'readonly:readonly' https://api.a2rm.tpicapcloud.com/app/application?name=${parname} | python -m json.tool > ${APTMP}
				$CRIT_CMD
				if [ $? -eq 0 ]
		       		 	then
						APP_PAR_CRIT=`grep -i "\"criticality\"\:" ${APTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`
						LOG_INFO "Found parent app criticality ${APP_PAR_CRIT} for ${HAPP}"
					else
						LOG_ERROR "Did not find parent application criticality for ${HAPP}"
				fi	
		
		else
			LOG_ERROR "Did not find parent application for ${HAPP}"
		fi	

		$BUS_CMD
		if [ $? -eq 0 ]
       		 	then
				APP_BUS=`grep -i "\"business_owner\"\:" ${ATMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`
				LOG_INFO "Found business owner ${APP_BUS} for ${HAPP}"
		else
			LOG_ERROR "Did not find business owner for ${HAPP}"
		fi	

		$SUP_CMD
		if [ $? -eq 0 ]
       		 	then
				APP_SUP=`grep -i "\"support_team\"\:" ${ATMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`
				LOG_INFO "Found support team ${APP_SUP} for ${HAPP}"
		else
			LOG_ERROR "Did not find support team for ${HAPP}"
		fi	

		$DL_CMD
		if [ $? -eq 0 ]
       		 	then
				APP_SUP_DL=`grep -i "\"support_team_dl\"\:" ${ATMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] |  sed s/^' '//`
				LOG_INFO "Found support team DL ${APP_SUP_DL} for ${HAPP}"
		else
			LOG_ERROR "Did not find support team DL for ${HAPP}"
		fi	

	        WRITE_TMP "- ${HAPP} (${APP_PAR_CRIT} criticality), supported by ${APP_SUP} (${APP_SUP_DL})"

}
# ----------------------------------------------------------------------
# Get the Application Instances for the host
# ----------------------------------------------------------------------
get_apps() {

	$AI_CMD
	if [ $? -eq 0 ]
		then
			HOST_APP=`grep -i "app_instances" ${HTMP} | cut -f2 -d ':'`
			IFS=',' read -r -a APP_ARR <<< "${HOST_APP}"
			if [ ${#APP_ARR[@]} -gt 0 ]
				then
					
					for a in "${APP_ARR[@]}"
						do
						    HAPP=`echo $a | tr -d '\''"' |  sed s/^' '//`
#				                    echo $HAPP	
						    if [[ $HAPP =~ "None" ]]
							then
								LOG_INFO "Host ${CHOST} is an orphan"	
								IS_ORPHAN=1
						    	else
								LOG_INFO "Found application $HAPP for ${CHOST}"
			                			WRITE_TMP "This system is currently used by these apps:"
						   		 get_app_details
						     fi
					done
				else
					LOG_INFO "Host ${CHOST} is an orphan"
					IS_ORPHAN=1
			fi


		else
			LOG_ERROR "Command to find applications for ${CHOST} failed"
	fi

}

# ----------------------------------------------------------------------
# Get the Derived Environment for the host
# ----------------------------------------------------------------------
get_de() {

	$DE_CMD
	if [ $? -eq 0 ]
        	then
		HOST_DE=`grep -i "derived_environment\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`
		LOG_INFO "Found environment ${HOST_DE} for ${CHOST}"
		
	else
		LOG_ERROR "Did not find environment for ${CHOST}"
	fi	

}

# ----------------------------------------------------------------------
# Get the location for the host
# ----------------------------------------------------------------------
get_loc() {

	$LN_CMD
	if [ $? -eq 0 ]
        	then
		HOST_LN=`grep -i "building\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`

		if [[ ${HOST_LN} =~ "empty" ]]
			then
				HOST_LN=`echo empty | tr '[:lower:]' '[:upper:]'`
		fi

		LOG_INFO "Found location ${HOST_LN} for ${CHOST}"
		
	else
		LOG_ERROR "Did not find location for ${CHOST}"
	fi	

}

# ----------------------------------------------------------------------
# Get the os for the host
# ----------------------------------------------------------------------
get_os() {

	$OS_CMD
	if [ $? -eq 0 ]
        	then
		HOST_OS=`grep -i "os\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}] | sed s/^' '//`
		LOG_INFO "Found OS ${HOST_OS} for ${CHOST}"
		
	else
		LOG_ERROR "Did not find OS for ${CHOST}"
	fi	

}

# ----------------------------------------------------------------------
# Get the os version for the host
# ----------------------------------------------------------------------
get_os_ver() {

	$OSVER_CMD
	if [ $? -eq 0 ]
        	then
		HOST_OSVER=`grep -i "osver\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}]`
		LOG_INFO "Found OS version ${HOST_OSVER} for ${CHOST}"
		
	else
		LOG_ERROR "Did not find OS version for ${CHOST}"
	fi	

}
# ----------------------------------------------------------------------
# Get the cpu count for the host
# ----------------------------------------------------------------------
get_cpu_cnt() {

	$CPU_CMD
	if [ $? -eq 0 ]
        	then
		HOST_CPU_CNT=`grep -i "cpucount\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}]`
		LOG_INFO "Found ${HOST_CPU_CNT} CPUS for ${CHOST}"
		
	else
		LOG_ERROR "Did not find the CPU count for ${CHOST}"
	fi	

}
# ----------------------------------------------------------------------
# Get the cpu core count for the host
# ----------------------------------------------------------------------
get_cpucore_cnt() {

	$CPU_CORE_CMD
	if [ $? -eq 0 ]
        	then
		HOST_CORE_CNT=`grep -i "cpucore\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}]`
		LOG_INFO "Found ${HOST_CORE_CNT} CPU cores per CPU for ${CHOST}"
		
	else
		LOG_ERROR "Did not find the CPU core count for ${CHOST}"
	fi	

}
# ----------------------------------------------------------------------
# Check if the host is recorded as VMWARE in A2RM
# ----------------------------------------------------------------------
get_is_vm() {

	$SER_CMD
	if [ $? -eq 0 ]
        	then
		HOST_SER=`grep -i "serial_no\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}]`
		LOG_INFO "Found serial number ${HOST_SER} for ${CHOST}"
		H_SER=`echo ${HOST_SER} | sed s/' '//g`
		if [[ ${H_SER} =~ "VMWARE" ]]
			then
				LOG_INFO "Host ${CHOST} is a VMWARE virtual machine"
	                        WRITE_TMP "This is a VMware virtual machine."
		fi
		
	else
		LOG_ERROR "Did not find serial number details for ${CHOST}"
	fi	

}
# ----------------------------------------------------------------------
# Get the memory for the host
# This isnt a great check as RAM can be recorded with GB or MB unit of measure in Device42
# ----------------------------------------------------------------------
get_os_ram() {

	$RAM_CMD
	if [ $? -eq 0 ]
        	then
		HOST_RAM=`grep -i "ram\":" ${HTMP} | cut -f2 -d ':' | tr -d [\"\,\{\}]`
		LOG_INFO "Found ${HOST_RAM} GB memory for ${CHOST}"
		
	else
		LOG_ERROR "Did not find memory details for ${CHOST}"
	fi	

}
# ----------------------------------------------------------------------
# Cleanup temp files
# ----------------------------------------------------------------------
cleanup() {

if [ -f ${HTMP} ]
	then
		rm -f ${HTMP}
fi

if [ -f ${ATMP} ]
	then
		rm -f ${ATMP}
fi

if [ -f ${APTMP} ]
	then
		rm -f ${APTMP}
fi

}
# ----------------------------------------------------------------------
# Install the new motd
# ----------------------------------------------------------------------
install_motd() {

if [ -f ${MTMP} ]
	then
		mv ${MOTD} ${MOTD_LAST}
		mv ${MTMP} ${MOTD}
fi


}
# ----------------------------------------------------------------------
# Test connection to A2RM
# ----------------------------------------------------------------------
test_a2rm() {

HTTP_CODE=`curl -X GET -u 'readonly:readonly' -o /dev/null -I -L -s -w "%{http_code}" "https://api.a2rm.direct.tpicapcloud.com/host/${CHOST}?report=appd"`

if [ ${HTTP_CODE} -ne 200 ]
	then
		LOG_INFO "Unabled to connect to A2RM API. EXIT"
		exit 1
fi

}
# ----------------------------------------------------------------------
# MAIN SECTION
# ----------------------------------------------------------------------

if [ -f /root/update_motd.log ]
	then
		rm -f /root/update_motd.log
fi

test_a2rm


WRITE_TMP ""
WRITE_TMP "========== START OF CMDB DETAILS FOR HOST ==========="
WRITE_TMP ""


LOG_INFO "Collecting CMDB data from A2RM to ${HTMP}"

curl --connect-timeout 10 -s -X GET -u 'readonly:readonly' https://api.a2rm.direct.tpicapcloud.com/host/$CHOST |  python -m json.tool > ${HTMP}

get_de
get_loc
get_os
get_os_ver 
get_cpu_cnt
get_cpucore_cnt
get_os_ram

WRITE_TMP "This is a ${HOST_DE} server, in location ${HOST_LN}"
WRITE_TMP "${HOST_OS} , version ${HOST_OSVER} , ${HOST_CPU_CNT} CPUs with ${HOST_CORE_CNT} cores per CPU , and ${HOST_RAM} memory"

get_is_vm
get_apps

if [ $IS_ORPHAN -eq 1 ]
	then
		WRITE_TMP "This is an ORPHAN server i.e. one which has no related application instances in the CMDB."
		WRITE_TMP "If this server is actually in use, please update A2RM (https://a2rm.tpicapcloud.com/), failure to do so may result in operational issues."
fi


WRITE_TMP ""
WRITE_TMP "========== END OF CMDB DETAILS FOR HOST ==========="
cleanup

install_motd
LOG_INFO "End of motd update"
