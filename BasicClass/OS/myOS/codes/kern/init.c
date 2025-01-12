/* See COPYRIGHT for copyright information. */

#include <kern/inc/stdio.h>
#include <kern/inc/string.h>

#include <kern/inc/monitor.h>
#include <kern/inc/console.h>

// 入口函数
void
i386_init(void)
{
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();

	cprintf("6828 decimal is %o octal!\n", 6828);

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
}
