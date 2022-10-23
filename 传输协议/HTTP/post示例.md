### form-data

可以看出，form-data是body的一部分

```
POST / HTTP/1.1
Host: www.baidu.com
Content-Length: 210
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW

----WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="aaa"

111
----WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="bbb"

222
----WebKitFormBoundary7MA4YWxkTrZu0gW
```

![](/static/images/2210/p001.png)

### x-www-form-urlencoded

```
POST / HTTP/1.1
Host: www.baidu.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 15

aaa=111&bbb=222
```

![](/static/images/2210/p002.png)

### raw

```
POST / HTTP/1.1
Host: www.baidu.com
Content-Type: text/plain
Content-Length: 3

aaa
```

![](/static/images/2210/p003.png)

