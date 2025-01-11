https://pdos.csail.mit.edu/6.828/2018/tools.html

git clone https://github.com/mit-pdos/6.828-qemu.git

修改文件`6.828-qemu/qga/commands-posix.c`，在顶部添加以下代码：

```c
#include <sys/sysmacros.h>
```

```bash
./configure --disable-kvm --disable-werror --prefix=/home/zyl/software/qemu6828 --target-list="i386-softmmu x86_64-softmmu" --python=/home/zyl/software/python2/bin/python
make
make install
```