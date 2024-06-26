#!/bin/sh

# Rendered with following template parameters:
# User: [LBertin-a]
# Organization: [TPICAP]
# Location: [NJC2]
# Host group: [HG-RHEL8/PROD-V]
# Operating system: [RedHat 8.7]
# Setup Insights: [false]
# Setup remote execution: [false]
# Update packages: [false]
# Force: [true]
# Ignore subman errors: [true]
# Lifecycle environment id: [8]
# Activation keys: [ACT-AUTO,ACT-RHEL8-PROD-V,ACT-RHEL8-PROD-V,BLANK-KEY,ACT-RHEL8-PROD-P]

if ! [ $(id -u) = 0 ]; then
    echo "Please run as root"
    exit 1
fi


if [ -f /etc/os-release ] ; then
  . /etc/os-release
fi

# Get OS package manager
# ---
# apt-get   Debian
#           Ubuntu
# dnf       Fedora
#           RHEL family version > 7
# yum       RHEL family version < 8
# pacman    Arch
# zypper    openSUSE Tumbleweed

if [ -f /etc/fedora-release ]; then
  PKG_MANAGER='dnf'
elif [ -f /etc/redhat-release ] ; then
  if [ "${VERSION_ID%.*}" -gt 7 ]; then
    PKG_MANAGER='dnf'
  else
    PKG_MANAGER='yum'
  fi
elif [ -f /etc/debian_version ]; then
  PKG_MANAGER='apt-get'
elif [ -f /etc/arch-release ]; then
  PKG_MANAGER='pacman'
elif [ x$ID = xopensuse-tumbleweed ]; then
  PKG_MANAGER='zypper'
fi


SSL_CA_CERT=$(mktemp)
cat << EOF > $SSL_CA_CERT
-----BEGIN CERTIFICATE-----
MIIG/jCCBOagAwIBAgIJAJbX/ff02eHTMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYD
VQQGEwJVUzEXMBUGA1UECAwOTm9ydGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVp
Z2gxEDAOBgNVBAoMB0thdGVsbG8xFDASBgNVBAsMC1NvbWVPcmdVbml0MSYwJAYD
VQQDDB1sZG4ybHgxMDAwLmNvcnAuYWQudHVsbGliLmNvbTAeFw0yMjA5MjMxOTM0
MDZaFw0zODAxMTcxOTM0MDZaMIGIMQswCQYDVQQGEwJVUzEXMBUGA1UECAwOTm9y
dGggQ2Fyb2xpbmExEDAOBgNVBAcMB1JhbGVpZ2gxEDAOBgNVBAoMB0thdGVsbG8x
FDASBgNVBAsMC1NvbWVPcmdVbml0MSYwJAYDVQQDDB1sZG4ybHgxMDAwLmNvcnAu
YWQudHVsbGliLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOca
l0PfZHJApDYl8qmsa8ERx9JSVgf3VWNRogJTRNPlfS33Ym7Ao9INICue8ojGvUWO
iJUkWKFR4i8rT7lfS3DvBTICM00Xj6TK/dd8M71dUR/GD1e24ouqDTnuHLyv13pr
8246jnHkYNvkUfrIoJ9EYDd8F9Iram6LF90VOeL4bLQgtY5uvAkwQpw1SjI/1mol
C7ZmrZ9Cx5dr/NOoFqrmkwZDxdMH+3tKm4s9UNmfytCeQ/K7edOGY6cS9S4z6huR
iN998c5dAEW1Dea2pD5qUKMn7ffxYam3ATGIkCz3MDX6mVcW+Hp7DhHAnn70NXsG
9TrHXdnarzVR43u2MOQTfBjx5fP4zeGaV657UTKIsZYjAjbXixRXadPVVBWPd63u
Xjh6B5h9QWvCGpQrdRsMW/ggHbn9/gFbyqujA7WFDu0W+Rww5ensVvx9FmCFohv2
uwRmKjXFbXVN0wAEvOTVrz8Ppys5EcZdpVZnzoqn/ey8QS4MwFOH6sPa11xeIDuT
+MeJwpEWHcPjrbHWluOBns9f12kpSeAIeMu5tSVpNpmHZ6NOaJ9pCy+NdDtt5GS7
0YPRDVtbE8QG+yv7YYIkW2QEKX09hXXYvQDqG68+R/b0awdeupP6iTKlQJ+62bCf
33XEVK8Is9G+0jW4pYzS9/gZz2Ro8lVo+CyaPToxAgMBAAGjggFnMIIBYzAMBgNV
HRMEBTADAQH/MAsGA1UdDwQEAwIBpjAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYB
BQUHAwIwEQYJYIZIAYb4QgEBBAQDAgJEMDUGCWCGSAGG+EIBDQQoFiZLYXRlbGxv
IFNTTCBUb29sIEdlbmVyYXRlZCBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUvUoW5J7P
1p23B03X6Y8J+IFAfqgwgb0GA1UdIwSBtTCBsoAUvUoW5J7P1p23B03X6Y8J+IFA
fqihgY6kgYswgYgxCzAJBgNVBAYTAlVTMRcwFQYDVQQIDA5Ob3J0aCBDYXJvbGlu
YTEQMA4GA1UEBwwHUmFsZWlnaDEQMA4GA1UECgwHS2F0ZWxsbzEUMBIGA1UECwwL
U29tZU9yZ1VuaXQxJjAkBgNVBAMMHWxkbjJseDEwMDAuY29ycC5hZC50dWxsaWIu
Y29tggkAltf99/TZ4dMwDQYJKoZIhvcNAQELBQADggIBAEcTEpM6Ddct9u3JkyAF
RkggRK5NYgS0+TnT2RDiImFOFB47QAIhcCOdhmtkTdhv0TyYUWHIxy3lnqAGHE1O
id0CgIB71EXUAWYQCRvo5cTWF6d929npM1WkE9iMlX0Va3pNg5eomvm2BZike05b
VL6Dq0LePqyBpK2Mqba/TAbYC+KUqTd6vhPmpfqI7lKsWT2+OewwPAs2W0D99pKi
ljb6F3KdVcFW5Af+fdv9pd+UgqMfpjuufRgb6/BpaMBWTjccGfFAwcyYtknkw846
lNn5bO1Q21R2l7sQM9jF5CZQR/b19XLdtJ+Io0tcC11nZbStbkPEEbrf5nUvonDt
1fhhh+kMLrDuyJAYrshOy1pF5e1lMqe55GO+xxGjF9jKi+T6brvFyTzW7B5yuHsQ
2uxoyUT8FjhttnxrI/GIEWiR3sIoJ+wv0CTFAxNOt7VuO2G/B4ArFSkULjOvWnze
CQv3dolxVrBoXX4JbuIbZRR6Cxbdhdjh2gwv56dCFBtciNBoARQazgNey7L9aUWp
CQp+vJUoG+LhdYB/tTfZnR9Dv1+THC4oEVq0Rx9lzz2NyjfmY4hoNAlVYroEdbY0
Se4WKpvdfJUCoJsw3Qg//iUeas/Ftd253DQf4aSkqJvPHUcMR8sXt8nx0i8iy5SS
5PVOVQNZUD4GN5JZcA6WN6WV
-----END CERTIFICATE-----

EOF

cleanup_and_exit() {
  rm -f $SSL_CA_CERT
  exit $1
}


register_host() {
  curl --silent --show-error --cacert $SSL_CA_CERT --request POST https://ldn2lx1000/register \
       -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo5LCJpYXQiOjE2ODE3MzkwMzIsImp0aSI6ImNmNDY4NTRmZGM1YjRiZGM4NWNkMGI5MGI0ZWY2YmEyNGQ4ZTAyODZmNjA2NjFkYmQxNDUxODQ3OTc3ZTM0MTYiLCJleHAiOjE2ODE3NTM0MzIsInNjb3BlIjoicmVnaXN0cmF0aW9uI2dsb2JhbCByZWdpc3RyYXRpb24jaG9zdCJ9.WnuVt_aq1IOMgmX4rkj4cd9DWyPo6vN3liEbXLculCM' \
       --data "host[name]=$(hostname --fqdn)" \
       --data "host[build]=false" \
       --data "host[managed]=false" \
       --data 'host[organization_id]=1' \
       --data 'host[location_id]=12' \
       --data 'host[hostgroup_id]=32' \
       --data 'host[operatingsystem_id]=12' \
       --data 'setup_insights=false' \
       --data 'setup_remote_execution=false' \
       --data 'update_packages=false' \

}

echo "#"
echo "# Running registration"
echo "#"

if [ -f /etc/redhat-release ]; then
    register_katello_host(){
        UUID=$(subscription-manager identity | head -1 | awk '{print $3}')
        curl --silent --show-error --cacert $KATELLO_SERVER_CA_CERT --request POST "https://ldn2lx1000/register" \
             --data "uuid=$UUID" \
             -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo5LCJpYXQiOjE2ODE3MzkwMzIsImp0aSI6ImNmNDY4NTRmZGM1YjRiZGM4NWNkMGI5MGI0ZWY2YmEyNGQ4ZTAyODZmNjA2NjFkYmQxNDUxODQ3OTc3ZTM0MTYiLCJleHAiOjE2ODE3NTM0MzIsInNjb3BlIjoicmVnaXN0cmF0aW9uI2dsb2JhbCByZWdpc3RyYXRpb24jaG9zdCJ9.WnuVt_aq1IOMgmX4rkj4cd9DWyPo6vN3liEbXLculCM' \
          --data 'host[organization_id]=1' \
          --data 'host[location_id]=12' \
          --data 'host[hostgroup_id]=32' \
          --data 'host[lifecycle_environment_id]=8' \
          --data 'setup_insights=false' \
          --data 'setup_remote_execution=false' \
          --data 'update_packages=false' \

    }

    KATELLO_SERVER_CA_CERT=/etc/rhsm/ca/katello-server-ca.pem
    RHSM_CFG=/etc/rhsm/rhsm.conf

    # Backup rhsm.conf
    if [ -f $RHSM_CFG ] ; then
      test -f $RHSM_CFG.bak || cp $RHSM_CFG $RHSM_CFG.bak
    fi

    # rhn-client-tools conflicts with subscription-manager package
    # since rhn tools replaces subscription-manager, we need to explicitly
    # install subscription-manager after the rhn tools cleanup
    if [ x$ID = xol ]; then
      $PKG_MANAGER remove -y rhn-client-tools
      $PKG_MANAGER install -y --setopt=obsoletes=0 subscription-manager
    fi

    # Prepare SSL certificate
    mkdir -p /etc/rhsm/ca
    cp -f $SSL_CA_CERT $KATELLO_SERVER_CA_CERT
    chmod 644 $KATELLO_SERVER_CA_CERT

    # Prepare subscription-manager
        if [ -x "$(command -v subscription-manager)" ] ; then
      subscription-manager unregister || true
      subscription-manager clean
    fi

    $PKG_MANAGER remove -y katello-ca-consumer\*
    
    if ! [ -x "$(command -v subscription-manager)" ] ; then
      $PKG_MANAGER install -y subscription-manager
    else
      $PKG_MANAGER upgrade -y subscription-manager
    fi

    if ! [ -f $RHSM_CFG ] ; then
      echo "'$RHSM_CFG' not found, cannot configure subscription-manager"
      cleanup_and_exit 1
    fi

    # Configure subscription-manager
    test -f $RHSM_CFG.bak || cp $RHSM_CFG $RHSM_CFG.bak
    subscription-manager config \
      --server.hostname="ldn2lx1000.corp.ad.tullib.com" \
      --server.port="443" \
      --server.prefix="/rhsm" \
      --rhsm.repo_ca_cert="$KATELLO_SERVER_CA_CERT" \
      --rhsm.baseurl="https://ldn2lx1000.corp.ad.tullib.com/pulp/content"

    # Older versions of subscription manager may not recognize
    # report_package_profile and package_profile_on_trans options.
    # So set them separately and redirect out & error to /dev/null
    # to fail silently.
    subscription-manager config --rhsm.package_profile_on_trans=1 > /dev/null 2>&1 || true
    subscription-manager config --rhsm.report_package_profile=1 > /dev/null 2>&1 || true

    # Configuration for EL6
    if grep --quiet full_refresh_on_yum $RHSM_CFG; then
      sed -i "s/full_refresh_on_yum\s*=.*$/full_refresh_on_yum = 1/g" $RHSM_CFG
    else
      full_refresh_config="#config for on-premise management\nfull_refresh_on_yum = 1"
      sed -i "/baseurl/a $full_refresh_config" $RHSM_CFG
    fi

    subscription-manager register --force \
      --org='TPICAP' \
      --activationkey='ACT-AUTO,ACT-RHEL8-PROD-V,ACT-RHEL8-PROD-V,BLANK-KEY,ACT-RHEL8-PROD-P' || true

    register_katello_host | bash
else
    register_host | bash
fi

cleanup_and_exit
