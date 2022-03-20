### 查看iptables详情

```
iptables -L -v -n
```

- `-v`：更多的信息
- `-n`：直接展示ip, port

### 禁止除22端口和80端口外其它所有端口

清除目前所有规则(慎用)；注意：如果是基于ssh登录的机器，这句话可能导致无法登录机器

```
iptables -F
```

允许通过tcp协议访问22端口(先配置,否则无法使用ssh连接)

```
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

禁止访问除22端口以外所有端口

```
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

允许在80端口接收请求

```
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

允许本地内部访问

> 如果不设置，会导致curl 127.0.0.1:80无法正常工作；
> 表现是：
> 1. 发送方发送SYN，接收方可以收到：发送方从OUTPUT正常发送数据；接收方从INPUT正常接收数据，
> 2. 接收方发送ACK，发送方无法接收：接收方从OUTPUT正常输出数据；发送方的端口因为不是22或者80，无法从INPUT接收数据

```
iptables -A INPUT -i lo -j ACCEPT
```

允许数据包响应

> 如果不设置，会导致curl www.baidu.com无法正常工作；分析过程同上

```
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

允许从本地访问外部端口

> 因为已经设置了iptables -P OUTPUT ACCEPT，这句话可省略

```
iptables -A OUTPUT -j ACCEPT
```

设置结果

```bash
$ iptables -L -n -v
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 1732 95968 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
   43  2621 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
    5  1135 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
    6   726 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    4   312 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0
```

### 丢包

```
iptables -I INPUT -s x.x.x.x -m statistic --mode random --probability 0.2 -j DROP
```

statistic模块解释：

statistic
This module matches packets based on some statistic condition. It supports two distinct modes settable with the --mode option.
Supported options:

- --mode mode
  - Set the matching mode of the matching rule, supported modes are random and nth.
- --probability p
  - Set the probability for a packet to be randomly matched. It only works with the random mode. p must be within 0.0 and 1.0. The supported granularity is in 1/2147483648th increments.
- --every n
  - Match one packet every nth packet. It works only with the nth mode (see also the --packet option).
- --packet p
  - Set the initial counter value (0 <= p <= n-1, default 0) for the nth mode.

## 参考

- [iptables 禁止除22端口外其他所有端口](https://blog.csdn.net/qq_44273583/article/details/116661747)
