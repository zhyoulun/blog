## 精写目录

### TCP/IP协议

- 以太网帧(ethernet frame)
- IP包(ip packet)
- tcp段(tcp segment)
- udp数据报(udp datagram)

- 未整理
  - 协议
    - [术语](chapter-01/01-05.md)
    - [协议分层概述](chapter-01/01-00.md)
    - [一层：物理层](chapter-01/01-01.md)
      - 宽带接入技术
        - ADSL技术
        - 光纤同轴混合网
        - FTTx技术/光纤到户
    - [二层：数据链路层](chapter-01/01-02.md)
      - [ARP](chapter-01/01-08.md)
      - [MTU vs MSS](chapter-01/01-02/01-02-01.md)
      - [MAC唯一性问题](chapter-01/01-02/01-02-03.md)
      - [二层转发原理](chapter-01/01-02/01-02-04.md)
      - 以太网帧格式
      - CSMA/CD协议
      - [LAN](chapter-01/01-07/01-07-01.md)
      - [VLAN](chapter-01/01-07.md)
      - VXLAN
      - STP
    - [三层：网络层](chapter-01/01-03.md)
      - [IP地址格式](chapter-01/01-03-01.md)
      - 子网
      - [三层转发原理](chapter-01/01-03/01-03-02.md)
      - [snat和dnat](chapter-01/01-04/01-04-15.md)
      - IPv6
      - 单播/组播or多播orMultiCast/广播orBroadCast/任播orAnyCast
      - [任播/AnyCast](chapter-01/01-03/01-03-03.md)
      - IGMP(多播)
      - ICMP
      - 路由选择协议
        - 内部网关协议RIP
        - 内部网关协议OSPF
        - 外部网关协议BGP
        - 路由器的构成
      - 虚拟专用网VPN
    - 四层：传输层-TCP
      - [超时重传](chapter-01/01-04/01-04-02.md)
      - [SACK](chapter-01/01-04/01-04-03.md)
      - [tcp_fastopen](chapter-01/01-04/01-04-04.md)
      - [tcp平滑迁移](chapter-01/01-04/01-04-05.md)
      - [unp-echo](chapter-01/01-04/01-04-06.md)
      - [unp-daytime](chapter-01/01-04/01-04-07.md)
      - [golang-echo](chapter-01/01-04/01-04-08.md)
      - [tcp socket](chapter-01/01-04/01-04-09.md)
      - [TCP基础知识](chapter-01/01-04/01-04-10.md)
      - [TCP握手与挥手](chapter-01/01-04/01-04-11.md)
      - [TCP协议阅读备忘](chapter-01/01-04/01-04-12.md)
      - [socket编程常见问题](chapter-01/01-04/01-04-13.md)
      - [粘包](chapter-01/01-04/01-04-14.md)
      - TCP协议
        - 连接管理
        - 超时与重传
        - 数据流与窗口管理
        - 拥塞控制
        - 保活机制
      - TIME_WAIT
    - 四层：传输层-UDP
        - [UDP收发效率](chapter-01/01-09/01-09-01.md)
        - [GRO](chapter-01/01-09/01-09-02.md)
        - [TCP vs UDP](chapter-01/01-09/01-09-03.md)
    - [IPv6](chapter-01/01-06.md)
    - 安全
      - 网络层安全
        - IPSec
      - 传输层安全
        - tls
      - DNS安全
    - 应用层
      - [DNS](chapter-01/01-10.md)
      - [DHCP](chapter-01/01-11/01-11-01.md)
      - FTP
      - 简单网络管理协议SNMP
      - HTTP
      - [websocket](chapter-01/01-11/01-11-02.md)

### 套接字编程

- 未整理
  - 套接字编程
    - 基本函数/帮助函数
    - TCP套接字
    - I/O复用
    - UDP套接字
    - 高级I/O函数
    - 非阻塞I/O

### Linux网络相关内核参数

- net.core
- net.ipv4
  - [ip_forward](chapter-13/13-01.md)
  - [tcp_syn_retries](chapter-01/01-04/01-04-01.md)

### 工具

- [网络相关工具列表](chapter-04/04-01.md)
- ip
  - 未整理
    - [ip](chapter-04/04-09.md)
- iptables
  - [iptables介绍](chapter-07/07-05.md)
  - [iptables使用](chapter-07/07-08.md)
  - [iptables阅读更多](chapter-07/07-09.md)
  - 未整理
    - netfilter/iptables
      - [iptables术语](chapter-07/07-01.md)
      - [iptables tables](chapter-07/07-03.md)
      - [iptables实验](chapter-07/07-04.md)
      - [netfilter](chapter-07/07-06.md)
      - [iptables](chapter-04/04-17.md)
      - [nft](chapter-04/04-18.md)
      - [Introduce-01-what-is-nftables](chapter-04/04-41.md)
      - [Introduce-02-how-to-obtain-help](chapter-04/04-42.md)
      - [Reference-01-man-nft](chapter-04/04-43.md)
      - [Reference-02-man-nft-mankier](chapter-04/04-44.md)
      - [Reference-03-quick-reference-nftables-in-10-minutes](chapter-04/04-45.md)
      - [常用命令代理使用方法](chapter-04/04-46.md)
      - [curl](chapter-04/04-19.md)
      - [iperf](chapter-04/04-02.md)
      - [netstat](chapter-04/04-03.md)
      - [tcplife](chapter-04/04-04.md)
      - [tcpretrans](chapter-04/04-05.md)
      - [udpconnect](chapter-04/04-06.md)
      - [tcpdump](chapter-04/04-07.md)
      - [wireshark](chapter-04/04-36.md)
      - [nicstat](chapter-04/04-08.md)
      - [ethtool](chapter-04/04-10.md)
      - [snmpget](chapter-04/04-11.md)
      - [lldptool](chapter-04/04-12.md)
      - [ss](chapter-04/04-13.md)
      - [wireguard](chapter-04/04-14.md)
      - [dig](chapter-04/04-15.md)
      - [nslookup](chapter-04/04-16.md)
      - [host](chapter-04/04-20.md)
      - [ifconfig](chapter-04/04-21.md)
      - [iftop](chapter-04/04-22.md)
      - [iproute2mac](chapter-04/04-23.md)
      - [nali](chapter-04/04-24.md)
      - [nc](chapter-04/04-25.md)
      - [polipo](chapter-04/04-26.md)
      - [ping](chapter-04/04-27.md)
      - [route](chapter-04/04-28.md)
      - [ssh](chapter-04/04-29.md)
      - [tcconfig](chapter-04/04-30.md)
      - [tcping](chapter-04/04-32.md)
      - [traceroute](chapter-04/04-33.md)
      - [vpn](chapter-04/04-35.md)
      - [telnet](chapter-04/04-31.md)
      - snoop
      - dtrace
      - stap
      - perf
      - sar
      - nicstat
      - pathchar
      - lsof
      - nfsstat
      - iftop
      - /proc/net
      - stress
      - MAC环境
        - [netstat](chapter-04/04-34/04-34-01.md)
- lvs
  - [LVS使用](chapter-07/07-12.md)
  - [lvs NAT模式](chapter-07/07-10.md)
  - [lvs DR模式](chapter-04/04-38.md)
  - [lvs TUN模式](chapter-07/07-14.md)
  - [lvs FullNAT模式](chapter-07/07-15.md)
  - [LVS各模式的原理](chapter-07/07-13.md)
  - [LVS各模式间的对比总结](chapter-07/07-07.md)
  - [keepalived](chapter-07/07-11.md)
  - 未整理
    - [lvs](chapter-04/04-34.md)
      - [lvs-nat模式](chapter-04/04-39.md)
      - [lvs-tun模式](chapter-04/04-40.md)

### Linux网络虚拟化

- 未整理
  - [namespace](chapter-03/03-08.md)
  - [veth-pair](chapter-03/03-03.md)
  - [linux-bridge](chapter-03/03-04.md)
  - [容器与host veth pair的关系](chapter-03/03-09.md)
  - [tun-and-tap](chapter-03/03-01.md)
  - linux隧道
    - [ipip](chapter-03/03-10.md)
    - [GRE](chapter-03/03-14.md)
    - sit
    - ISATAP
    - VTI
  - [vlan](chapter-03/03-05.md)
    - [VLAN虚拟局域网](chapter-03/03-13.md)
  - [vxlan](chapter-03/03-12.md)
  - [bridge-and-macvlan](chapter-03/03-07.md)
  - [macvlan-and-ipvlan](chapter-03/03-06.md)
  - [macvlan-and-macvtap](chapter-03/03-02.md)

### 虚拟设备

- 路由器
  - [使用linux搭建路由器](chapter-02/02-01.md)

### 物理设备

- 未整理
  - 设备
    - [网络设备(Network Device)](chapter-02/02-00.md)
      - 集线器(Hub)
        - [中继器(Repeater)](chapter-02/02-04.md)
        - [集线器(Hub)](chapter-02/02-05.md)
      - 交换机(Switch)
        - [网桥（Bridge）](chapter-02/02-02.md)
        - [交换机(Switch)](chapter-02/02-03.md)
        - [交换机性能参数](chapter-02/02-06.md)
      - [冲突域的产生与解决](chapter-02/02-07.md)
      - [广播域](chapter-02/02-08.md)
      - 路由器(Router)
      - 无线设备(Wireless Device)
    - 终端设备(End Device)
      - 电脑(PC)

## 初版目录

- Linux网络体系
  - 关键数据结构
    - [socket_buffer](chapter-05/05-01.md)
    - [net_device](chapter-05/05-02.md)
  - 内核参数
  - 网络设备初始化
  - 传输和接收
    - 中断和网络驱动程序
    - 帧的接收
  - 桥接实现
- 个人理解
  - [VirtualBox中的Host-Only网络](chapter-06/06-03.md)
  - [VirtualBox中的内部网络](chapter-06/06-02.md)
  - [虚拟机NAT&桥接](chapter-01/01-02/01-02-02.md)
    - [VirtualBox中的NAT网络](chapter-06/06-04.md)
    - [VirtualBox中的桥接网卡](chapter-06/06-01.md)
  - [未整理的好文章-虚拟机网络](chapter-06/06-07.md)
  - [透明代理](chapter-06/06-05.md)
  - [流量分割](chapter-06/06-06.md)
- 系统观测
  - [bfc](chapter-08/08-01.md)
  - [ebpf-exporter](chapter-08/08-02.md)
  - [cilium-ebpf](chapter-08/08-03.md)
- k8s下的网络架构
  - [cni plugins](chapter-09/09-04.md)
  - [cni学习-tkng](chapter-09/09-03.md)
  - [kindnet](chapter-09/09-02.md)
  - [kube-proxy](chapter-09/09-01.md)
  - calico
  - kube-router
  - [Docker 使用Open vSwitch实现跨主机容器连接](chapter-09/09-05.md)
  - [BGP 如何引流到 Cilium 的 IP 上](chapter-09/09-06.md)
- 微服务 && service mesh
- 概念
  - [混杂模式](chapter-10/10-01.md)
  - [国际出口带宽](chapter-10/10-02.md)
  - [中国骨干网](chapter-10/10-03.md)
  - [SDN](chapter-10/10-04.md)
  - [AS](chapter-10/10-05.md)
  - [IXP](chapter-10/10-06.md)
- 性能
- 安全
  - 防火墙
  - [cc攻击](chapter-12/12-01.md)

## 思路备忘

- 目标读者：对网络感兴趣、但是兜兜转转走弯路入门中的人
- 用详细的示意图把事情讲清楚
- 不能堆砌知识点，例如在讲fcntl的时候，不要讲CLOEXEC相关的知识，因为想讲清楚后者的概念，需要花费更多的篇章
- 不进行穷举性的罗列，只确保读者能学会概要，然后告知他哪里可以查询详细的使用清单
- 简单明了，参考Python神经网络编程
- 关注重点知识，非重点忽略
- 不包含音视频相关

## 计划

- https://trello.com/b/9yViIqCV/network-book


- 第一遍，把每个知识点画清楚
  - 8个月
- 第二遍，通读调整
  - 2个月
- 开源（看情况）
- 第二遍通读调整
  - 1个月
- 出版
  - 1个月


## 参考

- 计算机网络，谢希仁
- 计算机网络，自顶向下方法
- TCP/IP详解卷一
- UNIX网络编程 卷1 套接字联网API
- 深入理解Linux网络技术内幕
- 路由与交换技术
- 局域网交换机和路由器的配置与管理
- k8s网络权威指南
- BPF之巅
- 性能之巅
- https://www.cloudflare.com/zh-cn/learning/
- Cisco Packet Tracer，https://www.netacad.com/courses/packet-tracer
- [解决Cisco Packet Tracer无法登录的问题](https://www.youtube.com/watch?v=04VpVYO7F78)
- 猿大白@公众号「Linux云计算网络」，https://www.cnblogs.com/bakari/default.html?page=1
- https://www.zhaohuabing.com/
- sdn: https://tonydeng.github.io/sdn-handbook/
- tcp/ip：http://static.kancloud.cn/lifei6671/tcp-ip

- https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html
- https://draveness.me/whys-the-design/
- https://draveness.me/sketch-and-sketch/
- https://draveness.me/few-words-time-management/
- https://pixso.cn/app/editor/g0Wqq98QTWnWqNnD8QMUlA?page-id=3%3A1084
- https://sysctl-explorer.net/fs/
- https://superproxy.github.io/docs/lvs/index.html
- http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-NAT.html