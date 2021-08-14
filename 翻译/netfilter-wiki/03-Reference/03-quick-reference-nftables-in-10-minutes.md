原文：https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes

# nftables 10分钟快速入门

如下是在使用nftables前需要了解的一些基本概念：

- table: refers to a container of chains with no specific semantics.
- chain: within a table refers to a container of rules.
- rule: refers to an action to be configured within a chain.

## nft命令行

nft是一个命令行工具，用于在userspace和nftables交互。

### tables

family refers to a one of the following table types: ip, arp, ip6, bridge, inet, netdev.

```bash
% nft list tables [<family>]
% nft list table [<family>] <name> [-n] [-a]
% nft (add | delete | flush) table [<family>] <name>
```

- The argument -n shows the addresses and other information that uses names in numeric format.
- The -a argument is used to display the handle.


### chains

**type** refers to the kind of chain to be created. Possible types are:

- filter: Supported by arp, bridge, ip, ip6 and inet table families.
- route: Mark packets (like mangle for the output hook, for other hooks use the type filter instead), supported by ip and ip6.
- nat: In order to perform Network Address Translation, supported by ip and ip6.

**hook** refers to an specific stage of the packet while it's being processed through the kernel. More info in Netfilter hooks.

- The hooks for ip, ip6 and inet families are: prerouting, input, forward, output, postrouting.
- The hooks for arp family are: input, output.
- The bridge family handles ethernet packets traversing bridge devices.
- The hook for netdev is: ingress.

**priority** refers to a number used to order the chains or to set them between some Netfilter operations. Possible values are: NF_IP_PRI_CONNTRACK_DEFRAG (-400), NF_IP_PRI_RAW (-300), NF_IP_PRI_SELINUX_FIRST (-225), NF_IP_PRI_CONNTRACK (-200), NF_IP_PRI_MANGLE (-150), NF_IP_PRI_NAT_DST (-100), NF_IP_PRI_FILTER (0), NF_IP_PRI_SECURITY (50), NF_IP_PRI_NAT_SRC (100), NF_IP_PRI_SELINUX_LAST (225), NF_IP_PRI_CONNTRACK_HELPER (300).

**policy** is the default verdict statement to control the flow in the chain. Possible values are: accept, drop, queue, continue, return.

```bash
% nft (add | create) chain [<family>] <table> <name> [ { type <type> hook <hook> [device <device>] priority <priority> \; [policy <policy> \;] } ]
% nft (delete | list | flush) chain [<family>] <table> <name>
% nft rename chain [<family>] <table> <name> <newname>
```

### rules

handle is an internal number that identifies a certain rule.

position is an internal number that is used to insert a rule before a certain handle.

```bash
% nft add rule [<family>] <table> <chain> <matches> <statements>
% nft insert rule [<family>] <table> <chain> [position <position>] <matches> <statements>
% nft replace rule [<family>] <table> <chain> [handle <handle>] <matches> <statements>
% nft delete rule [<family>] <table> <chain> [handle <handle>]
```

未完待续
