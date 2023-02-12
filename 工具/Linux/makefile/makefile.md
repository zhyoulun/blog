https://seisman.github.io/how-to-write-makefile/index.html


- makefile来告诉make命令如何编译和链接这几个文件

我们的规则是：

- 如果这个工程没有编译过，那么我们的所有c文件都要编译并被链接。
- 如果这个工程的某几个c文件被修改，那么我们只编译被修改的c文件，并链接目标程序。
- 如果这个工程的头文件被改变了，那么我们需要编译引用了这几个头文件的c文件，并链接目标程序。

makefile的规则：prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。

```
target ... : prerequisites ...
    command
    ...
    ...
```

