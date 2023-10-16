blackbox_exporter
=========

Deploy [blackbox-exporter](https://github.com/prometheus/blackbox_exporter)

Requirements
------------

```
ansible-galaxy collection install community.docker
```

Role Variables
--------------

| Name | Type | Description |
|-|-|-|
| blackbox_dir | string | path to blackbox config dir |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```
- hosts: servers
  vars:
    blackbox_dir: /path/to/dir
  roles:
      - role: roles/blackbox_exporter
```

