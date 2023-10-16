# Microsoft Defender Endpoint (MDE)

Documentation: [https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/linux-install-with-ansible](https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/linux-install-with-ansible?view=o365-worldwide)

## Variables

| Name | Default | Description |
|-|-|-|
| `mdatp_package_state` | `latest` | mdatp package state.<br>Choices:<ul><li>`absent`</li><li>`build-dep`</li><li>`latest`</li><li>`present`</li><li>`fixed`</li></ul> |
| `mdatp_enforcement_level` | `real_time` | [Enforcement level for antivirus engine](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/linux-preferences?view=o365-worldwide#enforcement-level-for-antivirus-engine).<br>Choices:<ul><li>`real_time`: Real-time protection (scan files as they're modified) is enabled</li><li>`on_demand`: Files are scanned only on demand</li><li>`passive`: Runs the antivirus engine in passive mode</li></ul> |
| `mdatp_uninstall_first` | `false` | Uninstall mdatp before installing (ignored when `mdatp_package_state: absent`) |

## Example playbook

### Install

```yaml
---
- name: Setup mdatp
  hosts: all,!lacework_agents
  become: true
  become_method: sudo
  environment: "{{proxy_env}}"
  vars:
    mdatp_package_state: present
    mdatp_enforcement_level: active
  roles:
    - ../roles/mdatp_install
```

### Update with reinstall

```yaml
---
- name: Setup latest mdatp by reinstalling
  hosts: all,!lacework_agents
  become: true
  become_method: sudo
  environment: "{{proxy_env}}"
  vars:
    mdatp_uninstall_first: true
    mdatp_package_state: latest
    mdatp_enforcement_level: active
  roles:
    - ../roles/mdatp_install
```

## Checking

```bash
$ ansible -m shell -a 'mdatp connectivity test' all
$ ansible -m shell -a 'mdatp health' all
```
