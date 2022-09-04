- controller-manager参数文档：https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/kube-controller-manager/

```bash
/opt/k8s/bin/kube-controller-manager \
#通过位于 host:port/debug/pprof/ 的 Web 接口启用性能分析。
  --profiling \
#集群实例的前缀。
  --cluster-name=kubernetes \
#要启用的控制器列表。* 表示启用所有默认启用的控制器； foo 启用名为 foo 的控制器； -foo 表示禁用名为 foo 的控制器。
  --controllers=*,bootstrapsigner,tokencleaner \
#与 API 服务器通信时每秒请求数（QPS）限制。
  --kube-api-qps=1000 \
#与 Kubernetes API 服务器通信时突发峰值请求个数上限。
  --kube-api-burst=2000 \
#在执行主循环之前，启动领导选举（Leader Election）客户端，并尝试获得领导者身份。 在运行多副本组件时启用此标志有助于提高可用性。
  --leader-elect \
#当此标志为 true 时，为每个控制器单独使用服务账号凭据。
  --use-service-account-credentials \
#可以并发同步的 Service 对象个数。数值越大，服务管理的响应速度越快， 不过对 CPU （和网络）的占用也越高。
  --concurrent-service-syncs=2 \

# 服务监听配置
  --bind-address=192.168.56.101 \
  --secure-port=10252 \
  --tls-cert-file=/etc/kubernetes/cert/kube-controller-manager.pem \
  --tls-private-key-file=/etc/kubernetes/cert/kube-controller-manager-key.pem \
  --port=0 \

  --authentication-kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
  --client-ca-file=/etc/kubernetes/cert/ca.pem \
  --requestheader-allowed-names=aggregator \
  --requestheader-client-ca-file=/etc/kubernetes/cert/ca.pem \
  --requestheader-extra-headers-prefix=X-Remote-Extra- \
  --requestheader-group-headers=X-Remote-Group \
  --requestheader-username-headers=X-Remote-User \
  --authorization-kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
  --cluster-signing-cert-file=/etc/kubernetes/cert/ca.pem \
  --cluster-signing-key-file=/etc/kubernetes/cert/ca-key.pem \
  --experimental-cluster-signing-duration=876000h \
  --horizontal-pod-autoscaler-sync-period=10s \
  --concurrent-deployment-syncs=10 \
  --concurrent-gc-syncs=30 \
  --node-cidr-mask-size=24 \
#集群中 Service 对象的 CIDR 范围。要求 --allocate-node-cidrs 标志为 true。
  --service-cluster-ip-range=10.254.0.0/16 \
  --pod-eviction-timeout=6m \
  --terminated-pod-gc-threshold=10000 \
  --root-ca-file=/etc/kubernetes/cert/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/cert/ca-key.pem \
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \
  --logtostderr=true \
  --v=2
```
