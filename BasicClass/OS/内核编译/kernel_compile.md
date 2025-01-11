## 直接编译遇到的问题

### 问题1

```
cc1: error: code model kernel does not support PIC mode
```

修改Makefile中的内容，增加`-fno-pie`到`KBUILD_CFLAGS`

```
KBUILD_CFLAGS   := -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs \
                   -fno-strict-aliasing -fno-common \
                   -Werror-implicit-function-declaration \
                   -Wno-format-security \
                   -fno-delete-null-pointer-checks -fno-pie
```

### 问题2

```
include/linux/compiler-gcc.h:90:1: fatal error: linux/compiler-gcc9.h: No such file or directory
```

```
# ls -l include/linux/compiler-gcc*
-rw-r--r-- 1 root root  631 Feb 26 07:59 include/linux/compiler-gcc3.h
-rw-r--r-- 1 root root 2048 Feb 26 07:59 include/linux/compiler-gcc4.h
-rw-r--r-- 1 root root 3642 Feb 26 07:59 include/linux/compiler-gcc.h
```

需要使用gcc4

所以还是在docker中编译

```
docker pull gcc:4.9
```

```
docker run -it --rm -v /Volumes/linux/linux:/usr/src/linux gcc:4.9 /bin/bash
```

## 参考

- [fatal error: linux/compiler-gcc7.h: No such file or directory](https://askubuntu.com/questions/1157084/fatal-error-linux-compiler-gcc7-h-no-such-file-or-directory)