### 信息

- 抓包文件：[p004.pcapng](/static/pcapng/2202/p004.pcapng)
  - 一共4个包：请求包，请求ack包，响应包，响应ack包
  - 没有握手挥手流程

### 测试与分析

问题备忘：

- 请求时必须设置`Connection:close`，否则会有keepalive机制导致无法关闭kcp session，衍生的问题是服务端无法收到客户端的ack包，导致服务端一直重发响应数据包（是同一个原因吗？）

**运行服务端**

```bash
go run server.go
# 无任何输出
```

**运行客户端**

```bash
go run client.go
{
  "Host": "127.0.0.1:8080",
  "Method": "GET",
  "Proto": "HTTP/1.1",
  "ContentLength": 0,
  "TransferEncoding": null,
  "Close": true,
  "RemoteAddr": "127.0.0.1:65064",
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
    "Connection": [
      "close"
    ],
    "User-Agent": [
      "Go-http-client/1.1"
    ]
  }
}
```


### 服务端

```go
package main

import (
	"encoding/json"
	"github.com/xtaci/kcp-go"
	"log"
	"net/http"
	"net/url"
)

func main() {
	ln, err := kcp.Listen("127.0.0.1:8080")
	//ln, err := net.Listen("tcp4", ":8080")
	if err != nil {
		log.Fatal(err)
	}

	s := &http.Server{
		Handler: customHandler{},
		//ReadTimeout:  time.Second,
		//WriteTimeout: time.Second,
		//IdleTimeout: 60 * time.Second,
	}
	err = s.Serve(ln)
	//err = http.Serve(ln, customHandler{})
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

### 客户端

```go
package main

import (
	"context"
	"fmt"
	"github.com/xtaci/kcp-go"
	"io/ioutil"
	"log"
	"net"
	"net/http"
)

func main() {
	client := &http.Client{
		Transport: &http.Transport{
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				//d := net.Dialer{
				//	Timeout: time.Second,
				//}
				//return d.DialContext(ctx, network, addr)
				return kcp.Dial("127.0.0.1:8080")
			},
			DisableKeepAlives: true, //对于kcp，连接不能复用，否则无法触发客户端发送最后一个ack
		},
	}

	req, err := http.NewRequest(http.MethodGet, "http://127.0.0.1:8080/", nil)
	if err != nil {
		log.Fatal(err)
	}

	//resp, err := http.Get("http://127.0.0.1:8080/")
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}

	defer resp.Body.Close()
	s, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(s))
}
```
