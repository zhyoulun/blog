在Linux主机上，Docker网络由Bridge驱动创建，而Bridge底层是基于Linux内核中久经考验达15年的Linux Bridge技术


```
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "4948bcbc50ee8e3e463930921b4510c9de423a76d5ee8705b09e130bffac1d4f",
        "Created": "2022-07-29T21:57:05.61357687+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0", //默认的bridge网络被映射到内核中为docker的linux网桥
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

```
$ ip link show docker0
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:ac:c8:b4:84 brd ff:ff:ff:ff:ff:ff
```

brctl工具可以用来查看系统中的Linux网桥

```
$ brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.0242acc8b484	no
```

创建一个容器，分别使用docker network inspect bridge和brctl show查看

```
$ docker container run -d --name c1 alpine sleep 1d
40eba052cf1db01590ba1bea226d0d7f655b5c53edd9e9d0a91787ff06c98560
```

```
$ docker network inspect bridge --format '{{json .Containers}}' | jq
{
  "40eba052cf1db01590ba1bea226d0d7f655b5c53edd9e9d0a91787ff06c98560": {
    "Name": "c1",
    "EndpointID": "b74d0f510f1d8fb66f701df4d68438d07ea903af48c4cf90a6e38c7f0c465a2b",
    "MacAddress": "02:42:ac:11:00:02",
    "IPv4Address": "172.17.0.2/16",
    "IPv6Address": ""
  }
}
```

```
$ brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.0242acc8b484	no		veth33a5778
```

```
$ ip link
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 02:42:ac:c8:b4:84 brd ff:ff:ff:ff:ff:ff
35: veth33a5778@if34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default
    link/ether 9a:d3:50:ff:3b:b3 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

在创建一个容器

```
$ docker container run -d --name c2 alpine sleep 1d
19adfa2e2db4b5a2e3a8bc9e8cfd3e317b724c1dec6ab05a4c767c9b98596fc5
```

```
$ brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.0242acc8b484	no		veth33a5778
							veth87c4799
```

## 参考

- 深入浅出docker
- linux bridge doc, https://wiki.linuxfoundation.org/networking/bridge
