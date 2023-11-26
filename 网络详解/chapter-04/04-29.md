**忽略yes输出要求**

```bash
ssh -o "StrictHostKeyChecking no" user@host
```


**启动一个端口为1080的socks5协议代理**

```bash
ssh -D 1080 user@ip
```



## 参考

- [How can I avoid SSH's host verification for known hosts?](https://superuser.com/questions/125324/how-can-i-avoid-sshs-host-verification-for-known-hosts)
