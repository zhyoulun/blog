```go
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"net/url"
)

func main() {
	err := http.ListenAndServe(":8080", customHandler{})
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

运行

```bash
$ go run server.go
```

测试

```bash
$ curl http://127.0.0.1:8080/a/b/c
{
  "Host": "127.0.0.1:8080",
  "Method": "GET",
  "Proto": "HTTP/1.1",
  "ContentLength": 0,
  "TransferEncoding": null,
  "Close": false,
  "RemoteAddr": "127.0.0.1:51066",
  "RequestURI": "/a/b/c",
  "URL": {
    "Scheme": "",
    "Opaque": "",
    "User": null,
    "Host": "",
    "Path": "/a/b/c",
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
