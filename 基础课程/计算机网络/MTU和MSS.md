### 概念

- MTU: Maxitum Transmission Unit 最大传输单元
  - 以太网最大的数据帧是 1518Bytes，刨去以太网帧的帧头（目标MAC地址，源MAC地址和类型）14Bytes 以及帧尾 CRC(大家有时候叫它: FCS) 校验部分4Bytes 那么剩下承载上层协议的地方也就是 Data 域最大就只能有1500Bytes 这个值我们就把它称之为 MTU
- MSS: Maxitum Segment Size 最大分段大小

### 以太网数据帧格式

![](/static/images/2202/p005.png)

### 分层数据包大小限制

- 物理链路层
  - 帧的最大传输单元（MTU，max transmit unit），帧最多能携带多少上层协议数据
  - 对于以太网帧，MTU是通常是（不一定是）1500字节；过长的IP数据报会被分片传输
- 传输层
  - 最大报文段大小（MSS，max segment size），指的是TCP报文的最大数据报长度，其中不包括TCP首部长度，一般来说：MSS=MTU-IP首部大小-TCP首部大小
  - MSS由TCP链接的过程中，双方协商得出，其中SYN报文中的选项部分包含了这部分信息

### 传输层长度计算

- UDP 包的大小(MSS)是 1500 - IP头(20) - UDP头(8) = 1472(BYTES)
- TCP 包的大小(MSS)是 1500 - IP头(20) - TCP头(20) = 1460 (BYTES)
- PPPoE导致MTU变小了，以太网的 MTU 是 1500，再减去PPP的包头包尾的开销（8Bytes），MTU 就变成1492。

### 如何确认MTU的值

```bash
ping -M do -s 1472 ip_addr
```

参数说明：

- `-M hint`：Select Path MTU Discovery strategy. hint may be either
  - do (prohibit fragmentation, even local one), 不拆包
  - want (do PMTU discovery, fragment locally when packet size is large),
  - or dont (do not set DF flag).
- `-s packetsize`：Specifies the number of data bytes to be sent. The default is 56, which translates into 64 ICMP data bytes when combined with the 8 bytes of ICMP header data. 设置包大小

成功示例

```bash
ping 10.0.0.1 -M do -s 1472
PING 10.0.0.1 (10.0.0.1) 1472(1500) bytes of data.
1480 bytes from 10.0.0.1: icmp_seq=1 ttl=53 time=5.61 ms
1480 bytes from 10.0.0.1: icmp_seq=2 ttl=53 time=3.98 ms
```

失败示例

```bash
$ ping 10.0.0.1 -M do -s 1473
PING 10.0.0.1 (10.0.0.1) 1473(1501) bytes of data.
ping: local error: Message too long, mtu=1500
ping: local error: Message too long, mtu=1500
ping: local error: Message too long, mtu=1500
```

### TCP和UDP如何防止数据包过大

- UDP不会分段，就由IP来分。
  - UDP需要避免包过大
- TCP会分段，当然就不用IP来分了！
  - TCP协议在建立连接的时候通常要协商双方的MSS值，每一方都有用于通告它期望接收的MSS选项（MSS选项只出现在SYN报文段中，即TCP三次握手的前两次）

## 参考

  - [TCP UDP 数据包长度(MSS)总结](https://www.jianshu.com/p/fbba3556fc40)
  - [MTU对IP协议、UDP协议、TCP协议的影响](https://blog.csdn.net/smile_zhangw/article/details/82424242)
  - [linux下使用ping测试MTU](https://blog.csdn.net/jiujiu372/article/details/76264208)
  - [https://linux.die.net/man/8/ping](https://linux.die.net/man/8/ping)
