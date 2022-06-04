基于net/http/httputil/ReverseProxy实现

```go
package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
)

func main() {
	// New functionality written in Go
	http.HandleFunc("/new", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "New function")
	})

	// Anything we don't do in Go, we pass to the old platform
	u, _ := url.Parse("http://127.0.0.1:12345/aaaa")
	http.Handle("/", httputil.NewSingleHostReverseProxy(u))

	// Start the server
	http.ListenAndServe(":8080", nil)
}
```

测试

```bash
➜  ~ curl -i "http://127.0.0.1:8080/bbbb"
HTTP/1.1 200 OK
Content-Length: 637
Content-Type: text/plain; charset=utf-8
Date: Sun, 29 May 2022 06:56:03 GMT

{
  "Host": "127.0.0.1:8080",
  "Method": "GET",
  "Proto": "HTTP/1.1",
  "ContentLength": 0,
  "TransferEncoding": null,
  "Close": false,
  "LocalAddr": "",
  "RemoteAddr": "127.0.0.1:55009",
  "RequestURI": "/aaaa/bbbb",
  "URL": {
    "Scheme": "",
    "Opaque": "",
    "User": null,
    "Host": "",
    "Path": "/aaaa/bbbb",
    "RawPath": "",
    "ForceQuery": false,
    "RawQuery": "",
    "Fragment": "",
    "RawFragment": ""
  }
}
```

参考

- [Example of a reverse proxy written in Go](https://gist.github.com/rolaveric/9167845)
