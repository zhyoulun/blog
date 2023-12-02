### 在容器中启动3个nginx

`docker-compose.yml`文件内容如下：

```
version: "3.7"
services:
    nginx1:
        image: bitnami/nginx:1.20.1
    nginx2:
        image: bitnami/nginx:1.20.1
    nginx3:
        image: bitnami/nginx:1.20.1
```

该实验在linux进行比较容易，在mac不好搞，因为无法在宿主机上通过IP直接访问容器服务

### 环境概况

```
$ ip link
...
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc htb state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:a5:d2:72 brd ff:ff:ff:ff:ff:ff
4: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 02:42:dc:c1:7d:da brd ff:ff:ff:ff:ff:ff
...
```

```
$ ip addr
...
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc htb state UP group default qlen 1000
    link/ether 08:00:27:a5:d2:72 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.108/24 brd 192.168.56.255 scope global dynamic enp0s8
       valid_lft 315sec preferred_lft 315sec
    inet6 fe80::a00:27ff:fea5:d272/64 scope link
       valid_lft forever preferred_lft forever
4: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:dc:c1:7d:da brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:dcff:fec1:7dda/64 scope link
       valid_lft forever preferred_lft forever
...
```

```
$ ip route
...
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.108
...
```

### 配置

启用ip转发

```
echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward
```

`192.168.56.108`是宿主机的IP

```
sudo ipvsadm -A -t 192.168.56.108:8999 -s rr
sudo ipvsadm -a -t 192.168.56.108:8999 -r 172.19.0.3:8080 -m
sudo ipvsadm -a -t 192.168.56.108:8999 -r 172.19.0.4:8080 -m
sudo ipvsadm -a -t 192.168.56.108:8999 -r 172.19.0.5:8080 -m
```

## 参考

- [Docker 搭建简单 LVS](https://www.cnblogs.com/majiang/p/11402015.html)