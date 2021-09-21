### vmstat

> Report virtual memory statistics

2秒间隔，共计5次

```
$ vmstat 2 5
procs -----------memory------------    ---swap-   ----io-- ---system--   ------cpu------
 r  b   swpd    free   buff    cache   si   so    bi    bo     in   cs   us  sy id wa st
 3  1      0 2791140 462208 11551124    0    0     0     6     0    1    2   3  95  0  0
 0  0      0 2788628 462208 11551148    0    0     0    22 29005 56548   3   6  89  0  1
 0  0      0 2804836 462208 11551168    0    0     0    32 28713 55950   3   7  89  0  1
 0  0      0 2794108 462208 11551208    0    0     0    30 28791 56036   4   7  87  0  1
 0  0      0 2794484 462208 11551172    0    0     0    40 28482 55801   3   6  89  0  1
```

- procs：r这一列显示了多少进程在等待cpu，b列显示多少进程正在不可中断的休眠（等待IO）。
- memory：swapd列显示了多少块被换出了磁盘（页面交换），剩下的列显示了多少块是空闲的（未被使用），多少块正在被用作缓冲区，以及多少正在被用作操作系统的缓存。
- swap：显示交换活动：每秒有多少块正在被换入（从磁盘）和换出（到磁盘）。
- io：显示了多少块从块设备读取（bi）和写出（bo）,通常反映了硬盘I/O。
- system：显示每秒中断(in)和上下文切换（cs）的数量。
- cpu：显示所有的cpu时间花费在各类操作的百分比，包括执行用户代码（非内核），执行系统代码（内核），空闲以及等待IO

### free 与 available 的区别
free 是真正尚未被使用的物理内存数量。
available 是应用程序认为可用内存数量，available = free + buffer + cache (注：只是大概的计算方法)

Linux 为了提升读写性能，会消耗一部分内存资源缓存磁盘数据，对于内核来说，buffer 和 cache 其实都属于已经被使用的内存。但当应用程序申请内存时，如果 free 内存不够，内核就会回收 buffer 和 cache 的内存来满足应用程序的请求。这就是稍后要说明的 buffer 和 cache。

### buff 和 cache 的区别

缓冲区

内核缓冲区使用的内存（Buffersin /proc/meminfo）

快取

页面缓存和slab（Cached和 SReclaimable中/proc/meminfo）使用的内存



![](/static/images/2109/p001.jpeg)

- cache 和 buffer 最大的不同：cache 是读的 cache，buffer 是写的 buffer。

总结：

1. buffer和cache都是为了解决互访的两种设备存在速率差异，使磁盘的IO的读写性能或cpu更加高效，减少进程间通信等待的时间
2. buffer：缓冲区-用于存储速度不同步的设备或优先级不同的设备之间传输数据，通过buffer可以减少进程间通信需要等待的时间，当存储速度快的设备与存储速度慢的设备进行通信时，存储快的设备先把数据缓存到buffer上，等到系统统一把buffer上的数据写到速度慢的设备上。常见的有把内存的数据往磁盘进行写操作，这时你可以查看一下buffers
3. cache：缓存区-用于对读取速度比较严格，却因为设备间因为存储设备存在速度差异，而不能立刻获取数据，这时cache就会为了加速缓存一部分数据。常见的是CPU和内存之间的数据通信，因为CPU的速度远远高于主内存的速度，CPU从内存中读取数据需等待很长的时间，而Cache保存着CPU刚用过的数据或循环使用的部分数据，这时Cache中读取数据会更快，减少了CPU等待的时间，提高了系统的性能。

## 参考

- https://blog.csdn.net/gpcsy/article/details/84951675
- https://www.cnblogs.com/M18-BlankBox/p/5326484.html
- https://zhuanlan.zhihu.com/p/409237909

