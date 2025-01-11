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

  # Zero data segment registers DS, ES, and SS.
  xorw    %ax,%ax             # Set %ax to zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment

  # Physical address line A20 is tied to zero so that the first PCs 
  # with 2 MB would run software that assumed 1 MB.  Undo that.
# not an instruction
seta20.1:
  # read a byte data from IO port $0x64, $0x64 stand for input port address/number. $0x64 usually stand for read data from keyboard.
  inb     $0x64,%al               # Wait for not busy
  # test the second bit in %al if not 1, if 1, will goto seta20.1, if not, will continue
  testb   $0x2,%al
  jnz     seta20.1

  movb    $0xd1,%al               # 0xd1 -> port 0x64
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf -> port 0x60
  outb    %al,$0x60

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

# 2. movl %cr0, %eax
# - movl 是一个数据传输指令，将 32 位数据从源操作数（右边）传送到目标操作数（左边）。
# - %cr0 是控制寄存器 0，它是控制 CPU 的关键寄存器之一，包含多个标志，用来控制处理器的模式和特性。
# - 这条指令将 %cr0 寄存器的内容复制到 %eax 寄存器中。

# 3. orl $CR0_PE, %eax
# - orl 是按位 “OR” 操作指令。它将立即数 $CR0_PE 与 %eax 寄存器的内容进行按位 “OR” 操作，并将结果存回 %eax。
# - CR0_PE 是控制寄存器 0（%cr0）中的一个标志位，表示是否启用保护模式（PE - Protection Enable）。CR0_PE 的值通常是 0x1。
# - 通过 orl 指令，代码的目的是将 CR0_PE 标志设置为 1，从而启用保护模式。

# 4. movl %eax, %cr0
# - 这条指令将 %eax 寄存器的内容存回 %cr0 寄存器。
# - 此时，%eax 寄存器中的值已经修改过，启用了 CR0_PE 标志（设置了保护模式标志），因此，执行此指令后，%cr0 寄存器会被更新为启用保护模式。

  lgdt    gdtdesc
  movl    %cr0, %eax     # ->
  orl     $CR0_PE, %eax
  movl    %eax, %cr0

//PAGEBREAK!
  # Complete the transition to 32-bit protected mode by using a long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
# 这条指令 ljmp $(SEG_KCODE<<3), $start32 是一个 长跳转（long jump） 指令，通常用于操作系统引导过程中或从实模式切换到保护模式后，跳转到新的代码段。它用于改变程序的控制流，并同时设置段选择器。
  ljmp    $(SEG_KCODE<<3), $start32


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