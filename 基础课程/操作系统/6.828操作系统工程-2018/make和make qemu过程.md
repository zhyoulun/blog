## make

```
zyl@debian:~/codes/zhyoulun/6.828-xv6-2018$ make V=1
echo "   -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL" | cmp -s obj/.vars.KERN_CFLAGS || echo "   -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL" > obj/.vars.KERN_CFLAGS
+ as kern/entry.S
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/entry.o kern/entry.S
+ cc kern/entrypgdir.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/entrypgdir.o kern/entrypgdir.c
echo "" | cmp -s obj/.vars.INIT_CFLAGS || echo "" > obj/.vars.INIT_CFLAGS
+ cc kern/init.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL  -c -o obj/kern/init.o kern/init.c
+ cc kern/console.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/console.o kern/console.c
+ cc kern/monitor.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/monitor.o kern/monitor.c
+ cc kern/printf.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/printf.o kern/printf.c
+ cc kern/kdebug.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/kdebug.o kern/kdebug.c
+ cc lib/printfmt.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/printfmt.o lib/printfmt.c
+ cc lib/readline.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/readline.o lib/readline.c
+ cc lib/string.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/string.o lib/string.c
echo "-m elf_i386 -T kern/kernel.ld -nostdlib" | cmp -s obj/.vars.KERN_LDFLAGS || echo "-m elf_i386 -T kern/kernel.ld -nostdlib" > obj/.vars.KERN_LDFLAGS
+ ld obj/kern/kernel
# 
ld -o obj/kern/kernel -m elf_i386 -T kern/kernel.ld -nostdlib obj/kern/entry.o obj/kern/entrypgdir.o obj/kern/init.o obj/kern/console.o obj/kern/monitor.o obj/kern/printf.o obj/kern/kdebug.o  obj/kern/printfmt.o  obj/kern/readline.o  obj/kern/string.o /usr/lib/gcc/i686-linux-gnu/12/libgcc.a -b binary
ld: warning: obj/kern/entry.o: missing .note.GNU-stack section implies executable stack
ld: NOTE: This behaviour is deprecated and will be removed in a future version of the linker
ld: warning: section `.bss' type changed to PROGBITS
ld: warning: obj/kern/kernel has a LOAD segment with RWX permissions
objdump -S obj/kern/kernel > obj/kern/kernel.asm
nm -n obj/kern/kernel > obj/kern/kernel.sym
+ as boot/boot.S
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/boot/boot.o boot/boot.S
+ cc -Os boot/main.c
gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -Os -c -o obj/boot/main.o boot/main.c
+ ld boot/boot
# 这条命令使用 GNU ld 链接器链接 32 位的 ELF 文件，生成一个启动程序。以下是命令中各个部分的详细解析
# 指定输出文件路径为 obj/boot/boot.out。这是链接生成的 ELF 格式可执行文件。
ld -m elf_i386 -N -e start -Ttext 0x7C00 -o obj/boot/boot.out obj/boot/boot.o obj/boot/main.o
ld: warning: obj/boot/boot.o: missing .note.GNU-stack section implies executable stack
ld: NOTE: This behaviour is deprecated and will be removed in a future version of the linker
ld: warning: obj/boot/boot.out has a LOAD segment with RWX permissions
objdump -S obj/boot/boot.out >obj/boot/boot.asm
objcopy -S -O binary -j .text obj/boot/boot.out obj/boot/boot
perl boot/sign.pl obj/boot/boot
boot block is 396 bytes (max 510)
+ mk obj/kern/kernel.img

# 作用：
# 创建一个大小为 10000 个块的空白文件 obj/kern/kernel.img~。
# 每个块默认大小为 512 字节（dd 的默认块大小）。
# 效果：
# 生成一个约 5MB (10000 × 512 = 5,120,000 字节) 的文件，填充全是零。
dd if=/dev/zero of=obj/kern/kernel.img~ count=10000 2>/dev/null
# 将引导程序 obj/boot/boot 的内容写入到 obj/kern/kernel.img~ 的开头。
# 引导程序位于镜像文件的第一个扇区（MBR）
dd if=obj/boot/boot of=obj/kern/kernel.img~ conv=notrunc 2>/dev/null
# 将内核文件 obj/kern/kernel 写入到镜像文件的第一个扇区之后（即从第 1KB 开始）。
# 内核 ELF 文件被嵌入到镜像文件中，引导程序可根据预定偏移找到它。
dd if=obj/kern/kernel of=obj/kern/kernel.img~ seek=1 conv=notrunc 2>/dev/null
# 将生成的临时文件 obj/kern/kernel.img~ 重命名为最终的 obj/kern/kernel.img。
mv obj/kern/kernel.img~ obj/kern/kernel.img
```



## make qemu

唯一涉及的文件是obj/kern/kernel.img

```
zyl@debian:~/codes/zhyoulun/6.828-xv6-2018$ make qemu
qemu-system-i386 -drive file=obj/kern/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -gdb tcp::26000 -D qemu.log
VNC server running on `::1:5900'
6828 decimal is XXX octal!
entering test_backtrace 5
entering test_backtrace 4
entering test_backtrace 3
entering test_backtrace 2
entering test_backtrace 1
entering test_backtrace 0
leaving test_backtrace 0
leaving test_backtrace 1
leaving test_backtrace 2
leaving test_backtrace 3
leaving test_backtrace 4
leaving test_backtrace 5
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
K> help
help - Display this list of commands
kerninfo - Display information about the kernel
K> kerninfo
Special kernel symbols:
  _start                  0010000c (phys)
  entry  f010000c (virt)  0010000c (phys)
  etext  f0101a1f (virt)  00101a1f (phys)
  edata  f010e060 (virt)  0010e060 (phys)
  end    f010e6c0 (virt)  0010e6c0 (phys)
Kernel executable memory footprint: 58KB
```