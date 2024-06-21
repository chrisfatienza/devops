import os
import subprocess
import urllib2
import json

ssBaseURL = "https://tss.secretservercloud.eu"

print "Enter a Database Name:"
DATABASE = raw_input()

print """Choose User:
1. = SYSTEM
2. = SYSASM
3. = SYSBACKUP
4. = SYSDG
5. = SYSOPER
6. = SYSRAC
7. = SYSKM
8. = SYSDBA"""
USERNAME = raw_input()

if USERNAME == "1":
    USERNAME = "SYSTEM"
    SECRETID = "30299"
elif USERNAME == "2":
    USERNAME = "SYSASM"
elif USERNAME == "3":
    USERNAME = "SYSBACKUP"
elif USERNAME == "4":
    USERNAME = "SYSDG"
elif USERNAME == "5":
    USERNAME = "SYSOPER"
elif USERNAME == "6":
    USERNAME = "SYSRAC"
elif USERNAME == "7":
    USERNAME = "SYSKM"
elif USERNAME == "8":
    USERNAME = "SYSTEM"

os.chdir("/opt/secretserver-sdk-1.5.3-linux-x64")
TOKEN = subprocess.Popen(["./tss", "token"], stdout=subprocess.PIPE).communicate()[0].strip()

headers = {
    "Accept": "application/json",
    "Authorization": "Bearer " + TOKEN
}
request_url = ssBaseURL + "/api/v1/secrets/" + SECRETID + "/fields/Password"
req = urllib2.Request(request_url, headers=headers)
response = urllib2.urlopen(req)
PASSWORD = json.loads(response.read())

ORACLE_BASE = "/orahome/app"
ORACLE_HOME = "/orahome/app/oracle/19.3.0.0"

# Preserve ORACLE_HOME
os.environ['ORACLE_HOME'] = ORACLE_HOME

subprocess.call(["sudo", "-u", "oracle", "sh", "-c", "export ORACLE_SID=" + DATABASE + " && /orahome/app/grid/19.3.0.0/bin/sqlplus " + USERNAME + "/" + PASSWORD])

