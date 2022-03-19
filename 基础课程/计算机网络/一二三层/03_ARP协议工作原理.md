### ARP协议作用

ARP协议能实现任意网络层地址到任意物理地址的转换，最常见的用途是从IP地址到以太网地址（MAC地址）的转换

### ARP协议在路由器、交换机中的工作细节

> 这里分析了在不同网段中两个机器之间的通信流程，也可以分析下在同一网段中两个机器之间的通信流程，后者更为简单，无论是PC0---Switch---P1还是PC0---Router---PC1

假设有一个网络：PC0---Switch---Router---PC1，PC0需要向PC1发送ping探测，**PC0和PC1在不同的网段中**

1. PC0开始发ping包给PC1，因为跨网段了，PC0需要先找到网关，经由网关给PC1发送数据，所以需要发送ARP包找网关的MAC地址
   1. 发送方PC0发送ARP请求：源IP地址为PC0的IP地址，源MAC地址为PC0的MAC地址；目标IP地址为网关的地址，目标MAC地址为全F
   2. Switch收到ARP请求包
      1. Switch学习PC0的MAC地址和端口，记录到CAM表
   3. Switch在CAM表中找不到PC0的网关，转发ARP请求到所有端口
   4. Router收到ARP包
      1. Router学习PC0的IP地址和MAC地址
   5. Router响应ARP包：源IP地址为路由器接口IP，源MAC为路由器接口MAC，目标IP为PC0的IP，目标MAC为PC0的MAC
   6. Switch收到ARP包
      1. Switch学习Router的MAC地址和端口，记录到CAM表
   7. Switch转发这个ARP到PC0
   8. PC0获取到网关的MAC地址
2. PC0发送ping包， 源IP是PC0的IP，源MAC为PC0的MAC，目的IP是PC1的IP，目标MAC为PC0网关的MAC
3. ping包到达Switch，Switch转发到PC0网关，即Router
4. ping包到达Router，Router查看自己的路由表，可以找到PC1的IP，但是没有PC1的MAC，无法将此包进行封装转发，封装失败，丢弃包；需要获取PC1的MAC
   1. Router在连接PC1网段的接口发送ARP包：源IP地址是Router在PC1接口的IP地址，源MAC地址是Router上连接PC1接口的MAC地址，目标IP地址PC1的IP地址，目标MAC地址是全F
   2. PC1 收到ARP包，发送响应，将自己的MAC地址返回给路由器
   3. Router收到ARP响应
      1. Router学习PC1的IP地址和MAC地址
5. 此时，Switch和Router已经掌握了所有需要掌握的MAC地址
6. 此时PC0发送第二个ping包，Switch可以转发到Router，Router也可以转发到PC1，并作出逆向的响应

### 备忘

- 交换机：可以看到MAC地址，了解每个MAC地址（链路层）和端口（物理层）之间的映射关系
- 路由器：可以查看IP头部，了解每个IP地址（网络层）和MAC地址（链路层）之间的映射关系

### 网段和掩码

为什么每台电脑都要设置子网掩码?

那先顺着题主的意思来，电脑不用网络掩码，我现在给你三个IP：

- A：10.1.1.2
- B：10.1.1.3
- 还有互联网上的一台服务器D：8.8.8.8

电脑连在交换机上，它们可以通信吗？

A与B通信应该没有问题，A可以通过ARP广播发现B的MAC地址，B也可以发现A的MAC地址，这没有问题。那A如何通过ARP广播发现D的MAC呢？没有办法！因为ARP广播会在本地网关终结（Termination），无法进入Internet。

那我们日常生活中，是如何解决这个问题的？

网络掩码！网络掩码A：10.1.1.2/24网关：10.1.1.1/24，D：8.8.8.8当A试图访问D时，用24位掩码来按位于8.8.8.8，得到网段是8.8.8，和自己的网段10.1.1不相同，就会知道，需要自己的网关（代理）介入，把发给8.8.8.8包先发给网关，网关会有办法把8.8.8.8的IP包送达目的地。

于是A通过24位掩码，计算网关的网段是10.1.1，和自己的网段一样，既然一样就可以发送ARP广播发现网关的MAC地址了（为什么？没有为什么，协议就是这么规定的），然后二层目的地MAC = 网关的MAC，目的IP = 8.8.8.8，这好像有点滑稽，二层与三层指示的目的地址并不一致，这就是三层代理的原理。然后网关就可以依据8.8.8.8来查询路由表，将包发到上游的Internet路由器上，最终到达目的地。


### 一些测试

查看arp缓存表

```bash
zyl@mydev:~$ sudo arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
172.17.0.2               ether   02:42:ac:11:00:02   C                     docker0
10.0.2.2                 ether   52:54:00:12:35:02   C                     enp0s3
192.168.56.2             ether   08:00:27:cf:40:2b   C                     enp0s8
192.168.56.1             ether   0a:00:27:00:00:00   C                     enp0s8
```

执行ping测试

```bash
ping 192.168.0.120
```

执行ping测试后的缓存表

```
zyl@mydev:~$ sudo arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
172.17.0.2               ether   02:42:ac:11:00:02   C                     docker0
10.0.2.2                 ether   52:54:00:12:35:02   C                     enp0s3
192.168.56.120           ether   08:00:27:68:ae:17   C                     enp0s8
192.168.56.2             ether   08:00:27:cf:40:2b   C                     enp0s8
192.168.56.1             ether   0a:00:27:00:00:00   C                     enp0s8
```

删除指定缓存后可以重新测试

```bash
zyl@mydev:~$ sudo arp -d 192.168.56.120
```

tcpdump抓包效果

```
zyl@mydev:~$ sudo tcpdump -n -v -e -i enp0s8 arp
tcpdump: listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
13:02:15.122067 08:00:27:a5:d2:72 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.56.120 tell 192.168.56.108, length 28
13:02:15.122352 08:00:27:a5:d2:72 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.56.120 tell 192.168.56.108, length 46
13:02:15.122453 08:00:27:68:ae:17 > 08:00:27:a5:d2:72, ethertype ARP (0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Reply 192.168.56.120 is-at 08:00:27:68:ae:17, length 46
13:02:15.122477 08:00:27:68:ae:17 > 08:00:27:a5:d2:72, ethertype ARP (0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Reply 192.168.56.120 is-at 08:00:27:68:ae:17, length 46
```

其中`-e`表示输出链路层的header信息

## 参考

- [路由器处理ARP包过程（ZZ）](https://blog.csdn.net/evenness/article/details/8855275)
- [为什么每台电脑都要设置子网掩码?](https://www.zhihu.com/question/263438014/answer/277783704)
- Linux高性能服务器编程
