
## 测试

1. 启动udp_server.go

```bash
go run udp_server.go
```

2. 启动mpserver

```bash
./mpserver 2000 127.0.0.1 12345
```

3. 启动mpclient

```bash
./mpclient mpclient.conf
```

其中配置文件内容是

```
cat mpclient.conf
x.x.x.x 3002
```

4. 测试

```
nc -u 127.0.0.1 3210
abc
```

## 测试的日志

nc

```
nc -u 127.0.0.1 3210
abc
```

mpclient

```
[2022-02-27 04:10:43.484](client.c:88) Configuration: Encryption enabled
[2022-02-27 04:10:43.484](client.c:97) Port listening started
[2022-02-27 04:10:43.485](client.c:378) Get remote server address 1.15.24.181:3002 from configura file
[2022-02-27 04:10:43.485](client.c:319) Connect to 1.15.24.181:3002
[2022-02-27 04:10:43.485](client.c:327) Connected to remote host 1.15.24.181:3002, fd is 5
[2022-02-27 04:10:43.485](client.c:441) Initializing libev thread
[2022-02-27 04:10:43.485](client.c:55) Starting libev thread

[2022-02-27 04:11:10.145](client.c:453) Received data from client(:37382), fd=3
[2022-02-27 04:11:10.145](mptunnel.c:70) Sent 20 bytes to 5, message id is 1
[2022-02-27 04:11:10.145](client.c:515) Packet sent to 1.15.24.181:3002(5) of 20 bytes.
```

mpserver

```
[2022-02-27 12:10:40.972](server.c:390) Configuration: Encryption enabled
[2022-02-27 12:10:40.973](server.c:391) Configuration: Local listening port: 2000
[2022-02-27 12:10:40.973](server.c:392) Configuration: server：127.0.0.1:12345
[2022-02-27 12:10:40.973](server.c:397) Initializing libev thread
[2022-02-27 12:10:40.973](server.c:306) Thread which forward packet from server to bridge is started
[2022-02-27 12:10:40.973](server.c:193) libev thread started

[2022-02-27 12:11:10.256](server.c:111) Got a new client, add it to Client List
[2022-02-27 12:11:10.256](server.c:157) Received packet from bridge (:0) of 20 bytes, ID is 1, forward it
[2022-02-27 12:11:10.256](mptunnel.c:150) Pakcet #1 is not exists in Received Packet List
[2022-02-27 12:11:10.256](mptunnel.c:254) Cleanup timed out packets, TTL=30, last cleanup time is 0, current time is 1645935070, elapsed time is 1645935070 seconds
[2022-02-27 12:11:10.256](mptunnel.c:299) Finish cleanup timed out packets, TTL = 30, smallest continuous received packet ID is 1
```

udp_server

```
2022/02/27 12:10:36 start handle client, 127.0.0.1:12345

2022/02/27 12:11:10 read data: abc
, length: 4, remote info: 127.0.0.1:33824
2022/02/27 12:11:10 end handle client, 127.0.0.1:12345
2022/02/27 12:11:10 start handle client, 127.0.0.1:12345
```

## 代码

udp_server.go

```go
package main

import (
	"fmt"
	"log"
	"net"
)

func main() {
	addr := "127.0.0.1:12345"
	laddr, err := net.ResolveUDPAddr("udp", addr)
	if err != nil {
		log.Fatalf("net ResolveUDPAddr fail, err=%+v\n", err)
	}
	conn, err := net.ListenUDP("udp", laddr)
	if err != nil {
		log.Fatalf("net ListenUDP fail, err=%+v\n", err)
	}
	defer conn.Close()

	for {
		handleClient(conn)
	}
}

func handleClient(conn *net.UDPConn) {
	info := conn.LocalAddr().String()
	log.Printf("start handle client, %s\n", info)
	defer log.Printf("end handle client, %s\n", info)

	buf := make([]byte, 1024)
	n, remoteAddr, err := conn.ReadFromUDP(buf)
	if err != nil {
		fmt.Printf("conn ReadFromUDP fail, err=%+v\n", err)
		return
	}
	log.Printf("read data: %s, length: %d, remote info: %s\n", string(buf), n, remoteAddr.String())
}
```

