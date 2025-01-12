这段代码是一个简单的 GNU 链接脚本，定义了一个内核的链接规则。链接脚本控制了内核的地址空间布局，决定了各个段（.text、.data、.bss 等）的虚拟地址和加载地址。

```c
/* Simple linker script for the JOS kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

//OUTPUT_FORMAT：指定生成的输出文件的格式。这里是 elf32-i386，表示 32 位小端格式的 ELF 文件，适用于 x86 架构。
OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
//OUTPUT_ARCH：指定目标架构，这里是 i386。
OUTPUT_ARCH(i386)
//ENTRY：定义程序的入口点 _start，这是程序开始执行的地址。
ENTRY(_start)

//SECTIONS：这是链接脚本的核心部分，用于定义程序的段布局。
SECTIONS
{
	/* Link the kernel at this address: "." means the current address */
    // .：当前地址指针，初始值被设置为 0x80100000，表示内核的虚拟地址基址。
	. = 0x80100000;

	/* AT(...) gives the load address of this section, which tells
	   the boot loader where to load the kernel in physical memory */
    //AT(...)：定义段的加载地址（物理地址）。在启动过程中，内核会被加载到物理地址 0x100000，然后通过分页机制映射到虚拟地址 0xF0100000。
    //text 段
    //AT(0x100000)：text 段的加载地址是物理地址 0x100000。这告诉引导加载器（bootloader）将 .text 段加载到物理内存中的这个地址。
    //*(.text .stub .text.* .gnu.linkonce.t.*)：将所有与 .text 相关的段（代码段）和符号合并到 .text 段中。
	.text : AT(0x100000) {
		*(.text .stub .text.* .gnu.linkonce.t.*)
	}

    //PROVIDE：定义一个符号，这个符号的值是当前地址 .。
    //etext：标识代码段（.text）的结束地址，可以在程序中用作标识，例如确定代码段范围。
	PROVIDE(etext = .);	/* Define the 'etext' symbol to this value */

    //rodata 段：只读数据段，用于存储常量和只读变量。
    //*(.rodata .rodata.* .gnu.linkonce.r.*)：将所有与 .rodata 相关的段和符号合并到 .rodata 中。
	.rodata : {
		*(.rodata .rodata.* .gnu.linkonce.r.*)
	}

	/* Include debugging information in kernel memory */
    //调试信息段
    //.stab 和 .stabstr：这两个段用于存储调试符号和字符串，通常在调试版本的内核中使用。
    //BYTE(0)：强制分配空间给这些段，即使它们为空。
    //符号 __STAB_BEGIN__ 和 __STAB_END__：标识调试段的起始和结束地址，用于调试器解析内核的调试信息。
	.stab : {
		PROVIDE(__STAB_BEGIN__ = .);
		*(.stab);
		PROVIDE(__STAB_END__ = .);
		BYTE(0)		/* Force the linker to allocate space
				   for this section */
	}
	.stabstr : {
		PROVIDE(__STABSTR_BEGIN__ = .);
		*(.stabstr);
		PROVIDE(__STABSTR_END__ = .);
		BYTE(0)		/* Force the linker to allocate space
				   for this section */
	}

    //数据段和对齐
	/* Adjust the address for the data segment to the next page */
    //对齐：将地址对齐到 0x1000（4 KB 页大小）。确保数据段从页边界开始，这对分页内存管理非常重要。
	. = ALIGN(0x1000);

    //.data 段：包含初始化的全局和静态变量。
	/* The data segment */
	.data : {
		*(.data)
	}

    //.bss 段：包含未初始化的全局和静态变量。这些变量在运行时会被初始化为 0。
    //符号 edata 和 end：标识数据段的结束地址和内核的总结束地址，用于运行时管理内存。
	.bss : {
		PROVIDE(edata = .);
		*(.bss)
		PROVIDE(end = .);
		BYTE(0)
	}


    //丢弃段
    ///DISCARD/：定义被丢弃的段。
    //*(.eh_frame .note.GNU-stack)：这些段通常用于异常处理和栈保护，不需要包含在内核中，因此被丢弃。
	/DISCARD/ : {
		*(.eh_frame .note.GNU-stack)
	}
}
```


The kernel has been compiled and linked so that it expects to ﬁnd itself at virtual addresses starting at 0x80100000. Thus, function call instructions must mention desti- nation addresses that look like  0x801xxxxx; you can see examples in  kernel.asm. This address is conﬁgured in  kernel.ld (9311).   0x80100000 is a relatively high ad- dress, towards the end of the 32-bit address space; Chapter 2 explains the reasons for this choice. There may not be any physical memory at such a high address. Once the kernel starts executing, it will set up the paging hardware to map virtual addresses starting at  0x80100000 to physical addresses starting at  0x00100000; the kernel as- sumes that there is physical memory at this lower address. At this point in the boot process, however, paging is not enabled. Instead,  kernel.ld speciﬁes that the ELF paddr start at 0x00100000, which causes the boot loader to copy the kernel to the low physical addresses to which the paging hardware will eventually point.

内核已经编译和链接，以便它期望自己位于从 0x80100000 开始的虚拟地址。因此，函数调用指令必须使用看起来像 0x801xxxxx 的目标地址；你可以在 kernel.asm 中看到这些例子。这个地址在 kernel.ld 中进行了配置（9311）。0x80100000 是一个相对较高的地址，接近 32 位地址空间的末尾；第 2 章解释了这个选择的原因。此地址处可能没有物理内存。一旦内核开始执行，它将设置分页硬件，将从 0x80100000 开始的虚拟地址映射到从 0x00100000 开始的物理地址；内核假设在这个较低的地址处有物理内存。然而，在启动过程的这个阶段，分页尚未启用。相反，kernel.ld 指定 ELF 的物理地址从 0x00100000 开始，这导致启动加载器将内核复制到分页硬件最终指向的低物理地址。

![](/static/images/2501/p012.png)