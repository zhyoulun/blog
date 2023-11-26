## 信息

### 主机网络信息

IP地址：192.168.1.8/24

### kind信息

#### 容器列表

```
root@zyl-desktop:~# docker container ls | grep kind
fc8df175d08e   kindest/node:v1.27.3                     "/usr/local/bin/entr…"   13 days ago    Up 26 hours             0.0.0.0:39761->6443/tcp                                                                                                           kind-test1-control-plane
879cea7c38d7   kindest/node:z01                         "/usr/local/bin/entr…"   13 days ago    Up 26 hours                                                                                                                                               kind-test1-worker3
6cd529ba5458   kindest/node:z01                         "/usr/local/bin/entr…"   13 days ago    Up 26 hours                                                                                                                                               kind-test1-worker2
2435841b8170   kindest/node:z01                         "/usr/local/bin/entr…"   13 days ago    Up 26 hours                                                                                                                                               kind-test1-worker
```

#### IP地址

```
root@zyl-desktop:~#docker inspect kind-test1-control-plane | grep -E "Gateway|IPAddress|IPPrefixLen"
```

```
"Gateway": "172.20.0.1",//网关
"IPAddress": "172.20.0.2",//control-plane
"IPAddress": "172.20.0.3",//worker1
"IPAddress": "172.20.0.4",//worker3
"IPAddress": "172.20.0.5",//worker2
子网掩码："IPPrefixLen": 16,
```

### pod信息

```
root@kind-test1-control-plane:/# ps -ef | grep kube --color
root         689     468  1 Nov25 ?        00:21:11 kube-controller-manager --allocate-node-cidrs=true --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf --bind-address=127.0.0.1 --client-ca-file=/etc/kubernetes/pki/ca.crt --cluster-cidr=10.244.0.0/16 --cluster-name=kind-test1 --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt --cluster-signing-key-file=/etc/kubernetes/pki/ca.key --controllers=*,bootstrapsigner,tokencleaner --enable-hostpath-provisioner=true --kubeconfig=/etc/kubernetes/controller-manager.conf --leader-elect=true --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --root-ca-file=/etc/kubernetes/pki/ca.crt --service-account-private-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --use-service-account-credentials=true
```

- service网段：10.96.0.0/16
- pod网段：10.244.0.0/16

示例

```
root@zyl-desktop:~# kubectl get services
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   13d
my-nginx     ClusterIP   10.96.86.215   <none>        80/TCP    13d

root@zyl-desktop:~# kubectl describe pod my-nginx-646554d7fd-fd4jp | grep 244
IP:               10.244.2.3
  IP:           10.244.2.3
```

## dns追踪

### pod中

dns配置

```
root@my-nginx-646554d7fd-fd4jp:/# cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
```

其中10.96.0.10是一个dns service

```
root@zyl-desktop:~# kubectl get services -A
NAMESPACE              NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
...
kube-system            kube-dns                    ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   13d
```

在pod中执行dig

```
root@my-nginx-646554d7fd-fd4jp:/# dig www.example.com

; <<>> DiG 9.18.19-1~deb12u1-Debian <<>> www.example.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3112
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: eeeee12a47e517c5 (echoed)
;; QUESTION SECTION:
;www.example.com.		IN	A

;; ANSWER SECTION:
www.example.com.	30	IN	A	93.184.216.34

;; Query time: 8 msec
;; SERVER: 10.96.0.10#53(10.96.0.10) (UDP)
;; WHEN: Sun Nov 26 08:56:34 UTC 2023
;; MSG SIZE  rcvd: 87
```

同时在pod中的抓包

```
root@my-nginx-646554d7fd-fd4jp:/# tcpdump -i eth0 -v -n port 53
tcpdump: listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes

08:56:34.195320 IP (tos 0x0, ttl 64, id 11938, offset 0, flags [none], proto UDP (17), length 84)
    10.244.2.3.53100 > 10.96.0.10.53: 3112+ [1au] A? www.example.com. (56)
08:56:34.202683 IP (tos 0x0, ttl 62, id 27900, offset 0, flags [DF], proto UDP (17), length 115)
    10.96.0.10.53 > 10.244.2.3.53100: 3112 1/0/1 www.example.com. A 93.184.216.34 (87)
```

在worker3上的路由表

在worker3上的抓包vethe281cb12

worker3上的vethe281cb12和pod中的eth0是一对

```
root@kind-test1-worker3:/# cat /sys/class/net/vethe281cb12/ifindex
3

root@kind-test1-worker3:/# ip netns exec cni-e39cb8ef-2884-81c7-5865-b6eca1ea0917 ip addr show eth0
2: eth0@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether ee:7b:df:c6:1f:17 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.2.3/24 brd 10.244.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::ec7b:dfff:fec6:1f17/64 scope link
       valid_lft forever preferred_lft forever

root@kind-test1-worker3:/# ip netns exec cni-e39cb8ef-2884-81c7-5865-b6eca1ea0917 ethtool -S eth0
NIC statistics:
     peer_ifindex: 3
```

```
root@kind-test1-worker3:/#  tcpdump -v -n -i vethe281cb12 port 53
tcpdump: listening on vethe281cb12, link-type EN10MB (Ethernet), snapshot length 262144 bytes

08:56:34.195322 IP (tos 0x0, ttl 64, id 11938, offset 0, flags [none], proto UDP (17), length 84)
    10.244.2.3.53100 > 10.96.0.10.53: 3112+ [1au] A? www.example.com. (56)
08:56:34.202680 IP (tos 0x0, ttl 62, id 27900, offset 0, flags [DF], proto UDP (17), length 115)
    10.96.0.10.53 > 10.244.2.3.53100: 3112 1/0/1 www.example.com. A 93.184.216.34 (87)
```

在worker3上的抓包eth0，可以发现其中的目的地址发生了变化，从10.96.0.10改成了10.244.0.3

```
root@kind-test1-worker3:/# tcpdump -v -n -i eth0 port 53
tcpdump: listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes

09:00:00.889695 IP (tos 0x0, ttl 63, id 63841, offset 0, flags [none], proto UDP (17), length 84)
    10.244.2.3.44051 > 10.244.0.3.53: 36892+ [1au] A? www.example.com. (56)
09:00:00.898560 IP (tos 0x0, ttl 63, id 51327, offset 0, flags [DF], proto UDP (17), length 115)
    10.244.0.3.53 > 10.244.2.3.44051: 36892 1/0/1 www.example.com. A 93.184.216.34 (87)
```

分析worker3上iptables的nat表，可以确定做了dnat的变更

摘抄关键信息

PREROUTING：

```
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES

-A KUBE-SERVICES -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU

# 1/2的概率去10.244.0.2:53或者10.244.0.3:53，这里的case去的是10.244.0.3:53
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-YIL6JZP7A3QYXJU2
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.3:53" -j KUBE-SEP-6E7XQMQ4RAYOWTTM

-A KUBE-SEP-6E7XQMQ4RAYOWTTM -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.3:53
```

OUTPUT略，因为目的地址不是本机

POSTROUTING:只处理mark的，非pod内发起的请求会打mark

//todo 待分析非pod内发起的请求

```
-A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING

-A KUBE-POSTROUTING -m mark ! --mark 0x4000/0x4000 -j RETURN
```

dns请求包被发送到了`10.244.0.3.53`，查看路由表

```
root@kind-test1-worker3:/# ip route
...
10.244.0.0/24 via 172.20.0.2 dev eth0
...
```

经由eth0发送给`172.20.0.2`，即kind的控制面容器

对于回程包，会再发回vethe281cb12

```
root@kind-test1-worker3:/# ip route
...
10.244.2.3 dev vethe281cb12 scope host
...
```