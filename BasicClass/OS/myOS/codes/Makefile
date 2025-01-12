build:
	rm -rf obj
	mkdir -p obj/boot obj/kern

	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/boot/boot.o boot/boot.S
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -Os -c -o obj/boot/main.o boot/main.c
	i386-elf-ld -m elf_i386 -N -e start -Ttext 0x7C00 -o obj/boot/boot.out obj/boot/boot.o obj/boot/main.o
	i386-elf-objcopy -S -O binary -j .text obj/boot/boot.out obj/boot/boot.data
	perl boot/sign.pl obj/boot/boot.data obj/boot/boot.mbr

	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/entry.o kern/entry.S
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/entrypgdir.o kern/entrypgdir.c
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL  -c -o obj/kern/init.o kern/init.c
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/console.o kern/inc/console.c
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/monitor.o kern/inc/monitor.c

	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/printf.o kern/inc/printf.c
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/printfmt.o kern/inc/printfmt.c
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/readline.o kern/inc/readline.c
	i386-elf-gcc -pipe -nostdinc    -O1 -fno-builtin -I. -MD -fno-omit-frame-pointer -std=gnu99 -static -Wall -Wno-format -Wno-unused -Werror -m32 -fno-tree-ch -fno-stack-protector -DJOS_KERNEL -c -o obj/kern/string.o kern/inc/string.c

	i386-elf-ld -o obj/kern/kernel.elf -m elf_i386 -T kern/kernel.ld -nostdlib obj/kern/entry.o obj/kern/entrypgdir.o obj/kern/init.o obj/kern/console.o obj/kern/monitor.o obj/kern/printf.o  obj/kern/printfmt.o  obj/kern/readline.o  obj/kern/string.o /opt/local/lib/gcc/i386-elf/12.4.0/libgcc.a -b binary

	dd if=/dev/zero of=obj/kern/kernel.img~ count=10000 2>/dev/null
	dd if=obj/boot/boot.mbr of=obj/kern/kernel.img~ conv=notrunc 2>/dev/null
	dd if=obj/kern/kernel.elf of=obj/kern/kernel.img~ seek=1 conv=notrunc 2>/dev/null
	mv obj/kern/kernel.img~ obj/kern/kernel.img

qemu:
	qemu-system-i386 -drive file=obj/kern/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -gdb tcp::25502 -D qemu.log

clean:
	rm -rf obj
