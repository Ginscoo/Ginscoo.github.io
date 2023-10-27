#!/bin/bash

NETCART_NAME=$(ip -o link show | awk 'NR>1 && $2 ~ /^ens/ {sub(/:/, "", $2); print $2}')
echo $NETCART_NAME
UUID=$(cat /etc/sysconfig/network-scripts/ifcfg-$NETCART_NAME | grep UUID | grep -v grep)
GATEWAY=$(echo "$1" | sed 's/\(\([0-9]\{1,3\}\.\)\{3\}\)[0-9]\{1,3\}/\11/g')
echo "
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPADDR="$1"
PREFIX="24"
GATEWAY="$GATEWAY"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="$NETCART_NAME"
$UUID
DEVICE="$NETCART_NAME"
ONBOOT="yes"
" > /etc/sysconfig/network-scripts/ifcfg-$NETCART_NAME

systemctl restart network