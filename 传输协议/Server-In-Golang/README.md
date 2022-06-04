协议间的对比：

- kcp的接口和tcp的接口是一致的

协议组合大一统架构设计：

- 应用层：http, rtmp
- 可靠传输：tcp, kcp
- 非可靠传输：udp

### golang的net包

接口与实现

- PacketConn：面向packet的网络连接
  - IPConn：ip网络连接
  - UDPConn：udp网络连接
  - UnixConn：unix domain socket
- Conn：面向stream的网络连接
  - tls.Conn：安全网络连接
  - TCPConn：tcp网络连接
  - IPConn：ip网络连接
  - UDPConn：udp网络连接
  - UnixConn：unix domain socket

### kcp-go分层

```
+-----------------+
| SESSION         |
+-----------------+
| KCP(ARQ)        |
+-----------------+
| FEC(OPTIONAL)   |
+-----------------+
| CRYPTO(OPTIONAL)|
+-----------------+
| UDP(PACKET)     |
+-----------------+
| IP              |
+-----------------+
| LINK            |
+-----------------+
| PHY             |
+-----------------+
```

## 参考

- [golang net包基础解析](https://blog.csdn.net/Wu_Roc/article/details/77169838)
- [https://github.com/xtaci/kcp-go](https://github.com/xtaci/kcp-go)
