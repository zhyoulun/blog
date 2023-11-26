**使用socks5代理**

```bash
curl --socks5 127.0.0.1:1080 http://www.example.com
```

注意不能是`-socks5`

**使用http代理**

```bash
curl --proxy 128.0.0.1:8123 http://www.example.com
```

**固定https解析**

```bash
curl https://www.example.com --resolve 'www.example.com:443:192.0.2.17'
curl https://www.example.com:8443 --resolve 'www.example.com:8443:192.0.2.17'
```

## 参考

- [Curl测试socks5 or http 代理命令](https://www.cnblogs.com/zafu/p/9951200.html)
- [How to test a HTTPS URL with a given IP address](https://serverfault.com/questions/443949/how-to-test-a-https-url-with-a-given-ip-address)
