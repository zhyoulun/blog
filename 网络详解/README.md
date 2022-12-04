- 不能堆砌知识点，例如在讲fcntl的时候，不要讲CLOEXEC相关的知识，因为想讲清楚后者的概念，需要花费更多的篇章
- 简单明了，参考Python神经网络编程

大纲：

- 协议
  - [协议分层概述](chapter-01/01-00.md)
    - LAN/VLAN/VXLAN
  - [一层：物理层](chapter-01/01-01.md)
  - [二层：数据链路层](chapter-01/01-02.md)
  - [三层：网络层](chapter-01/01-03.md)
  - [四层：传输层](chapter-01/01-04.md)
- 设备
  - [网络设备(Network Device)](chapter-02/02-00.md)
    - [路由器(Router)](chapter-02/02-01.md)
    - 交换机(Switch)
      - [网桥（Bridge）](chapter-02/02-02.md)
      - [交换机(Switch)](chapter-02/02-03.md)
    - 集线器(Hub)
      - [中继器(Repeater)](chapter-02/02-04.md)
      - [集线器(Hub)](chapter-02/02-05.md)
    - 无线设备(Wireless Device)
  - 终端设备(End Device)
    - 电脑(PC)
- Linux网络协议栈
  - [namespace](chapter-03/03-08.md)
  - [veth-pair](chapter-03/03-03.md)
  - [容器与host veth pair的关系](chapter-03/03-09.md)
  - [linux-bridge](chapter-03/03-04.md)
  - [tun-and-tap](chapter-03/03-01.md)
  - [ip forward](chapter-03/03-11.md)
  - [ipip](chapter-03/03-10.md)
  - [bridge-and-macvlan](chapter-03/03-07.md)
  - [macvlan-and-ipvlan](chapter-03/03-06.md)
  - [macvlan-and-macvtap](chapter-03/03-02.md)
  - [vlan](chapter-03/03-05.md)
- Linux网络工具
  - [需要关注的工具列表](chapter-04/04-01.md)
  - [iperf](chapter-04/04-02.md)
  - [netstat](chapter-04/04-03.md)
  - [tcplife](chapter-04/04-04.md)
  - [tcpretrans](chapter-04/04-05.md)
  - [udpconnect](chapter-04/04-06.md)
  - [tcpdump](chapter-04/04-07.md)
  - [nicstat](chapter-04/04-08.md)
  - [ip](chapter-04/04-09.md)
  - [ethtool](chapter-04/04-10.md)
  - [snmpget](chapter-04/04-11.md)
  - [lldptool](chapter-04/04-12.md)
  - [ss](chapter-04/04-13.md)
  - wireguard
- k8s下的网络架构
  - kube-proxy
  - calico
  - kube-router




## 参考

- Cisco Packet Tracer，https://www.netacad.com/courses/packet-tracer
- [解决Cisco Packet Tracer无法登录的问题](https://www.youtube.com/watch?v=04VpVYO7F78)
- 计算机网络，谢希仁
- 猿大白@公众号「Linux云计算网络」，https://www.cnblogs.com/bakari/default.html?page=1
- https://www.zhaohuabing.com/
