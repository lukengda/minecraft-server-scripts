#!/bin/bash
# ddns script compatible with cloudpit.io
# lukengda

# setup:
# - install and configure this script to /usr/local/bin/ddns.sh
# - sudo mkdir -p /etc/ddns
# - sudo mkdir -p /var/log/ddns
# - add to `sudo crontab -e`: "*/5 * * * * /usr/local/bin/ddns.sh >> /var/log/ddns/ddns.log 2>&1"
# - add logrotate config /etc/logrotate.d/ddns
#   /var/log/ddns/ddns.log {
#       daily
#       rotate 7
#       compress
#       delaycompress
#       missingok
#       notifempty
#       create 644 root root
#   }

# enable for debugging:
#set -x

# This simple bash script will auto-update a cloudpit.io DNS entry if a computer's public IP address changes.
# Simply place it in a folder called /etc/ddns and add a cron job to call it every minute or so.
# The five configuration options below are specific to your account and must be set.
DOMAIN="<domain name>"
PASSWORD="<update password>"
INTERFACE="eth0"

# Static config
CACHE_PATH="/etc/ddns/cache.txt"

# IP address retr
#IP_ADDRESS=`curl -s http://checkip.dyn.com/ | sed -En -e 's/.*>Current IP Address: ([0-9.]+)<.*/\1/p'`
IP_ADDRESS=`ip -f inet addr show $INTERFACE | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'`

# Fetch last value of IP address sent to server or create cache file
if [ ! -f $CACHE_PATH ]; then touch $CACHE_PATH; fi
CURRENT=$(<$CACHE_PATH)

# If IP address hasn't changed, exit, otherwise save the new IP
if [ "$IP_ADDRESS" == "$CURRENT" ]; then
    echo "$(date) | No update required. IP address is still $IP_ADDRESS"
    exit 0
fi
echo $IP_ADDRESS > $CACHE_PATH

# Update dns
result=`curl -s "https://cloudpit.io/dynDns/update?login=$DOMAIN&password=$PASSWORD&ip=$IP_ADDRESS"`

echo "$(date) | $result"
# Check if the result is ok.
if [ "$result" = "IP updated for $DOMAIN" ]; then
    exit 0
else
    echo "ERROR ON UPDATE" > "$CACHE_PATH"
    exit 1
fi
