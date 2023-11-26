### 描述

SACK是一个TCP的选项，来允许TCP单独确认非连续的片段，用于告知真正丢失的包，只重传丢失的片段。

要使用SACK，2个设备必须同时支持SACK才可以。

### 建联阶段，SYN包

建立连接的时候需要使用SACK Permitted的option：

![](/static/images/2203/p003.png)

![](/static/images/2203/p004.png)

### 发送数据阶段，ACK包

如果允许，后续的传输过程中TCP segment中的可以携带SACK option，这个option内容包含一系列的非连续的没有确认的数据的seq range。

![](/static/images/2203/p005.png)

Kind 5  Length  剩下的都是没有确认的segment的range了 比如说segment 501-600 没有被确认，那么Left Edge of 1st Block = 501，Right Edge of 1st Block = 600，TCP的选项不能超过40个字节，所以边界不能超过4组。

## 参考

- [TCP-IP详解：SACK选项（Selective Acknowledgment）](https://blog.csdn.net/wdscq1234/article/details/52503315)
