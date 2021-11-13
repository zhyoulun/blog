网卡配置

在文件/etc/network/interfaces中追加内容

```
auto enp0s8
iface enp0s8 inet dhcp
```

或者

```
auto eth1
iface eth1 inet dhcp
```

具体是eth1还是enp0s8需要通过`ip link`查看当前的网卡列表

## 参考

- [In VirtualBox, how do I set up host-only virtual machines that can access the Internet?](https://askubuntu.com/questions/293816/in-virtualbox-how-do-i-set-up-host-only-virtual-machines-that-can-access-the-in)