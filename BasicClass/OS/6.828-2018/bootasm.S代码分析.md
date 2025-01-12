```s
#include "asm.h"
#include "memlayout.h"
#include "mmu.h"

# Start the first CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

# an instruction to use 16-bit mode
.code16                       # Assemble for 16-bit mode
.globl start
start:
  # disable outside hardware interrupts, short for Clear Interrupt Flag
  cli                         # BIOS enabled interrupts; disable
```

```s
  # Zero data segment registers DS, ES, and SS.
  xorw    %ax,%ax             # Set %ax to zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment
```

```s
  # Physical address line A20 is tied to zero so that the first PCs 
  # with 2 MB would run software that assumed 1 MB.  Undo that.
# not an instruction
seta20.1:
  # read a byte data from IO port $0x64, $0x64 stand for input port address/number. $0x64 usually stand for read data from keyboard.
  inb     $0x64,%al               # Wait for not busy
  # test the second bit in %al if not 1, if 1, will goto seta20.1, if not, will continue
  testb   $0x2,%al                # 0x2(0010)
  jnz     seta20.1

  movb    $0xd1,%al               # 0xd1(1101 0001) -> port 0x64
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al                # 0x2(0010)
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf(1101 1111) -> port 0x60
  outb    %al,$0x60
```

A virtual  segment:oﬀset  can yield a 21-bit physical address, but the Intel 8088 could only address 20 bits of memory, so it discarded the top bit:  0xffff0+0xffff = 0x10ffef, but virtual address 0xffff:0xffff on the 8088 referred to physical address 0x0ffef. Some early software relied on the hardware ignoring the 21st address bit, so when Intel introduced processors with more than 20 bits of physical address, IBM pro- vided a compatibility hack that is a requirement for PC-compatible hardware. If the second bit of the keyboard controller’s output port is low, the 21st physical address bit is always cleared; if high, the 21st bit acts normally. The boot loader must enable the 21st address bit using I/O to the keyboard controller on ports 0x64 and 0x60  (9120-
9136).

virtual segment：Ofset可以产生21位物理地址，但英特尔8088只能寻址20位内存，因此它丢弃了最高位：0xffff0+0xffff=0x10ffef，但8088上的虚拟地址0xffff：0xffff引用了物理地址0x0ffef。一些早期的软件依赖于忽略第21个地址位的硬件，因此当英特尔推出物理地址超过20位的处理器时，IBM提供了一个兼容性hack，这是PC兼容硬件的一个要求。如果键盘控制器输出端口的第2位为低电平，则始终清除第21个物理地址位；如果为高，则第21位正常工作。引导加载程序必须使用端口0x64和0x60（9120-9136).

```s
  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  # lgdt short for Load Global Descriptor Table Register

# 在操作系统引导（bootstrapping）过程中，Bootstrap GDT 的作用通常体现在以下几个方面：
# - 提供初始的内存访问权限：
# 操作系统刚启动时，CPU 处于实模式（Real Mode）或保护模式（Protected Mode）。在这些模式下，GDT 定义了代码段、数据段等内存区域，操作系统通过它们来安全地访问内存。
# - 从实模式切换到保护模式：
# 在 x86 架构中，操作系统在启动时通常会先从实模式切换到保护模式。GDT 允许操作系统在保护模式下使用分段机制来管理内存。在这时，Bootstrap GDT 的作用就是提供一个简单的、最基本的 GDT，用于操作系统完成从实模式到保护模式的过渡。
# - 初始化段描述符：
# 引导阶段的 GDT 通常只包含基本的段描述符（如代码段、数据段和空段）。这些段描述符用于配置系统的内存访问权限和大小，从而使操作系统能够以保护模式的方式运行。
# - 为操作系统内核创建内存模型：
# Bootstrap GDT 会为内核的运行和用户空间的划分提供基础。这些段描述符可以定义内核的代码段、数据段以及堆栈段等，保证内核能够访问到正确的内存区域。

# 1. lgdt gdtdesc
# - lgdt 是一个 x86 汇编指令，表示 “Load Global Descriptor Table Register”（加载全局描述符表寄存器）。
# - gdtdesc 是一个数据结构，通常是一个包含 GDT 描述符的地址。这个描述符包含了 GDT 的基地址和大小。
# - 该指令的作用是将 gdtdesc 地址中的基址和大小加载到 GDTR（Global Descriptor Table Register）寄存器中。这样，CPU 就会使用新加载的 GDT 来进行内存段的管理。
  lgdt    gdtdesc
```

```s
  movl    %cr0, %eax     # ->
  orl     $CR0_PE, %eax
  movl    %eax, %cr0
```

the boot loader enables protected mode by setting the 1 bit (CR0_PE) in register %cr0 (9142-9144).

```s
//PAGEBREAK!
  # Complete the transition to 32-bit protected mode by using a long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
# 这条指令 ljmp $(SEG_KCODE<<3), $start32 是一个 长跳转（long jump） 指令，通常用于操作系统引导过程中或从实模式切换到保护模式后，跳转到新的代码段。它用于改变程序的控制流，并同时设置段选择器。
  ljmp    $(SEG_KCODE<<3), $start32
```

Enabling protected mode does not immediately change how the processor translates logical to physical addresses; it is only when one loads a new value into a segment register that the processor reads the GDT and changes its internal segmentation settings. One cannot directly modify %cs, so instead the code executes an ljmp (far jump) instruction (9153), which allows a code segment selector to be speciﬁed. The jump continues execution at the next line (9156) but in doing so sets %cs to refer to the code descriptor entry in gdt. That descriptor describes a 32-bit code segment, so the processor switches into 32-bit mode. The boot loader has nursed the processor through an evolution from 8088 through 80286 to 80386.

启用保护模式不会立即改变处理器将逻辑地址转换为物理地址的方式；只有当将新值加载到分段寄存器中时，处理器才会读取GDT并改变其内部分段设置。无法直接修改%cs，因此代码执行ljmp（远跳）指令（9153），该指令允许指定代码段选择器。跳转在下一行(9156)继续执行，但这样做将%cs设置为引用gdt中的代码描述符条目。该描述符描述32位代码段，因此处理器切换到32位模式。引导加载程序通过从8088到80286再到80386的演变来照顾处理器。

```s
# an instruction to use 32-bit mode
.code32  # Tell assembler to generate 32-bit code now.
start32:

# movw 是一个 16 位的数据传送指令。它将源操作数（右边）传送到目标操作数（左边）。
# - $(SEG_KDATA<<3) 表示数据段选择器的值。SEG_KDATA 是一个常量，表示内核数据段的选择器。由于 x86 架构中段选择器的大小是 8 字节，所以通过左移 3 位 (<<3) 来将选择器转换成有效的值（等价于乘以 8）。因此，SEG_KDATA << 3 计算出的结果是内核数据段的选择器。
# - 该指令将内核数据段选择器（SEG_KDATA << 3）加载到 16 位寄存器 %ax 中。

  # Set up the protected-mode data segment registers
  movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %ss                # -> SS: Stack Segment
  movw    $0, %ax                 # Zero segments not ready for use
# 这是用来将段寄存器 FS 和 GS 清零，通常是为了避免它们指向未初始化的段，或者它们在操作系统的初始化过程中并不需要立即使用。
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
```

The boot loader’s ﬁrst action in 32-bit mode is to initialize the data segment reg- isters with  SEG_KDATA (9158-9161). Logical address now map directly to physical ad- dresses. The only step left before executing C code is to set up a stack in an unused region of memory. The memory from 0xa0000 to 0x100000 is typically littered with device memory regions, and the xv6 kernel expects to be placed at  0x100000. The boot loader itself is at 0x7c00 through 0x7e00 (512 bytes). Essentially any other sec- tion of memory would be a  ﬁne location for the stack. The boot loader chooses 0x7c00 (known in this  ﬁle as  $start) as the top of the stack; the stack will grow down from there, toward 0x0000, away from the boot loader.

在32位模式下，引导加载程序的第一个操作是用SEG_KDATA（9158-9161）初始化数据段寄存器。逻辑地址现在直接映射到物理地址。

在执行C代码之前剩下的唯一步骤是在内存的未使用区域中建立堆栈。

从0xa0000到0x100000的内存通常散落着设备内存区域，xv6内核期望将其放置在0x100000。

引导加载程序本身位于0x7c00到0x7e00（512字节）。

基本上，内存的任何其他部分都是堆栈的理想位置。引导加载程序选择0x7c00（在本文件中称为$start）作为堆栈的顶部；堆栈将从那里向下增长，朝向0x0000，远离引导加载程序。

```s
  # Set up the stack pointer and call into C.
# $start 表示一个 立即数，通常是一个内存地址，在这里是操作系统内核启动时的起始位置。
# call 是一个 调用子程序 的指令，它将当前指令的地址（返回地址）压入堆栈，然后跳转到目标地址执行指令。
  movl    $start, %esp
  call    bootmain

  # If bootmain returns (it shouldn't), trigger a Bochs
  # breakpoint if running under Bochs, then loop.
  movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00
  movw    %ax, %dx
  outw    %ax, %dx
  movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
  outw    %ax, %dx
# 这段代码通过标签 spin 和指令 jmp spin 实现了一个 无限循环，程序会不断跳转回 spin 标签，导致程序停留在该位置而不再继续执行后续代码。这个模式在操作系统的启动或错误处理中非常常见，通常用于程序暂停或等待外部事件。
# 要退出这种 无限循环，需要触发一种外部干预或使用某种控制结构来打破循环。例如硬件中断
spin:
  jmp     spin
```

Finally the boot loader calls the C function bootmain (9168).  Bootmain’s job is to load and run the kernel. It only returns if something has gone wrong. In that case, the code sends a few output words on port 0x8a00 (9170-9176). On real hardware, there is no device connected to that port, so this code does nothing. If the boot loader is running inside a PC simulator, port 0x8a00 is connected to the simulator itself and can transfer control back to the simulator. Simulator or not, the code then executes an inﬁnite loop  (9177-9178). A real boot loader might attempt to print an error message ﬁrst.

最后，引导加载程序调用C函数bootmain（9168）。Bootmain的工作是加载和运行内核。只有当出现问题时，它才会返回。

在这种情况下，代码在端口0x8a00（9170-9176）上发送一些输出字。

在真正的硬件上，没有设备连接到那个端口，所以这段代码什么也不做。

如果引导加载程序在PC模拟器内部运行，端口0x8a00连接到模拟器本身，可以将控制传递回模拟器。

无论是否是模拟器，代码都会执行无限循环（9177-9178）。真正的引导加载程序可能会尝试首先打印错误消息。

```s
# Bootstrap GDT
# 	.p2align 2 是一种汇编指令，用来 强制对齐 后续数据到 4 字节的边界。
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULLASM                             # null seg
  SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
  SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg

gdtdesc:
  .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1
  .long   gdt                             # address gdt
```

xv6 makes almost no use of segments; it uses the paging hardware instead, as Chapter 2 describes. The boot loader sets up the segment descriptor table gdt (9182- 9185)  so that all segments have a base address of zero and the maximum possible limit (four gigabytes). The table has a null entry, one entry for executable code, and one entry to data. The code segment descriptor has a ﬂag set that indicates that the code should run in 32-bit mode (0660). With this setup, when the boot loader enters protect- ed mode, logical addresses map one-to-one to physical addresses.

xv6几乎不使用段；它使用寻呼硬件，如第2章所述。引导加载程序设置段描述符表gdt（9182-9185），以便所有段的基址为零和最大可能限制（4GB）。该表有一个空条目、一个可执行代码条目和一个到数据的entry。代码段描述符有一个指示代码应在32位模式下运行的标志集(0660)。通过这种设置，当引导加载程序进入保护模式时，逻辑地址会一对一地映射到物理地址。