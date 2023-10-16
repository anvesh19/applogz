## This role deploys a systemd timer to targets for:
- store static routes as permanent on hosts
- uploads them to a git reposirory: https://gitlab-ecxdf.aorta.net/ggercso/static-routes

## Notes and limitations
- The `VIA LINK ip route add 172.23.24.0/24 via link dev eth1` SHOULD BE: `ip route add 172.23.24.0/24 dev eth1`
- It doesn't work on a KVM HOST as there it can not handle bridge interfaces.
    If a host has non-standard interfaces (other than eg. eth0 or ens0) **the script will delete the original static route file, if it was set up manually!!!**
- Requires `--ask-vault-pass` parameter, with the regular "Ansible" password at deploy time
- Not usable for automatic deployment to older hosts, we have to deploy this tool from host to host and check the routing manually because:
    - the "via link dev eth" limitation what the script mentioning (thanks for catching!)
    - some of the hosts has configured routing rules in /etc/network/interfaces
    - some of the hosts has configured routing rules in /etc/network/interfaces.d/${interface} too
    - some of the hosts has overlapping rules eg. separate host rules and subnet rules in the same range, on top of that using a different interface
    - it is possible that the default gateway is different in the routing table compared to config files, what can make a host unaccessible after a reboot

## Parameters:
- `save_static_routes_as_permanent` (string): If "true" (default) writes gathered static routes to `/etc/network/if-up.d/static-routes` file.
- `static_route_handler_dir` (string): Destination path to store scritps and data.
