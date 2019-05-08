#!/bin/ash

# Set your variables

domain=""
type="A"
value="@"
ttl=3600
godaddyKey=""
godaddySecret=""
wanInterface="eth0.2"

if [ "$value" == "@" ]
then
        value="%40"
fi


# Do stuff

echo "[-] Getting GoDaddy IP"

godaddyGET=`curl -s -X GET "https://api.godaddy.com/v1/domains/${domain}/records/${type}/${value}" -H "accept: application/json" -H "Authorization: sso-key ${godaddyKey}:${godaddySecret}"`

godaddyIP=`echo -n $godaddyGET | awk -F '"' '{print $4}'`

echo "[+] Godaddy IP is $godaddyIP"
echo "[-] Getting current WAN IP"

currentIP=`ifconfig ${wanInterface} | grep "inet addr" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}'`

echo "[+] Current IP is $currentIP"

if [ "$godaddyIP" != "$currentIP" ]
then
        echo "[!] IPs are different! Updating... "
        curl -s -X PUT "https://api.godaddy.com/v1/domains/${domain}/records/${type}/{$value}" -H "accept: application/json" -H "Content-Type: application/json" -H "Authorization: sso-key ${godaddyKey}:${godaddySecret}" -d "[ { \"data\": \"${currentIP}\", \"ttl\": ${ttl} }]"
        echo "[+] Update completed!"
else
        echo "[+] IPs are the same. Nothing else to do. "
fi

