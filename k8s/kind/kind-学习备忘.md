## worker1

```
# ip route
default via 172.20.0.1 dev eth0 
10.244.0.0/24 via 172.20.0.2 dev eth0 
10.244.2.0/24 via 172.20.0.4 dev eth0 
10.244.3.0/24 via 172.20.0.5 dev eth0 
172.20.0.0/16 dev eth0 proto kernel scope link src 172.20.0.3 
```


## worker2

```
# ip route
default via 172.20.0.1 dev eth0 
10.244.0.0/24 via 172.20.0.2 dev eth0 
10.244.1.0/24 via 172.20.0.3 dev eth0 
10.244.2.0/24 via 172.20.0.4 dev eth0 
10.244.3.2 dev veth758da698 scope host 
10.244.3.3 dev veth87bdb93d scope host # nginx
172.20.0.0/16 dev eth0 proto kernel scope link src 172.20.0.5 
```

## worker3

```
# ip route
default via 172.20.0.1 dev eth0 
10.244.0.0/24 via 172.20.0.2 dev eth0 
10.244.1.0/24 via 172.20.0.3 dev eth0 
10.244.2.2 dev vethbb7627ba scope host 
10.244.2.3 dev vethe281cb12 scope host # nginx
10.244.3.0/24 via 172.20.0.5 dev eth0 
172.20.0.0/16 dev eth0 proto kernel scope link src 172.20.0.4 
```

## nginx pod1 at worker2

### at host

```
# ip addr show veth87bdb93d
3: veth87bdb93d@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 8e:44:5c:b6:18:42 brd ff:ff:ff:ff:ff:ff link-netns cni-459e9507-cbdc-d8dd-7900-a4559ea7c63a
    inet 10.244.3.1/32 scope global veth87bdb93d
       valid_lft forever preferred_lft forever
```

### in pod

```
# ip addr show eth0
2: eth0@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether a2:43:a3:40:a3:82 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.3.3/24 brd 10.244.3.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a043:a3ff:fe40:a382/64 scope link 
       valid_lft forever preferred_lft forever

# ip route
default via 10.244.3.1 dev eth0 
10.244.3.0/24 via 10.244.3.1 dev eth0 src 10.244.3.3 
10.244.3.1 dev eth0 scope link src 10.244.3.3 
```

## nginx pod2 at worker3

### at host

```
# ip addr show vethe281cb12
3: vethe281cb12@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 4e:4d:5c:5d:90:35 brd ff:ff:ff:ff:ff:ff link-netns cni-e39cb8ef-2884-81c7-5865-b6eca1ea0917
    inet 10.244.2.1/32 scope global vethe281cb12
       valid_lft forever preferred_lft forever
```

### in pod


```bash
# ip addr show eth0 
2: eth0@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether ee:7b:df:c6:1f:17 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.2.3/24 brd 10.244.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::ec7b:dfff:fec6:1f17/64 scope link 
       valid_lft forever preferred_lft forever

# ip route
default via 10.244.2.1 dev eth0         # 默认网关是veth的另一端
10.244.2.0/24 via 10.244.2.1 dev eth0 src 10.244.2.3 
10.244.2.1 dev eth0 scope link src 10.244.2.3 
```

## iptables at worker3

### filter表

```
# iptables -S   
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-N KUBE-EXTERNAL-SERVICES
-N KUBE-FIREWALL
-N KUBE-FORWARD
-N KUBE-KUBELET-CANARY
-N KUBE-NODEPORTS
-N KUBE-PROXY-CANARY
-N KUBE-PROXY-FIREWALL
-N KUBE-SERVICES

-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A INPUT -m comment --comment "kubernetes health check service ports" -j KUBE-NODEPORTS
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
-A INPUT -j KUBE-FIREWALL

-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A FORWARD -m comment --comment "kubernetes forwarding rules" -j KUBE-FORWARD
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES

-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -j KUBE-FIREWALL

-A KUBE-FIREWALL ! -s 127.0.0.0/8 -d 127.0.0.0/8 -m comment --comment "block incoming localnet connections" -m conntrack ! --ctstate RELATED,ESTABLISHED,DNAT -j DROP

-A KUBE-FORWARD -m conntrack --ctstate INVALID -j DROP
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding rules" -m mark --mark 0x4000/0x4000 -j ACCEPT
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding conntrack rule" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

### nat表 - 删减版

```
# iptables -t nat -S

-P PREROUTING ACCEPT
-P INPUT ACCEPT
-P OUTPUT ACCEPT
-P POSTROUTING ACCEPT
-N DOCKER_OUTPUT
-N DOCKER_POSTROUTING
-N KIND-MASQ-AGENT
-N KUBE-KUBELET-CANARY
-N KUBE-MARK-MASQ
-N KUBE-NODEPORTS
-N KUBE-POSTROUTING
-N KUBE-PROXY-CANARY
-N KUBE-SEP-6E7XQMQ4RAYOWTTM
-N KUBE-SEP-7X37DHTI3VKMHRUW
-N KUBE-SEP-IT2ZTR26TO4XFPTO
-N KUBE-SEP-ME73ZWD7U6KL3OSU
-N KUBE-SEP-MEZP33SDGZXSPSO5
-N KUBE-SEP-MKDZHZ7VKZG7DWNK
-N KUBE-SEP-N4G2XR5TDX7PQE7P
-N KUBE-SEP-TIQJFJVSHRJZTTZW
-N KUBE-SEP-YIL6JZP7A3QYXJU2
-N KUBE-SEP-ZP3FB6NMPNCO4VBJ
-N KUBE-SEP-ZXMNUKOKXUTL2MK2
-N KUBE-SERVICES
-N KUBE-SVC-CEZPIJSAUFW5MYPQ
-N KUBE-SVC-ERIFXISQEP7F7OF4
-N KUBE-SVC-JD5MR3NA4I4DYORP
-N KUBE-SVC-L65ENXXZWWSAPRCR
-N KUBE-SVC-NPX46M4PTMTKRN6Y
-N KUBE-SVC-TCOU7JCQXEZGVUNU
-N KUBE-SVC-Z6GDYMWE5TV2NNJN

-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A PREROUTING -d 172.20.0.1/32 -j DOCKER_OUTPUT

-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -d 172.20.0.1/32 -j DOCKER_OUTPUT

-A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING
-A POSTROUTING -d 172.20.0.1/32 -j DOCKER_POSTROUTING
-A POSTROUTING -m addrtype ! --dst-type LOCAL -m comment --comment "kind-masq-agent: ensure nat POSTROUTING directs all non-LOCAL destination traffic to our custom KIND-MASQ-AGENT chain" -j KIND-MASQ-AGENT

-A DOCKER_OUTPUT -d 172.20.0.1/32 -p tcp -m tcp --dport 53 -j DNAT --to-destination 127.0.0.11:37389
-A DOCKER_OUTPUT -d 172.20.0.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 127.0.0.11:37347

-A DOCKER_POSTROUTING -s 127.0.0.11/32 -p tcp -m tcp --sport 37389 -j SNAT --to-source 172.20.0.1:53
-A DOCKER_POSTROUTING -s 127.0.0.11/32 -p udp -m udp --sport 37347 -j SNAT --to-source 172.20.0.1:53

-A KIND-MASQ-AGENT -d 10.244.0.0/16 -m comment --comment "kind-masq-agent: local traffic is not subject to MASQUERADE" -j RETURN
-A KIND-MASQ-AGENT -m comment --comment "kind-masq-agent: outbound traffic is subject to MASQUERADE (must be last in chain)" -j MASQUERADE

-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000

-A KUBE-POSTROUTING -m mark ! --mark 0x4000/0x4000 -j RETURN
-A KUBE-POSTROUTING -j MARK --set-xmark 0x4000/0x0
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -j MASQUERADE --random-fully

-A KUBE-SEP-MEZP33SDGZXSPSO5 -s 10.244.3.3/32 -m comment --comment "default/my-nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-MEZP33SDGZXSPSO5 -p tcp -m comment --comment "default/my-nginx" -m tcp -j DNAT --to-destination 10.244.3.3:80
-A KUBE-SEP-TIQJFJVSHRJZTTZW -s 10.244.2.3/32 -m comment --comment "default/my-nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-TIQJFJVSHRJZTTZW -p tcp -m comment --comment "default/my-nginx" -m tcp -j DNAT --to-destination 10.244.2.3:80

-A KUBE-SERVICES -d 10.96.86.215/32 -p tcp -m comment --comment "default/my-nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-L65ENXXZWWSAPRCR

-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS

-A KUBE-SVC-L65ENXXZWWSAPRCR ! -s 10.244.0.0/16 -d 10.96.86.215/32 -p tcp -m comment --comment "default/my-nginx cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-L65ENXXZWWSAPRCR -m comment --comment "default/my-nginx -> 10.244.2.3:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-TIQJFJVSHRJZTTZW
-A KUBE-SVC-L65ENXXZWWSAPRCR -m comment --comment "default/my-nginx -> 10.244.3.3:80" -j KUBE-SEP-MEZP33SDGZXSPSO5
```

### nat表 - 完整版

```
# iptables -t nat -S
-P PREROUTING ACCEPT
-P INPUT ACCEPT
-P OUTPUT ACCEPT
-P POSTROUTING ACCEPT
-N DOCKER_OUTPUT
-N DOCKER_POSTROUTING
-N KIND-MASQ-AGENT
-N KUBE-KUBELET-CANARY
-N KUBE-MARK-MASQ
-N KUBE-NODEPORTS
-N KUBE-POSTROUTING
-N KUBE-PROXY-CANARY
-N KUBE-SEP-6E7XQMQ4RAYOWTTM
-N KUBE-SEP-7X37DHTI3VKMHRUW
-N KUBE-SEP-IT2ZTR26TO4XFPTO
-N KUBE-SEP-ME73ZWD7U6KL3OSU
-N KUBE-SEP-MEZP33SDGZXSPSO5
-N KUBE-SEP-MKDZHZ7VKZG7DWNK
-N KUBE-SEP-N4G2XR5TDX7PQE7P
-N KUBE-SEP-TIQJFJVSHRJZTTZW
-N KUBE-SEP-YIL6JZP7A3QYXJU2
-N KUBE-SEP-ZP3FB6NMPNCO4VBJ
-N KUBE-SEP-ZXMNUKOKXUTL2MK2
-N KUBE-SERVICES
-N KUBE-SVC-CEZPIJSAUFW5MYPQ
-N KUBE-SVC-ERIFXISQEP7F7OF4
-N KUBE-SVC-JD5MR3NA4I4DYORP
-N KUBE-SVC-L65ENXXZWWSAPRCR
-N KUBE-SVC-NPX46M4PTMTKRN6Y
-N KUBE-SVC-TCOU7JCQXEZGVUNU
-N KUBE-SVC-Z6GDYMWE5TV2NNJN
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A PREROUTING -d 172.20.0.1/32 -j DOCKER_OUTPUT
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -d 172.20.0.1/32 -j DOCKER_OUTPUT
-A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING
-A POSTROUTING -d 172.20.0.1/32 -j DOCKER_POSTROUTING
-A POSTROUTING -m addrtype ! --dst-type LOCAL -m comment --comment "kind-masq-agent: ensure nat POSTROUTING directs all non-LOCAL destination traffic to our custom KIND-MASQ-AGENT chain" -j KIND-MASQ-AGENT
-A DOCKER_OUTPUT -d 172.20.0.1/32 -p tcp -m tcp --dport 53 -j DNAT --to-destination 127.0.0.11:37389
-A DOCKER_OUTPUT -d 172.20.0.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 127.0.0.11:37347
-A DOCKER_POSTROUTING -s 127.0.0.11/32 -p tcp -m tcp --sport 37389 -j SNAT --to-source 172.20.0.1:53
-A DOCKER_POSTROUTING -s 127.0.0.11/32 -p udp -m udp --sport 37347 -j SNAT --to-source 172.20.0.1:53
-A KIND-MASQ-AGENT -d 10.244.0.0/16 -m comment --comment "kind-masq-agent: local traffic is not subject to MASQUERADE" -j RETURN
-A KIND-MASQ-AGENT -m comment --comment "kind-masq-agent: outbound traffic is subject to MASQUERADE (must be last in chain)" -j MASQUERADE
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
-A KUBE-POSTROUTING -m mark ! --mark 0x4000/0x4000 -j RETURN
-A KUBE-POSTROUTING -j MARK --set-xmark 0x4000/0x0
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -j MASQUERADE --random-fully
-A KUBE-SEP-6E7XQMQ4RAYOWTTM -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-6E7XQMQ4RAYOWTTM -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.3:53
-A KUBE-SEP-7X37DHTI3VKMHRUW -s 10.244.3.2/32 -m comment --comment "kubernetes-dashboard/dashboard-metrics-scraper" -j KUBE-MARK-MASQ
-A KUBE-SEP-7X37DHTI3VKMHRUW -p tcp -m comment --comment "kubernetes-dashboard/dashboard-metrics-scraper" -m tcp -j DNAT --to-destination 10.244.3.2:8000
-A KUBE-SEP-IT2ZTR26TO4XFPTO -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-IT2ZTR26TO4XFPTO -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.2:53
-A KUBE-SEP-ME73ZWD7U6KL3OSU -s 172.20.0.2/32 -m comment --comment "default/kubernetes:https" -j KUBE-MARK-MASQ
-A KUBE-SEP-ME73ZWD7U6KL3OSU -p tcp -m comment --comment "default/kubernetes:https" -m tcp -j DNAT --to-destination 172.20.0.2:6443
-A KUBE-SEP-MEZP33SDGZXSPSO5 -s 10.244.3.3/32 -m comment --comment "default/my-nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-MEZP33SDGZXSPSO5 -p tcp -m comment --comment "default/my-nginx" -m tcp -j DNAT --to-destination 10.244.3.3:80
-A KUBE-SEP-MKDZHZ7VKZG7DWNK -s 10.244.2.2/32 -m comment --comment "kubernetes-dashboard/kubernetes-dashboard" -j KUBE-MARK-MASQ
-A KUBE-SEP-MKDZHZ7VKZG7DWNK -p tcp -m comment --comment "kubernetes-dashboard/kubernetes-dashboard" -m tcp -j DNAT --to-destination 10.244.2.2:8443
-A KUBE-SEP-N4G2XR5TDX7PQE7P -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
-A KUBE-SEP-N4G2XR5TDX7PQE7P -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.2:9153
-A KUBE-SEP-TIQJFJVSHRJZTTZW -s 10.244.2.3/32 -m comment --comment "default/my-nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-TIQJFJVSHRJZTTZW -p tcp -m comment --comment "default/my-nginx" -m tcp -j DNAT --to-destination 10.244.2.3:80
-A KUBE-SEP-YIL6JZP7A3QYXJU2 -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-YIL6JZP7A3QYXJU2 -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.2:53
-A KUBE-SEP-ZP3FB6NMPNCO4VBJ -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZP3FB6NMPNCO4VBJ -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.3:9153
-A KUBE-SEP-ZXMNUKOKXUTL2MK2 -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZXMNUKOKXUTL2MK2 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.3:53
-A KUBE-SERVICES -d 10.96.223.183/32 -p tcp -m comment --comment "kubernetes-dashboard/kubernetes-dashboard cluster IP" -m tcp --dport 443 -j KUBE-SVC-CEZPIJSAUFW5MYPQ
-A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES -d 10.96.86.215/32 -p tcp -m comment --comment "default/my-nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-L65ENXXZWWSAPRCR
-A KUBE-SERVICES -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -d 10.96.7.211/32 -p tcp -m comment --comment "kubernetes-dashboard/dashboard-metrics-scraper cluster IP" -m tcp --dport 8000 -j KUBE-SVC-Z6GDYMWE5TV2NNJN
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
-A KUBE-SVC-CEZPIJSAUFW5MYPQ ! -s 10.244.0.0/16 -d 10.96.223.183/32 -p tcp -m comment --comment "kubernetes-dashboard/kubernetes-dashboard cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
-A KUBE-SVC-CEZPIJSAUFW5MYPQ -m comment --comment "kubernetes-dashboard/kubernetes-dashboard -> 10.244.2.2:8443" -j KUBE-SEP-MKDZHZ7VKZG7DWNK
-A KUBE-SVC-ERIFXISQEP7F7OF4 ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-IT2ZTR26TO4XFPTO
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.0.3:53" -j KUBE-SEP-ZXMNUKOKXUTL2MK2
-A KUBE-SVC-JD5MR3NA4I4DYORP ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics -> 10.244.0.2:9153" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-N4G2XR5TDX7PQE7P
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics -> 10.244.0.3:9153" -j KUBE-SEP-ZP3FB6NMPNCO4VBJ
-A KUBE-SVC-L65ENXXZWWSAPRCR ! -s 10.244.0.0/16 -d 10.96.86.215/32 -p tcp -m comment --comment "default/my-nginx cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-L65ENXXZWWSAPRCR -m comment --comment "default/my-nginx -> 10.244.2.3:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-TIQJFJVSHRJZTTZW
-A KUBE-SVC-L65ENXXZWWSAPRCR -m comment --comment "default/my-nginx -> 10.244.3.3:80" -j KUBE-SEP-MEZP33SDGZXSPSO5
-A KUBE-SVC-NPX46M4PTMTKRN6Y ! -s 10.244.0.0/16 -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
-A KUBE-SVC-NPX46M4PTMTKRN6Y -m comment --comment "default/kubernetes:https -> 172.20.0.2:6443" -j KUBE-SEP-ME73ZWD7U6KL3OSU
-A KUBE-SVC-TCOU7JCQXEZGVUNU ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-YIL6JZP7A3QYXJU2
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.3:53" -j KUBE-SEP-6E7XQMQ4RAYOWTTM
-A KUBE-SVC-Z6GDYMWE5TV2NNJN ! -s 10.244.0.0/16 -d 10.96.7.211/32 -p tcp -m comment --comment "kubernetes-dashboard/dashboard-metrics-scraper cluster IP" -m tcp --dport 8000 -j KUBE-MARK-MASQ
-A KUBE-SVC-Z6GDYMWE5TV2NNJN -m comment --comment "kubernetes-dashboard/dashboard-metrics-scraper -> 10.244.3.2:8000" -j KUBE-SEP-7X37DHTI3VKMHRUW
```