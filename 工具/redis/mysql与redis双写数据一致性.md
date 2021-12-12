## 三种经典的缓存模式

### cache-aside模式

旁路缓存模式，它的提出是为了尽可能解决缓存与数据库的数据不一致的问题

读流程

![](/static/images/2112/p001.awebp)

写流程

![](/static/images/2112/p002.awebp)

### read-through/write-through(读写穿透)

在该模式中，服务端把缓存作为主要数据存储。

read-through

Read-Through实际只是在Cache-Aside之上进行了一层封装，它会让程序代码变得更简洁，同时也减少数据源上的负载。

![](/static/images/2112/p003.awebp)

![](/static/images/2112/p004.awebp)

write-through

![](/static/images/2112/p005.awebp)

### write behind(异步缓存写入)

Write behind跟Read-Through/Write-Through有相似的地方，都是由Cache Provider来负责缓存和数据库的读写。它两又有个很大的不同：Read/Write Through是同步更新缓存和数据的，Write Behind则是只更新缓存，不直接更新数据库，通过批量异步的方式来更新数据库。

![](/static/images/2112/p006.awebp)

## 参考

- [Redis与MySQL双写一致性如何保证？](https://juejin.cn/post/6964531365643550751)
