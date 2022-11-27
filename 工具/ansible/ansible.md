### 安装

```
pip3 install ansible

# 安装参数不全
pip3 install argcomplete
activate-global-python-argcomplete
```

### 使用ansible

`inventory.yaml`

```
myvirtualmachines:
  hosts:
    vm01:
      ansible_host: 192.168.56.2
    vm02:
      ansible_host: 192.168.56.3
    vm03:
      ansible_host: 192.168.56.4
  vars:
    ansible_user: zyl
```

```bash
$ ansible myvirtualmachines -i ./inventory.yaml -m ping
vm02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
vm01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
vm03 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: ssh: connect to host 192.168.56.4 port 22: Operation timed out",
    "unreachable": true
}
```

### 使用ansible-playbook

`playbook.yaml`

```
- name: My first play
  hosts: myvirtualmachines
  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:
   - name: Print message
     ansible.builtin.debug:
       msg: Hello world
```

```bash
ansible-playbook -i ./inventory.yaml ./playbook.yaml

PLAY [My first play] ***********************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************
ok: [vm02]
ok: [vm01]
fatal: [vm03]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host 192.168.56.4 port 22: Operation timed out", "unreachable": true}

TASK [Ping my hosts] ***********************************************************************************************************
ok: [vm01]
ok: [vm02]

TASK [Print message] ***********************************************************************************************************
ok: [vm01] => {
    "msg": "Hello world"
}
ok: [vm02] => {
    "msg": "Hello world"
}

PLAY RECAP *********************************************************************************************************************
vm01                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vm02                       : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vm03                       : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0
```

## 参考

- [Installing Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- 待阅读部分
  - https://docs.ansible.com/ansible/latest/user_guide/index.html
