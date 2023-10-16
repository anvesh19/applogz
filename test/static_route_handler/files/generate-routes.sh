#!/bin/bash

# ./generate_routes.sh | tee /etc/network/if-up.d/static-routes
# chmod +x /etc/network/if-up.d/static-routes
# ls -la /etc/network/if-up.d/
#
# XXX !!! THE VIA LINK ip route add 172.23.24.0/24 via link dev eth1 SHOULD BE: ip route add 172.23.24.0/24 dev eth1
#
# XXX It doesn't work for HOST KVM for br interfaces


IFACES=$(ls -l /sys/class/net/ | awk '$0 ~ /lrwxrwxrwx/ && $0 !~ /virtual/{print $9}')
# For KVM hosts we're going to check if there are any routes for brXXXX interfaces,
# as far as we cannot treat them as physical devices, and create a list of such interfaces.
BRIFACES=$(ip r sh | grep -P 'via .* br\d\d\d\d' | awk '{print $5}' | uniq)

if [[ -n $BRIFACES ]]; then
    IFACES="${IFACES} ${BRIFACES}"
fi

echo "#!$(which bash)"
for IFACE in ${IFACES}
do
    [[ $(ip route show dev ${IFACE} | awk '$1 !~ /default/ && $0 !~ /proto kernel/' | wc -l) -gt 0 ]] || continue

cat <<EOD

# Check for specific interface if desired
if [[ "\${IFACE}" == "${IFACE}" ]]
    then
        # Adding additional routes on connection
        true
EOD
    while read DEST VIA GW
    do
        echo "        ip route add ${DEST} via ${GW} dev ${IFACE}"
    done < <(ip route show dev ${IFACE} | awk '$1 !~ /default/ && $0 !~ /proto kernel/')
echo "fi"
done
echo "exit 0"
