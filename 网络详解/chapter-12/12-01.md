个人理解：构造合法的http请求，让服务耗尽资源（内存、数据库、网络等）


CC攻击（Challenge Collapsar Attack，CC）是针对Web服务器或应用程序的攻击，利用获取信息的标准的GET/POST请求，如请求涉及数据库操作的URI（Universal Resource Identifier）或其他消耗系统资源的URI，造成服务器资源耗尽，无法响应正常请求。

CC攻击是攻击者借助代理服务器生成指向受害主机的合法请求，实现DDoS和伪装攻击。攻击者通过控制某些主机不停地发送大量数据包给对方服务器，造成服务器资源耗尽，直至宕机崩溃。例如，当一个网页访问的人数特别多的时候，用户打开网页就慢了，CC攻击模拟多个用户（多少线程就是多少用户）不停地访问需要大量数据操作（需要占用大量的CPU资源）的页面，造成服务器资源的浪费，CPU的使用率长时间处于100%，将一直在处理连接直至网络拥塞，导致正常的访问被中止。

## 参考

- [CC攻击](https://www.huaweicloud.com/zhishi/challenge-collapsar-attack.html)
