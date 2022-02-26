### 准备

- 安装go
- 安装compiler：`brew install protobuf`
- 安装go插件

```bash
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1
```

### 测试hello world代码

- 服务端：https://github.com/grpc/grpc-go/blob/v1.41.0/examples/helloworld/greeter_server/main.go
- 客户端：https://github.com/grpc/grpc-go/blob/v1.41.0/examples/helloworld/greeter_client/main.go
- proto文件: https://github.com/grpc/grpc-go/blob/v1.41.0/examples/helloworld/helloworld/helloworld.proto

### 增加新的方法

修改文件`examples/helloworld/helloworld/helloworld.proto`，增加如下内容

```
rpc SayWorld (HelloRequest) returns (HelloReply) {}
```

重新生成`helloworld.pb.go`和`helloworld_grpc.pb.go`

```bash
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    helloworld/helloworld.proto
```

修改server和client代码进行测试即可

## 参考

- https://www.grpc.io/docs/languages/go/quickstart/
- https://github.com/zhyoulun/grpc-example