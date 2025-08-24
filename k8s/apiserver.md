apiserver参数文档：https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-apiserver/

kube-apiserver启动命令示例：

```bash
/opt/k8s/bin/kube-apiserver \
	--advertise-address=192.168.56.101 \
	--default-not-ready-toleration-seconds=360 \
	--default-unreachable-toleration-seconds=360 \
	--feature-gates=DynamicAuditing=true \
	--max-mutating-requests-inflight=2000 \
	--max-requests-inflight=4000 \
	--default-watch-cache-size=200 \

# 为 DeleteCollection 调用而产生的工作线程数。 这些用于加速名字空间清理。
	--delete-collection-workers=2 \

# 包含加密提供程序配置信息的文件，用在 etcd 中所存储的 Secret 上。
	--encryption-provider-config=/etc/kubernetes/encryption-config.yaml \

# 依赖etcd的配置
	--etcd-cafile=/etc/kubernetes/cert/ca.pem \
	--etcd-certfile=/etc/kubernetes/cert/kubernetes.pem \
	--etcd-keyfile=/etc/kubernetes/cert/kubernetes-key.pem \
	--etcd-servers=https://192.168.56.101:2379,https://192.168.56.102:2379,https://192.168.56.103:2379 \

# apiserver监听的端口和证书
	--bind-address=192.168.56.101 \
	--secure-port=6443 \
	--tls-cert-file=/etc/kubernetes/cert/kubernetes.pem \
	--tls-private-key-file=/etc/kubernetes/cert/kubernetes-key.pem \
	--insecure-port=0 \

## 审计日志配置
	--audit-dynamic-configuration \
# 根据文件名中编码的时间戳保留旧审计日志文件的最大天数。
	--audit-log-maxage=15 \
# 要保留的旧的审计日志文件个数上限。 将值设置为 0 表示对文件个数没有限制。
	--audit-log-maxbackup=3 \
# 定义要保留的审计日志文件的最大数量
	--audit-log-maxsize=100 \
# 是否弃用事件和批次的截断处理。
	--audit-log-truncate-enabled \
# 如果设置，则所有到达 API 服务器的请求都将记录到该文件中。 "-" 表示标准输出。
	--audit-log-path=/data/k8s/k8s/kube-apiserver/audit.log \
# 定义审计策略配置的文件的路径。
	--audit-policy-file=/etc/kubernetes/audit-policy.yaml \

# 通过 Web 接口 host:port/debug/pprof/ 启用性能分析。
	--profiling \

# 如果为true则表示启用到 API 服务器的安全端口的匿名请求。 未被其他认证方法拒绝的请求被当做匿名请求。 匿名请求的用户名为 system:anonymous， 用户组名为 system:unauthenticated
	--anonymous-auth=false \

# 如果已设置，则使用与客户端证书的 CommonName 对应的标识对任何出示由 client-ca 文件中的授权机构之一签名的客户端证书的请求进行身份验证。；；；没有看明白
	--client-ca-file=/etc/kubernetes/cert/ca.pem \

# 启用以允许将 "kube-system" 名字空间中类型为 "bootstrap.kubernetes.io/token" 的 Secret 用于 TLS 引导身份验证。
	--enable-bootstrap-token-auth \

# --requestheader-*：kube-apiserver 的 aggregator layer 相关的配置参数，proxy-client & HPA 需要使用；
	--requestheader-allowed-names=aggregator \
	--requestheader-client-ca-file=/etc/kubernetes/cert/ca.pem \
	--requestheader-extra-headers-prefix=X-Remote-Extra- \
	--requestheader-group-headers=X-Remote-Group \
	--requestheader-username-headers=X-Remote-User \

	--service-account-key-file=/etc/kubernetes/cert/ca.pem \
	--authorization-mode=Node,RBAC \
	--runtime-config=api/all=true \
	--enable-admission-plugins=NodeRestriction \
	--allow-privileged=true \
	--apiserver-count=3 \
	--event-ttl=168h \

# --kubelet-*：如果指定，则使用 https 访问 kubelet APIs；需要为证书对应的用户(上面 kubernetes*.pem 证书的用户为 kubernetes) 用户定义 RBAC 规则，否则访问 kubelet API 时提示未授权；
	--kubelet-certificate-authority=/etc/kubernetes/cert/ca.pem \
	--kubelet-client-certificate=/etc/kubernetes/cert/kubernetes.pem \
	--kubelet-client-key=/etc/kubernetes/cert/kubernetes-key.pem \
	--kubelet-https=true \
	--kubelet-timeout=10s \

	--proxy-client-cert-file=/etc/kubernetes/cert/proxy-client.pem \
	--proxy-client-key-file=/etc/kubernetes/cert/proxy-client-key.pem \
	--service-cluster-ip-range=10.254.0.0/16 \
	--service-node-port-range=30000-32767 \
	--logtostderr=true \
	--v=2
```

### 测试apiserver接口

```
curl --cert admin.pem --key admin-key.pem --cacert ./ca.pem -v https://192.168.56.101:6443/api
```

响应结果

```
*   Trying 192.168.56.101...
* Connected to 192.168.56.101 (192.168.56.101) port 6443 (#0)
* found 1 certificates in ./ca.pem
* found 516 certificates in /etc/ssl/certs
* ALPN, offering http/1.1
* SSL connection using TLS1.2 / ECDHE_RSA_AES_128_GCM_SHA256
* 	 server certificate verification OK
* 	 server certificate status verification SKIPPED
* 	 common name: kubernetes-master (matched)
* 	 server certificate expiration date OK
* 	 server certificate activation date OK
* 	 certificate public key: RSA
* 	 certificate version: #3
* 	 subject: C=CN,ST=BeiJing,L=BeiJing,O=k8s,OU=opsnull,CN=kubernetes-master
* 	 start date: Sun, 21 Aug 2022 03:21:00 GMT
* 	 expire date: Tue, 28 Jul 2122 03:21:00 GMT
* 	 issuer: C=CN,ST=BeiJing,L=BeiJing,O=k8s,OU=opsnull,CN=kubernetes-ca
* 	 compression: NULL
* ALPN, server accepted to use http/1.1
> GET /api HTTP/1.1
> Host: 192.168.56.101:6443
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Audit-Id: e412c9c0-eff1-48ae-b344-eade7ad2102e
< Cache-Control: no-cache, private
< Content-Type: application/json
< Date: Sat, 03 Sep 2022 15:09:01 GMT
< Content-Length: 186
<
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "192.168.56.101:6443"
    }
  ]
* Connection #0 to host 192.168.56.101 left intact
```

### 查看apiserver目前支持的资源对象种类

```
curl --cert admin.pem --key admin-key.pem --cacert ./ca.pem -i https://192.168.56.101:6443/api/v1
```

## 参考

- [05-2. 部署 kube-apiserver 集群](https://github.com/opsnull/follow-me-install-kubernetes-cluster/blob/master/05-2.apiserver%E9%9B%86%E7%BE%A4.md)
