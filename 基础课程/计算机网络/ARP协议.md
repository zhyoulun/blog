### ARP协议工作原理

ARP协议能实现任意网络层地址到任意物理地址的转换，最常见的用途是从IP地址到以太网地址（MAC地址）的转换

### 为什么每台电脑都要设置子网掩码?

那先顺着题主的意思来，电脑不用网络掩码，我现在给你三个IP：

- A：10.1.1.2
- B：10.1.1.3
- 还有互联网上的一台服务器D：8.8.8.8

电脑连在交换机上，它们可以通信吗？

A与B通信应该没有问题，A可以通过ARP广播发现B的MAC地址，B也可以发现A的MAC地址，这没有问题。那A如何通过ARP广播发现D的MAC呢？没有办法！因为ARP广播会在本地网关终结（Termination），无法进入Internet。

那我们日常生活中，是如何解决这个问题的？

网络掩码！网络掩码A：10.1.1.2/24网关：10.1.1.1/24，D：8.8.8.8当A试图访问D时，用24位掩码来按位于8.8.8.8，得到网段是8.8.8，和自己的网段10.1.1不相同，就会知道，需要自己的网关（代理）介入，把发给8.8.8.8包先发给网关，网关会有办法把8.8.8.8的IP包送达目的地。

于是A通过24位掩码，计算网关的网段是10.1.1，和自己的网段一样，既然一样就可以发送ARP广播发现网关的MAC地址了（为什么？没有为什么，协议就是这么规定的），然后二层目的地MAC = 网关的MAC，目的IP = 8.8.8.8，这好像有点滑稽，二层与三层指示的目的地址并不一致，这就是三层代理的原理。然后网关就可以依据8.8.8.8来查询路由表，将包发到上游的Internet路由器上，最终到达目的地。

### 测试

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

- [为什么每台电脑都要设置子网掩码?](https://www.zhihu.com/question/263438014/answer/277783704)
- Linux高性能服务器编程
