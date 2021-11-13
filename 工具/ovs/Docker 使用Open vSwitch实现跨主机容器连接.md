### 教程来源

https://www.youtube.com/watch?v=149VMsAvSKI

### 简介

Open vSwitch是一个高质量的、多层虚拟交换机，开源协议是Apache 2.0。目的是让大规模网络自动化可以通过编程扩展，同时仍然支持标准的管理接口和协议（例如NetFlow，sFlow，SPAN，RSPAN，CLI，LACP，802.1ag）

跨主机容器连接原理

![](/static/images/2111/p001.png)

- 通主机容器之间的连接
  - 基于虚拟网桥实现，也就是br0
- 跨主机容器之间的的连接
  - obr0
  - 通过gre

什么是gre隧道：

gre：通用路由协议封装

隧道技术（Tunneling）是一种通过使用互联网络的基础设施在网络之间传递数据的方式。使用隧道传递的数据（或者负载）可以是不同协议的数据帧或者包。隧道协议将其他协议的数据帧或者包重新封装然后通过隧道发送。新的帧头提供路由信息，以便通过互联网传递被封装的负载数据。

### 实验

- Mac OS X + virtualbox
- 两台Ubuntu14.04虚拟机
- 双网卡，Host-Only & NAT
  - Host-Only 虚拟机之间的连接
  - NAT 外部网络类的连接
- 安装 Open VSwitch
  - apt install openvswitch-switch
- 安装网桥管理工具
  - apt install bridge-utils
- IP地址
  - Host1: 192.168.59.103
  - Host2: 192.168.59.104

### 实验步骤

- 建立ovs网桥
  - sudo ovs-vsctl add-br obr0
- 添加gre连接
  - sudo ovs-vsctl add-port obr0 gre0
- 配置docker容器虚拟网桥
- 为虚拟网桥添加ovs接口
- 添加不同Docker容器网段路由

