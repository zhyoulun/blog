### 信息

- 这是一个echo服务端与客户端
- 抓包文件：[p001.pcapng](/static/pcapng/2202/p001.pcapng)
  - 一共4个包：请求包，请求ack包，响应包，响应ack包
  - 没有握手挥手流程

### 测试与分析

- 问题备忘：
  - 服务端的session只能通过超时断开
    - 优化思路：抛开echo功能的约束，服务端发送指定长度内容之后主动断开
  - 客户端的session只能通过超时断开
    - 优化思路：客户端读到和发送一样长度的内容之后主动断开

**服务端日志**

```bash
go run server.go
2022/02/20 19:53:47 read :timeout
```

**客户端日志**

```bash
go run client.go
write: 2022-02-20 19:53:46.174776 +0800 CST m=+0.000829049
read : 2022-02-20 19:53:46.174776 +0800 CST m=+0.000829049
2022/02/20 19:53:47 read :timeout
```

### 服务端

```go
package main

import (
	"github.com/xtaci/kcp-go"
	"log"
	"net"
	"time"
)

func main() {
	ln, err := kcp.Listen("127.0.0.1:8080")
	if err != nil {
		log.Fatal(err)
	}

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal(err)
		}
		go handleConn(conn)
	}
}

func handleConn(conn net.Conn) {
	defer func() {
		err := conn.Close()
		if err != nil {
			log.Print("close:", err)
		}
	}()

	buf := make([]byte, 4096)

	for {
		_ = conn.SetReadDeadline(time.Now().Add(time.Second))
		nRead, err := conn.Read(buf)
		//if err == io.EOF {
		//	break
		//}
		if err != nil {
			log.Print("read :", err)
			return
		}

		nWrite := 0
		for nWrite < nRead {
			_ = conn.SetWriteDeadline(time.Now().Add(time.Second))
			n, err := conn.Write(buf[nWrite:nRead])
			if err != nil {
				log.Print("write:", err)
				return
			}
			nWrite += n
		}
	}
}
```


### 客户端

```go
package main

import (
	"fmt"
	"github.com/xtaci/kcp-go"
	"log"
	"time"
)

func main() {
	conn, err := kcp.Dial("127.0.0.1:8080")
	if err != nil {
		log.Fatal("dial :", err)
	}

	defer func() {
		err := conn.Close()
		if err != nil {
			log.Print("close:", err)
		}
	}()

	content := []byte(time.Now().String())
	nWrite := 0
	for nWrite < len(content) {
		_ = conn.SetReadDeadline(time.Now().Add(time.Second))
		n, err := conn.Write(content[nWrite:])
		if err != nil {
			//log.Fatal(err)
			log.Print("write:", err)
			break
		}
		nWrite += n
	}
	fmt.Println("write:", string(content))

	buf := make([]byte, 4096)
	nRead := 0
	for {
		_ = conn.SetReadDeadline(time.Now().Add(time.Second))
		n, err := conn.Read(buf[nRead:])
		//if err == io.EOF {
		//	break
		//}
		if err != nil {
			//log.Fatal(err)
			log.Print("read :", err)
			break
		}
		nRead += n

		fmt.Println("read :", string(buf[:nRead]))
	}
}
```
