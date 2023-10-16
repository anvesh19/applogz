# journald-storage

## General

The role is designed to re-configure Journald to use persistent storage. 
It creates (if not presented) directory for custom configuration (/etc/systemd/journald.conf.d/),
and puts a configuration file there. For more information about journald configuration see journald.conf.d(5).

## Execution

No special notes on how to run. Keep in mind that systemd-journald will be **restarted**, 
not reloaded, because the service may keep running with a stale configuration when just reloaded.

## Changelog

2023-02-15 nafanasiev.contractor@libertyglobal.com [OBSCLOUD-7928] Initial commit
2023-02-15 nafanasiev.contractor@libertyglobal.com [OBSCLOUD-7928] Disk storage for journald increased up to 8G
2023-04-18 nafanasiev.contractor@libertyglobal.com N/A Added mechine id initialization to prevent systemd-journald restart fail

## Errata

1. If the role is executed for the first time on a host, it may fail with following error:

`Unable to restart service systemd-journald: Job for systemd-journald.service failed because a timeout was exceeded.`

While systemd-journald was restarted successfully on target host
