

目前CNM支持的驱动类型有四种：Null、Bridge、Overlay、Remote。

- Null:不提供网络服务，容器启动后无网络连接。
- Bridge：Docker传统上默认用Linux网桥和Iptables实现的单机网络。
- Overlay：是用vxlan隧道实现的跨主机容器网络。
- Remote：扩展类型，预留给其它外部实现的方案。

## 参考

- [docker——libnetwork插件网络功能](https://www.cnblogs.com/yangmingxianshen/p/10153377.html)
