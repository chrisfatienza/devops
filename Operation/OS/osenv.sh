host=$@

for i in $host
do

    host=$1
    ServerEnv(){                               
            while IFS= read -r file_contents; do
            # Check if PROD and ESX are found
            if [[ $file_contents == *"PROD"* && $file_contents == *"ESX"* ]]; then
                activation="PROD-V"
            # Check if PROD is found but not ESX
            elif [[ $file_contents == *"PROD"* ]]; then
                activation="PROD-P"
            # Check if DEV and ESX are found
            elif [[ $file_contents == *"DEV"* && $file_contents == *"ESX"* ]]; then
                activation="DEV-V"
            # Check if DEV is found but not ESX
            elif [[ $file_contents == *"DEV"* ]]; then
                activation="DEV-P"
            else
                echo "Environment and type could not be determined."
                exit 1
            fi
            done < <(grep "$host" /root/cfgmain/patching/prepatch/A2RMS-ServerDetails)

            # Print the environment variable
            echo "Environment: $activation"
    }
    ServerEnv $activation 
    echo $type

    #echo Checking if $i is pingable
    hostchk=`ping -c1 $i`
    if [[ $? -eq 0 ]]
    then

    hostssh=`ssh -tt -o BatchMode=yes -o StrictHostKeyChecking=no -q $i date`

            if [[ $? -eq 0 ]]
            then
                echo $host            
            else
                echo $i: host is not accessible via ssh or passwordless ssh as root not allowed
            fi
    else
            echo $i: host not pingable
    fi
done
