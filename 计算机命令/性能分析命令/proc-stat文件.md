# /proc/stat 

- user	用户态时间
- nice	用户态时间(低优先级，nice>0)
- system	内核态时间
- idle	空闲时间
- iowait	I/O等待时间
- irq	硬中断
- softirq	软中断
- steal   Stolen time, which is the time spent in other operating systems when running in a virtualized environment
- guest
- guest_nice

### iowait解释

对 %iowait 常见的误解有两个：一是误以为 %iowait 表示CPU不能工作的时间，二是误以为 %iowait 表示I/O有瓶颈。

第一种误解太低级了，%iowait 的首要条件就是CPU空闲，既然空闲当然就可以接受运行任务，只是因为没有可运行的进程，CPU才进入空闲状态的。那为什么没有可运行的进程呢？因为进程都处于休眠状态、在等待某个特定事件：比如等待定时器、或者来自网络的数据、或者键盘输入、或者等待I/O操作完成，等等。

第二种误解更常见，为什么人们会认为 %iowait 偏高是有I/O瓶颈的迹象呢？他们的理由是：”%iowait  的第一个条件是CPU空闲，意即所有的进程都在休眠，第二个条件是仍有未完成的I/O请求，意味着进程休眠的原因是等待I/O，而 %iowait 升高则表明因等待I/O而休眠的进程数量更多了、或者进程因等待I/O而休眠的时间更长了。“ 听上去似乎很有道理，但是不对：

首先 %iowait 升高并不能证明等待I/O的进程数量增多了，也不能证明等待I/O的总时间增加了。为什么呢？看看下面两张图就明白了。

第一张图演示的是，在I/O完全一样的情况下，CPU忙闲状态的变化就能够影响 %iowait 的大小。下图我们看到，在CPU繁忙期间发生的I/O，无论有多少，%iowait 的值都是不受影响的（因为 %iowait 的第一个前提条件就是CPU必须空闲）；当CPU繁忙程度下降时，有一部分I/O落入了CPU空闲的时间段内，这就导致了 %iowait 升高。可见，I/O并没有变化，%iowait 却升高了，原因仅仅是CPU的空闲时间增加了。请记住，系统中有成百上千的进程数，任何一个进程都可以引起CPU和I/O的变化，因为 %iowait、%idle、%user、%system 等这些指标都是全局性的，并不是特指某个进程。

![](/static/images/2109/p003.png)

再往下看第二张图，它描述了另一种情形：假设CPU的繁忙状况保持不变的条件下，即使 %iowait 升高也不能说明I/O负载加重了。

如果2个I/O请求依次提交、使得整个时段内始终有I/O在进行，那么 %iowait 是100%；

如果3个I/O请求同时提交，因为系统有能力同时处理多个I/O，所以3个并发的I/O从开始到结束的时间与一个I/O一样，%iowait 的结果只有50%。

2个I/O使 %iowait 达到了100%，3个I/O的 %iowait 却只有50%，显然 %iowait 的高低与I/O的多少没有必然关系，而是与I/O的并发度相关。所以，仅凭 %iowait 的上升不能得出I/O负载增加 的结论。

![](/static/images/2109/p004.png)

这就是为什么说 %iowait 所含的信息量非常少的原因，它是一个非常模糊的指标，如果看到 %iowait 升高，还需检查I/O量有没有明显增加，avserv/avwait/avque等指标有没有明显增大，应用有没有感觉变慢，如果都没有，就没什么好担心的。

## 参考

- [/proc/stat解析](http://gityuan.com/2017/08/12/proc_stat/)
- [https://man7.org/linux/man-pages/man5/proc.5.html](https://man7.org/linux/man-pages/man5/proc.5.html)
- [理解 %IOWAIT (%WIO)](http://linuxperf.com/?p=33)