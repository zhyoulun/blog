
### 查看默认规则集

```bash
root@mydev:/home/zyl# nft list ruleset
table inet filter {
	chain input {
		type filter hook input priority 0; policy accept;
	}

	chain forward {
		type filter hook forward priority 0; policy accept;
	}

	chain output {
		type filter hook output priority 0; policy accept;
	}
}
```

### 清除规则

```
nft flush ruleset
```

### 创建表

```
nft add table inet my_table
```

nftables 的每个表只有一个地址簇，并且只适用于该簇的数据包。表可以指定五个簇中的一个：

| nftables簇 | iptables命令行工具 |
|-|-|
| ip |	iptables |
| ip6 |	ip6tables |
| inet |	iptables和ip6tables |
| arp |	arptables |
| bridge |	ebtables |

inet 同时适用于 IPv4 和 IPv6 的数据包，即统一了 ip 和 ip6 簇，可以更容易地定义规则，下文的示例都将采用 inet 簇

示例

```bash
root@mydev:~# nft list tables
table inet filter
root@mydev:~# nft add table inet my_table
root@mydev:~# nft list tables
table inet filter
table inet my_table
```

### 查看表

```
nft list tables
```

示例

```
root@mydev:~# nft list tables
table inet filter
table inet my_table
```

### 删除表

```
nft delete table inet my_table
```

示例

```bash
root@mydev:~# nft list tables
table inet filter
table inet my_table
root@mydev:~# nft delete table inet my_table
root@mydev:~# nft list tables
table inet filter
```

### 创建chain

```
nft add chain inet my_table my_chain
```

示例

```bash
root@mydev:~# nft list ruleset
table inet filter {
	...
}
table inet my_table {
	chain my_chain {
	}
}
```

### 查询chain

```
nft list chain inet my_table my_chain
```

示例

```bash
root@mydev:~# nft list chain inet my_table my_chain
table inet my_table {
	chain my_chain {
	}
}
```

### 删除chain

```
nft delete chain inet my_table my_chain
```

### 创建rule

```
nft add rule inet my_table my_chain ip saddr 192.168.56.109 drop
```

```bash
root@mydev:~# nft add rule inet my_table my_chain ip saddr 192.168.56.109 drop
root@mydev:~# nft list table inet my_table
table inet my_table {
	chain my_chain {
		ip saddr 192.168.56.109 drop
	}
}
```

### 使用配置文件

nft -f /etc/nftables.conf

文件内容`/etc/nftables.conf`

```
flush ruleset

table firewall {
  chain incoming {
    type filter hook input priority 0; policy drop;

    # established/related connections
    ct state established,related accept

    # loopback interface
    iifname lo accept

    # icmp
    icmp type echo-request accept

    # open tcp ports: sshd (22), httpd (80)
    tcp dport {ssh, http} accept
  }
}
```

测试

```bash
zyl@zyldev32:~$ nc -w 1 -v 192.168.56.108 80
nc: connect to 192.168.56.108 port 80 (tcp) failed: Connection refused
zyl@zyldev32:~$ nc -w 1 -v 192.168.56.108 81
nc: connect to 192.168.56.108 port 81 (tcp) timed out: Operation now in progress
```

## 参考

- [Netfilter hooks](https://wiki.nftables.org/wiki-nftables/index.php/Netfilter_hooks)
- [nftables 使用教程](https://fuckcloudnative.io/posts/using-nftables/)
- [https://www.netfilter.org/](https://www.netfilter.org/)
- [过渡到 nftables](https://zhuanlan.zhihu.com/p/88981486)
- [第 47 章 NFTABLES 入门](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking)