### 生成证书

步骤如图所示：

![](/static/images/2202/p001.png)

```bash
# step1
openssl genrsa -out ca.key 2048
# step2
openssl req -x509 -new -nodes -key ca.key -subj "/CN=zhyoulun.com" -days 5000 -out ca.crt
# step3
openssl genrsa -out server.key 2048
# step4
openssl req -new -key server.key -subj "/CN=localhost" -out server.csr
# step5
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 5000 -out server.crt
```

### 启动HTTPS服务端

这里会使用`server.crt`和`server.key`文件

```go
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"net/url"
)

func main() {
	err := http.ListenAndServeTLS(":8443", "server.crt", "server.key", customHandler{})
	//err := http.ListenAndServe(":8080", customHandler{})
	log.Fatal(err)
}

type customHandler struct {
}

func (ch customHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s, _ := json.MarshalIndent(struct {
		Host             string
		Method           string
		Proto            string
		ContentLength    int64
		TransferEncoding []string
		Close            bool
		RemoteAddr       string
		RequestURI       string
		URL              *url.URL
		Header           http.Header
	}{
		Host:             r.Host,
		Method:           r.Method,
		Proto:            r.Proto,
		ContentLength:    r.ContentLength,
		TransferEncoding: r.TransferEncoding,
		Close:            r.Close,
		RemoteAddr:       r.RemoteAddr,
		RequestURI:       r.RequestURI,
		URL:              r.URL,
		Header:           r.Header,
	}, "", "  ")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(s)
}
```

启动

```bash
$ go run server.go
```

### 使用curl测试

**错误的测试**

```bash
$ curl https://localhost:8443/
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

**正确的测试**

需要使用到`--cacert`参数

```bash
$ curl --cacert ca.crt https://localhost:8443/
{
  "Host": "localhost:8443",
  "Method": "GET",
  "Proto": "HTTP/2.0",
  "ContentLength": 0,
  "TransferEncoding": null,
  "Close": false,
  "RemoteAddr": "127.0.0.1:52185",
  "RequestURI": "/",
  "URL": {
    "Scheme": "",
    "Opaque": "",
    "User": null,
    "Host": "",
    "Path": "/",
    "RawPath": "",
    "ForceQuery": false,
    "RawQuery": "",
    "Fragment": "",
    "RawFragment": ""
  },
  "Header": {
    "Accept": [
      "*/*"
    ],
    "User-Agent": [
      "curl/7.77.0"
    ]
  }
}
```

### 使用go实现一个client，支持读取ca.crt

注意：
- 这里的程序基于golang1.14版本可以正常运行
  - 原因参考：https://go.dev/doc/go1.15#commonname
- 如果希望基于1.15及以上版本运行，需要增加环境变量`GODEBUG=x509ignoreCN=0`
  - 如何解决这个问题？需要支持SAN扩展，这里不展开，可以参考[使用 OpenSSL 制作一个包含 SAN（Subject Alternative Name）的证书](https://liaoph.com/openssl-san/)

```go
package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	caCrt, err := ioutil.ReadFile("ca.crt")
	if err != nil {
		log.Fatal(err)
	}

	pool := x509.NewCertPool()
	pool.AppendCertsFromPEM(caCrt)

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				RootCAs: pool,
			},
		},
	}

	resp, err := client.Get("https://localhost:8443/")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(body))
}
```

运行

```bash
$ GODEBUG=x509ignoreCN=0 go run client.go
{
  "Host": "localhost:8443",
  "Method": "GET",
  "Proto": "HTTP/1.1",
  "ContentLength": 0,
  "TransferEncoding": null,
  "Close": false,
  "RemoteAddr": "[::1]:53295",
  "RequestURI": "/",
  "URL": {
    "Scheme": "",
    "Opaque": "",
    "User": null,
    "Host": "",
    "Path": "/",
    "RawPath": "",
    "ForceQuery": false,
    "RawQuery": "",
    "Fragment": "",
    "RawFragment": ""
  },
  "Header": {
    "Accept-Encoding": [
      "gzip"
    ],
    "User-Agent": [
      "Go-http-client/1.1"
    ]
  }
}
```

## 参考

- [使用 OpenSSL 制作一个包含 SAN（Subject Alternative Name）的证书](https://liaoph.com/openssl-san/)
