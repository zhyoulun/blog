```c
// Boot loader.
//
// Part of the boot block, along with bootasm.S, which calls bootmain().
// bootasm.S has put the processor into protected 32-bit mode.
// bootmain() loads an ELF kernel image from the disk starting at
// sector 1 and then jumps to the kernel entry routine.

#include "types.h"
#include "elf.h"
#include "x86.h"
#include "memlayout.h"

#define SECTSIZE  512

void readseg(uchar*, uint, uint);

// 这段代码是一个用于加载和启动 ELF 格式的可执行文件的引导程序，通常出现在操作系统的引导加载器中。它从磁盘上读取 ELF 文件的内容，检查文件格式，然后加载程序的各个段，并最终跳转到 ELF 文件中指定的入口点执行程序。下面是对这段代码的详细解读：
// 1.	从磁盘读取 ELF 文件头。
// 2.	检查 ELF 文件的格式是否正确（通过验证魔数）。
// 3.	遍历并加载 ELF 文件中的每个程序段。
// 4.	如果某些程序段的内存大小大于文件大小，填充内存剩余部分为零。
// 5.	最后，跳转到 ELF 文件中指定的入口点，开始执行该程序。
void
bootmain(void)
{
  // elf 是一个指向 elfhdr 结构的指针。elfhdr 结构通常是 ELF 文件头，它包含了有关 ELF 文件的基本信息，如魔数（magic）、程序头表的偏移量（phoff）、入口点（entry）等。
  struct elfhdr *elf;
  struct proghdr *ph, *eph;
  // entry 是一个函数指针，用来保存 ELF 文件中指定的入口点地址（通常是程序的起始位置）。
  void (*entry)(void);
  uchar* pa;

  elf = (struct elfhdr*)0x10000;  // scratch space

  // Read 1st page off disk
  readseg((uchar*)elf, 4096, 0);

  // Is this an ELF executable?
  if(elf->magic != ELF_MAGIC)
    return;  // let bootasm.S handle error

  // Load each program segment (ignores ph flags).
  // ph 是指向 ELF 文件中的程序头表的指针。elf->phoff 是程序头表的偏移量，表示程序头表在 ELF 文件中的位置。
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
  //eph 是指向程序头表最后一个程序头的指针。elf->phnum 是程序头的数量，因此 eph = ph + elf->phnum 会指向程序头表的末尾。
  eph = ph + elf->phnum;
  for(; ph < eph; ph++){
    // pa 指向当前程序头的 paddr 字段，这个字段表示该段在内存中的起始地址。
    pa = (uchar*)ph->paddr;
    // 这条指令将从磁盘读取该段数据并加载到内存的 pa 地址。
    readseg(pa, ph->filesz, ph->off);
    // 这部分代码处理程序段的 内存大小 大于 文件大小 的情况：如果段的内存大小（memsz）大于文件大小（filesz），则会将段的剩余部分填充为零。stosb 是一个函数，用于将指定内存位置的字节值填充为零。
    if(ph->memsz > ph->filesz)
      stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
  }

  // Call the entry point from the ELF header.
  // Does not return!
  // elf->entry 是 ELF 文件头中的入口点地址，它指示程序从哪里开始执行。
  entry = (void(*)(void))(elf->entry);
  // 通过调用 entry()，程序控制权跳转到 ELF 文件中指定的入口点，开始执行加载的程序。
  entry();
}

// waitdisk 函数的作用是 等待硬盘准备好，以便进行后续的读写操作。它通过检查硬盘控制器的状态寄存器，确保硬盘的准备状态符合预期（高 2 位为 0x40）。如果硬盘尚未准备好，程序会一直在空循环中等待，直到硬盘准备好为止。
// 1.	inb(0x1F7) 从硬盘的控制器读取一个字节，获取硬盘的状态。
// 2.	& 0xC0 操作提取状态字节的高 2 位，这 2 位通常用于表示硬盘是否准备好进行读写。
// 3.	!= 0x40 检查这两位是否为 0x40，即硬盘是否准备好。
// 4.	如果硬盘还没有准备好，程序会进入一个 空循环，一直检查硬盘状态。
// 5.	一旦硬盘准备好（即状态字节的高 2 位为 0x40），循环结束，函数退出，程序可以继续进行后续的磁盘操作。
void
waitdisk(void)
{
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
    ;
}

// readsect 函数的作用是从硬盘读取一个扇区的数据并将其存储到指定的内存位置。它通过设置硬盘控制器的端口来启动读取操作，并通过 insl 指令将硬盘数据读取到内存中。整个过程涉及两次等待硬盘准备好（waitdisk），并且使用硬盘控制器的特定命令和端口进行数据传输。
// 1.	等待硬盘准备好：调用 waitdisk()，确保硬盘控制器准备好进行数据操作。
// 2.	设置读取命令：
// •	设置要读取的扇区数为 1。
// •	将扇区偏移量分解成 4 个字节并写入控制端口。
// •	发送 0x20 命令，指示硬盘开始读取扇区数据。
// 3.	等待硬盘完成操作：再次调用 waitdisk()，确保硬盘准备好输出数据。
// 4.	读取数据：使用 insl 从硬盘的数据端口 0x1F0 读取数据并存储到目标内存地址 dst。
// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
  // Issue command.
  waitdisk();
  outb(0x1F2, 1);   // count = 1

  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
  outb(0x1F5, offset >> 16);
  outb(0x1F6, (offset >> 24) | 0xE0);

  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
  insl(0x1F0, dst, SECTSIZE/4);
}
```

![](/static/images/2501/p002.png)

尽管 x86 体系支持 16 位 I/O 地址（理论上有16^4=2^16=65536个），但实际CPU实际没有这么多的引脚，是通过如下一些技术解决的：

- 总线共享：CPU 使用少量引脚（如 16~32 根地址线）通过总线传输地址，而非每个端口有独立引脚。
- 地址解码器：I/O 地址范围分配给不同设备，由地址解码器选择性激活某个设备。
- 扩展机制：借助控制器和桥接芯片（如 PCI、USB 控制器）进一步扩展设备数量。
- 多路复用：数据总线和地址总线可复用同一组引脚，通过时钟和控制信号区分功能。
  - 在 PC 电脑（x86 架构） 中，地址总线和数据总线是独立的，各自有专用的物理硬件。

```
// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
  uchar* epa;

  epa = pa + count;

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;

  // Translate from bytes to sectors; kernel starts at sector 1.
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    readsect(pa, offset);
}
```