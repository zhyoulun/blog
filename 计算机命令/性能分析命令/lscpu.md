展示和cpu架构相关的信息

总结一下：

- 一个节点可以有多个CPU，一个CPU可以有多个CPU核心，一个CPU核心可以有一个及以上的线程
- 一个核心同一个时间点只能执行一个任务（进程或线程）
- 核心间是并行的
- 如果开启超线程能力，一个核心支持两个线程，线程间是并发的，不是并行的



示例

```bash
zyl@mydev:~$ lscpu
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              4 # 4个逻辑核，vCPU
On-line CPU(s) list: 0-3
Thread(s) per core:  1 # 每个核1个线程；一般是1或者2，2代表是超线程模式
Core(s) per socket:  4 # 一个cpu有四个核
Socket(s):           1 # 代表有一个CPU插槽，也就是一个物理CPU设备
NUMA node(s):        1
Vendor ID:           GenuineIntel
CPU family:          6
Model:               126
Model name:          Intel(R) Core(TM) i7-1068NG7 CPU @ 2.30GHz
Stepping:            5
CPU MHz:             2303.998
BogoMIPS:            4607.99
Hypervisor vendor:   KVM
Virtualization type: full
L1d cache:           48K
L1i cache:           32K
L2 cache:            512K
L3 cache:            8192K
NUMA node0 CPU(s):   0-3
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase avx2 invpcid rdseed clflushopt md_clear flush_l1d arch_capabilities
```

## 参考

- [节点、cpu、cpu核、进程、线程，以及运行程序和OpenMP](http://www.aais.pku.edu.cn/clshpc/quession/shownews.php?id=48)
- [什么是超线程？](https://www.intel.cn/content/www/cn/zh/gaming/resources/hyper-threading.html)
- [三分钟速览cpu,socket,core,thread等术语之间的关系](https://cloud.tencent.com/developer/article/1736628)