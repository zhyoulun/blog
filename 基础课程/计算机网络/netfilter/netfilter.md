### netfilter

- netfilter project: provides packet filtering software for the Linux 2.4.x and later kernel series.
- The netfilter project is commonly associated with iptables and its successor nftables.
- The netfilter project enables packet filtering, network address [and port] translation (NA[P]T), packet logging, userspace packet queueing and other packet mangling.
- The netfilter hooks are a framework inside the Linux kernel that allows kernel modules to register callback functions at different locations of the Linux network stack. The registered callback function is then called back for every packet that traverses the respective hook within the Linux network stack.
- iptables is a generic firewalling software that allows you to define rulesets. Each rule within an IP table consists of a number of classifiers (iptables matches) and one connected action (iptables target).
- nftables is the successor of iptables, it allows for much more flexible, scalable and performance packet classification.

### nftables

- nftables 主要由三个组件组成：内核实现、libnl netlink 通信和 nftables 用户空间。
  - 其中内核提供了一个 netlink 配置接口以及运行时规则集评估
  - libnl 包含了与内核通信的基本函数
  - 用户空间可以通过 nft 和用户进行交互。
- nftables 和 iptables 一样，由表（table）、链（chain）和规则（rule）组成，其中表包含链，链包含规则，规则是真正的 action。与 iptables 相比，nftables 主要有以下几个变化：
  - iptables 规则的布局是基于连续的大块内存的，即数组式布局；而 nftables 的规则采用链式布局。其实就是数组和链表的区别
  - iptables 大部分工作在内核态完成，如果要添加新功能，只能重新编译内核；而 nftables 的大部分工作是在用户态完成的，添加新功能很 easy，不需要改内核。
  - iptables 有内置的链，即使你只需要一条链，其他的链也会跟着注册；而 nftables 不存在内置的链，你可以按需注册。由于 iptables 内置了一个数据包计数器，所以即使这些内置的链是空的，也会带来性能损耗。
  - 简化了 IPv4/IPv6 双栈管理
  - 原生支持集合、字典和映射
- nft 需要以 root 身份运行或使用 sudo 运行


### 架构图

![](/static/images/2203/p018.svg)

![](/static/images/2108/p001.png)



## 参考

- [Netfilter hooks](https://wiki.nftables.org/wiki-nftables/index.php/Netfilter_hooks)
- [nftables 使用教程](https://fuckcloudnative.io/posts/using-nftables/)
- [https://www.netfilter.org/](https://www.netfilter.org/)
- [过渡到 nftables](https://zhuanlan.zhihu.com/p/88981486)
- [[译] 深入理解 iptables 和 netfilter 架构](https://arthurchiao.art/blog/deep-dive-into-iptables-and-netfilter-arch-zh/)
