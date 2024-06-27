#!/bin/bash

# NOTE: We recommend all shell users to use the "httpie" examples instead.
#       `curl` should not be used for writing large scripts.
#       This code is provided for debugging purposes only.

HOST_NAME="cmkcentral.corp.ad.tullib.com"
SITE_NAME="Main"
PROTO="https"
API_URL="$PROTO://$HOST_NAME/$SITE_NAME/check_mk/api/1.0"

USERNAME="automation"
KEY="10b70962-b2ac-4244-803a-8be7cd06a11a"

host=$@
for i in $host
do

# Move to DECOM
curl \
  --request POST \
  --write-out "\nxxx-status_code=%{http_code}\n" \
  --header "Authorization: Bearer $USERNAME $KEY" \
  --header "Accept: application/json" \
  --header "If-Match: "*"" \
  --header "Content-Type: application/json" \
  --data '{
          "target_folder": "~decom"
        }' \
  "$API_URL/objects/host_config/$host/actions/move/invoke"
