### 生成证书

步骤如图所示：

![](/static/images/2202/p002.png)

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

# step6
openssl genrsa -out client.key 2048
# step7
openssl req -new -key client.key -subj "/CN=custom_client_common_name" -out client.csr
$ step8
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 5000 -out client.crt
```

### 启动服务端程序

```go
package main

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
)

func main() {
	caCrt, err := ioutil.ReadFile("ca.crt")
	if err != nil {
		log.Fatal(err)
	}

	pool := x509.NewCertPool()
	pool.AppendCertsFromPEM(caCrt)

	s := &http.Server{
		Addr:    ":8443",
		Handler: customHandler{},
		TLSConfig: &tls.Config{
			ClientCAs:  pool,
			ClientAuth: tls.RequireAndVerifyClientCert, //实现Server强制校验client端证书
		},
	}

	//err := http.ListenAndServeTLS(":8443", "server.crt", "server.key", customHandler{})
	err = s.ListenAndServeTLS("server.crt", "server.key")
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

### 使用curl客户端测试

正确的测试

```bash
$ curl --cacert ca.crt --cert client.crt --key client.key https://localhost:8443/
```

错误的测试

```bash
# 也能拿到结果，忽略了对服务端证书的校验
$ curl -k --cert client.crt --key client.key https://localhost:8443/
# 无法拿到结果
$ curl --cert client.crt --key client.key https://localhost:8443/
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```


### 基于golang实现客户端

在golang1.14版本运行正常

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
	clientCrt, err := tls.LoadX509KeyPair("client.crt", "client.key")
	if err != nil {
		log.Fatal(err)
	}

	caCrt, err := ioutil.ReadFile("ca.crt")
	if err != nil {
		log.Fatal(err)
	}

	pool := x509.NewCertPool()
	pool.AppendCertsFromPEM(caCrt)

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				RootCAs:      pool,
				Certificates: []tls.Certificate{clientCrt},
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

## 参考

- [HTTPS双向认证（Mutual TLS authentication)](https://help.aliyun.com/document_detail/160093.html)
