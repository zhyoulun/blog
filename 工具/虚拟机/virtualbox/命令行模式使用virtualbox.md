### 安装

```
sudo apt install --reinstall virtualbox-dkms
```

### 创建hostonly网络

```
vboxmanage hostonlyif  create # 创建vboxnet0
vboxmanage list hostonlyifs  # 列出所有的host-only网卡
```


## 参考

- [virtualbox - "FATAL: Module vboxdrv not found in directory /lib/modules/4.10.0-20-generic" - Ask Ubuntu](https://askubuntu.com/questions/912011/fatal-module-vboxdrv-not-found-in-directory-lib-modules-4-10-0-20-generic)
- [6.7. Host-Only Networking](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/network_hostonly.html)
