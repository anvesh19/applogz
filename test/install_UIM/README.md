# Install UIM

## General

The role installs UIM client to the target host. If this role executes against existing host (not during initial setup),
make sure following prerequisites are met:

1. Host is [added](https://gitlab.sdil.aorta.net/observer-devops/obs-infrastructure/-/wikis/UIM/api) to UIM
1. All local accounts, except service accounts like ansible, are removed
 
## Execution

No special notes on how to run. 

## Changelog

2023-08-01 nafanasiev.contractor@libertyglobal.com [OBSCLOUD-8462] Added CentOS deployment
2023-07-21 nafanasiev.contractor@libertyglobal.com [OBSCLOUD-8134] Initial commit

## Errata

1. UIM's init script may fail to check connectivity correctly, if nslcd fails to communicate to 
LDAP endpoint, check routing table
