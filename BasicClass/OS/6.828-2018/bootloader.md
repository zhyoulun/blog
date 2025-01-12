bootloader一般情况下用于加载操作系统。


When an x86 PC boots, it starts executing a program called the BIOS (Basic Input/ Output System), which is stored in non-volatile memory on the motherboard. The BIOS’s job is to prepare the hardware and then transfer control to the operating system. Specifically, it transfers control to code loaded from the boot sector, the first 512-byte sector of the boot disk. The boot sector contains the boot loader: instructions that load the kernel into memory. The BIOS loads the boot sector at memory address 0x7c00 and then jumps (sets the processor’s %ip) to that address. When the boot loader begins executing, the processor is simulating an Intel 8088, and the loader’s job is to put the processor in a more modern operating mode, to load the xv6 kernel from disk into memory, and then to transfer control to the kernel. The xv6 boot loader comprises two source files, one written in a combination of 16-bit and 32-bit x86 assembly (bootasm.S; (9100)) and one written in C (bootmain.c; (9200)).

当一台 x86 PC 启动时，它开始执行一个名为 **BIOS**（基本输入/输出系统）的程序，该程序存储在主板的非易失性存储器中。BIOS 的任务是初始化硬件，然后将控制权交给操作系统。具体来说，它将控制权交给从**启动扇区**加载的代码。启动扇区是启动磁盘的第一个 **512 字节** 的扇区，包含启动加载器：一组将内核加载到内存的指令。

**BIOS** 将启动扇区加载到内存地址 `0x7c00`，然后跳转到该地址（设置处理器的 `%ip`）。当启动加载器开始执行时，处理器模拟的是一台 **Intel 8088**，而加载器的任务是：
1. 将处理器切换到更现代的操作模式；
2. 将 **xv6 内核** 从磁盘加载到内存中；
3. 将控制权转移给内核。

**xv6** 的启动加载器由两个源文件组成：
- 一个是由 16 位和 32 位 x86 汇编语言编写的（`bootasm.S`）。
- 另一个是用 C 语言编写的（`bootmain.c`）。