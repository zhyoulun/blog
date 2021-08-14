### 说明

无密码登录，将本机的`~/.ssh/id_rsa.pub`文件拷贝到对端的`~/.ssh/authorized_keys`文件中

### 使用方法

```bash
ssh-copy-id user@ip
```

### 示例

本机

```bash
zyl@mydev:~$ ssh-copy-id zyl@192.168.56.109
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/zyl/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
zyl@192.168.56.109's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'zyl@192.168.56.109'"
and check to make sure that only the key(s) you wanted were added.
```

对端机

```
zyl@zyldev32:~$ cat ~/.ssh/authorized_keys
ssh-rsa xxxxxxxxxxxxxxxxxxxx
zyl@zyldev32:~$ cat ~/.ssh/authorized_keys
ssh-rsa xxxxxxxxxxxxxxxxxxxx
ssh-rsa yyyyyyyyyyyyyyyyyyyy
```

## 参考

- [添加节点信任关系](https://github.com/opsnull/follow-me-install-kubernetes-cluster/blob/master/01.%E5%88%9D%E5%A7%8B%E5%8C%96%E7%B3%BB%E7%BB%9F%E5%92%8C%E5%85%A8%E5%B1%80%E5%8F%98%E9%87%8F.md)