**查看key信息**

```bash
openssl rsa -noout -text -in server.key
```

**查看csr信息**

```bash
openssl req -noout -text -in server.csr
```

**查看crt信息**

```bash
openssl x509 -noout -text -in ca.crt
```

**验证证书**

```bash
openssl verify -CAfile ca.crt server.crt
```

## 参考

- [openssl 查看证书](https://www.jianshu.com/p/f5f93c89155e)
