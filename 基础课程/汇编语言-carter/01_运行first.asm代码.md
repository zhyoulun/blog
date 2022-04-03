初始文件列表

```
asm_io.asm
asm_io.inc
cdecl.h
driver.c
first
first.asm
```

```bash
nasm -f elf -d ELF_TYPE asm_io.asm
```

输出`asm_io.o`

```bash
nasm -f elf first.asm
```

输出`first.o`

```bash
gcc first.o asm_io.o driver.c -o first
```

输出可执行文件`first`

运行

```
$ ./first
Enter a number: 1
Enter another number: 2
Register Dump # 1
EAX = 00000003 EBX = 00000003 ECX = BF846620 EDX = BF846644
ESI = B773A000 EDI = B773A000 EBP = BF8465E8 ESP = BF8465C8
EIP = 080484F7 FLAGS = 0206                PF
Memory Dump # 2 Address = 0804A050
0804A050 59 6F 75 20 65 6E 74 65 72 65 64 20 00 20 61 6E "You entered ? an"
0804A060 64 20 00 2C 20 74 68 65 20 73 75 6D 20 6F 66 20 "d ?, the sum of "
You entered 1 and 2, the sum of these is 3
```

### 可能遇到的问题

```
$ gcc first.o driver.c asm_io.o -o first
/tmp/ccsD09PE.o: In function `main':
driver.c:(.text+0x12): undefined reference to `asm_main'
collect2: error: ld returned 1 exit status
```

这是因为first.o中的函数是`_asm_main`，需要修改下driver.c中的调用的`asm_main`为`_asm_main`

之所以会遇到这个问题，是Linux和DOS/Windows的区别，后者不会有这个问题

```bash
$ nm first.o
00000000 T _asm_main #这里
00000000 b input1
00000004 b input2
00000028 d outmsg1
00000035 d outmsg2
0000003b d outmsg3
         U print_char
         U print_int
         U print_nl
         U print_string
00000000 d prompt1
00000011 d prompt2
         U read_char
         U read_int
         U sub_dump_math
         U sub_dump_mem
         U sub_dump_regs
         U sub_dump_stack
```
