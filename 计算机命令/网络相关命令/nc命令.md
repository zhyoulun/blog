检测端口是否开启

```
$ nc -v 192.168.56.108 22
Connection to 192.168.56.108 22 port [tcp/ssh] succeeded!
$ nc -v 192.168.56.108 80
nc: connect to 192.168.56.108 port 80 (tcp) failed: Connection refused
```