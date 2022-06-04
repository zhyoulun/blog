### ALPN的作用

> 摘自《网络协议之:加密传输中的NPN和ALPN》

上面我们介绍SSL/TLS协议的时候，最后一步是切换到应用数据协议，那么客户端是怎么和服务器端讨论协商具体使用哪种应用数据协议呢？是使用HTTP1.1？还是HTTP2？还是SPDY呢？

这里就要用到TLS扩展协议了。而NPN(Next Protocol Negotiation) 和 ALPN (Application Layer Protocol Negotiation) 就是两个TLS的扩展协议。

## 参考

- [网络协议之:加密传输中的NPN和ALPN](https://www.cnblogs.com/flydean/p/15419443.html)
- [ALPN协议](https://blog.csdn.net/laing92/article/details/104366381)
  - 抓包示例
- [应用层协议协商，维基百科](https://zh.m.wikipedia.org/zh-hans/%E5%BA%94%E7%94%A8%E5%B1%82%E5%8D%8F%E8%AE%AE%E5%8D%8F%E5%95%86)
