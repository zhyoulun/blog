gdb常用命令：

- `b *0x7c00`：在内存0x7c00处设置断点
- `c`：continue，继续运行
- `si`：但不执行
- `i r`：查看当前寄存器的值
- `set disassembly-flavor intel`：切换成intel风格
- `x/4i $pc`：查看当前的反汇编代码


## 参考

- [Qemu与GDB调试内核](http://blog.chiyiw.com/2017/04/28/Qemu%E4%B8%8EGDB%E8%B0%83%E8%AF%95%E5%86%85%E6%A0%B8.html)
- [用 gdb 和 qemu 调试 grub](https://www.cnblogs.com/linuxheik/articles/11398208.html)
