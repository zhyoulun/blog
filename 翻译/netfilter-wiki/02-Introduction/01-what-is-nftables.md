原文：https://wiki.nftables.org/wiki-nftables/index.php/What_is_nftables%3F

# nftables是什么

## nftables是什么

nftables是现代linux kernel packet classification framework. 新的代码应该使用这个，而不是过时的{ip,ip6,arp,eb}_tables (xtables)。对于现存仍为升级的代码库，xtables infrastructure仍然会维护到2021年。自动化工具会帮助你从xtables迁移到nftables。

nftables是一个nutshell:

- 在linux kernel 3.13及以上可用
- 有一个新的命令行工具nft，用于替换iptables
- 它有一个兼容层，允许你在nfttables kenel framework之上运行iptables命令
- It provides a generic set infrastructure that allows you to construct maps and concatenations. You can use these new structures to arrange your ruleset in a multidimensional tree which drastically reduces the number of rules that need to be inspected until reaching the final action on a packet.

## 为什么是nftables

我们毕竟很喜欢iptables，这个工具提供了很多功能，例如filter out traffic on both per-packet and per-flow basis, log suspicious traffic activity, perform NAT and many other things. 在过去的15年中，它被贡献了超过100个扩展。

然而，iptables框架仍然有很多限制，并且不能很容易绕过去：

- Avoid code duplication and inconsistencies: Many of the iptables extensions are protocol specific, so there is no a consolidated way to match packet fields, instead we have one extension for each protocol that it supports. This bloats the codebase with very similar code to perform a similar task: payload matching.
- Faster packet classification through enhanced generic set and map infrastructure.
- Simplified dual stack IPv4/IPv6 administration, through the new inet family that allows you to register base chains that see both IPv4 and IPv6 traffic.
- Better dynamic ruleset updates support.
- Provide a Netlink API for third party applications, just as other Linux Networking and Netfilter subsystem do.
- Address syntax inconsistencies and provide nicer and more compact syntax.

此外还有其它一些问题没有别列出来。在Netfilter community in the 6th Netfilter Workshop in Paris (France)上，触发了nftables的开发。

## 和iptables的主要区别

从使用者的视角来看nftables和iptables的主要区别：

- nftables使用了一个新的语法. The iptables command line tool uses a getopt_long()-based parser where keys are always preceded by double minus, eg. --key or one single minus, eg. -p tcp. In contrast, nftables uses a compact syntax inspired by tcpdump.
- tables和chains是可完全配置的. iptables has multiple pre-defined tables and base chains, all of which are registered even if you only need one of them. There have been reports of even unused base chains harming performance. With nftables there are no pre-defined tables or chains. Each table is explicitly defined, and contains only the objects (chains, sets, maps, flowtables and stateful objects) that you explicitly add to it. Now you register only the base chains that you need. You choose table and chain names and netfilter hook priorities that efficiently implement your specific packet processing pipeline.
- 一个简单的nftables可以执行多个actions. Instead of the matches and single target action used in iptables, an nftables rule consists of zero or more expressions followed by one or more statements. Each expression tests whether a packet matches a specific payload field or packet/flow metadata. Multiple expressions are linearly evaluated from left to right: if the first expression matches, then the next expression is evaluated and so on. If we reach the final expression, then the packet matches all of the expressions in the rule, and the rule's statements are executed. Each statement takes an action, such as setting the netfilter mark, counting the packet, logging the packet, or rendering a verdict such as accepting or dropping the packet or jumping to another chain. As with expressions, multiple statements are linearly evaluated from left to right: a single rule can take multiple actions by using multiple statements. Do note that a verdict statement by its nature ends the rule.
- 每个chian和rule，没有内置的计数器. In nftables counters are optional, you can enable them as needed.
- 对动态ruleset更新有更好的支持. In contrast to the monolithic blob used by iptables, nftables rulesets are represented internally in a linked list. Now adding or deleting a rule leaves the rest of the ruleset untouched, simplifying maintenance of internal state information.
- 简化双栈IPv4/IPv6的管理. The nftables inet family allows you to register base chains that see both IPv4 and IPv6 traffic. It is no longer necessary to rely on scripts to duplicate your ruleset.
- New generic set infrastructure. This infrastructure integrates tightly into the nftables core and allows advanced configurations such as maps, verdict maps and intervals to achieve performance-oriented packet classification. The most important thing is that you can use any supported selector to classify traffic.
- Support for concatenations. Since Linux kernel 4.1, you can concatenate several keys and combine them with maps and verdict maps. The idea is to build a tuple whose values are hashed to obtain the action to be performed nearly O(1).
- 不需要kernel升级，即可支持新的协议. Kernel upgrades can be a time-consuming and daunting task, especially if you have to maintain more than a single firewall in your network. Distribution kernels usually lag the newest release. With the new nftables virtual machine approach, supporting a new protocol will often not require a new kernel, just a relatively simple nft userspace software update.

未完待续
