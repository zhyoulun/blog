```bash
netstat -a -p TCP -n -v
```

- `-a`：在netstat的输出中包含服务端口(server ports)
- `-p PROTOCOL`：列出与特定网络协议(protocol)关联的流量. 完整的协议(protocol)列表位于/etc/protocols，但是最重要的协议是udp和tcp
- `-n`：隐藏带有名称的远程地址标签，带来的好处是：大大加快了netstat的输出，同时只牺牲了有限的信息
- `-v`：增加详细程度，特别是通过添加一列来显示与每个打开的端口关联的进程ID(pid)

## 参考

- [netstat在mac上不好用了,试试lsof](https://segmentfault.com/a/1190000023905522)
- man netstat