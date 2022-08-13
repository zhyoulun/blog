### hostNetwork

缺点：

- 每次启动这个 Pod 的时候都可能被调度到不同的节点上，所有外部访问 Pod 的 IP 也是变化的
- 调度 Pod 的时候还需要考虑是否与宿主机上的端口冲突

使用场景：

- 一般情况下除非您知道需要某个特定应用占用特定宿主机上的特定端口时才使用 hostNetwork: true 的方式。
- 可以将网络插件包装在 Pod 中然后部署在每个宿主机上，这样该 Pod 就可以控制该宿主机上的所有网络

### hostPort

直接将容器的端口与所调度的节点上的端口路由，这样用户就可以通过宿主机的 IP 加上来访问 Pod 了

缺点：

- Pod 重新调度的时候该 Pod 被调度到的宿主机可能会变动，这样就变化了，用户必须自己维护一个 Pod 与所在宿主机的对应关系

使用场景：

- 用来做 nginx ingress controller。外部流量都需要通过 Kubernetes node 节点的 80 和 443 端口

### NodePort

描述：

集群外就可以使用 kubernetes 任意一个节点的 IP 加上 30000 端口访问该服务了。kube-proxy 会自动将流量以 round-robin 的方式转发给该 service 的每一个 pod。

缺点：

- 这种服务暴露方式，无法让你指定自己想要的应用常用端口，不过可以在集群上再部署一个反向代理作为流量入口。

### LoadBalancer

```
$ kubectl get svc influxdb
NAME       CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
influxdb   10.97.121.42   10.13.242.236   8086:30051/TCP   39s
```

使用方法：

- 内部可以使用 ClusterIP 加端口来访问服务，如 19.97.121.42:8086。
- 外部可以用以下两种方式访问该服务：
  - 使用任一节点的 IP 加 30051 端口访问该服务
  - 使用 EXTERNAL-IP 来访问，这是一个 VIP，是云供应商提供的负载均衡器 IP，如 10.13.242.236:8086。

### Ingress

描述：

- 必须要部署 Ingress controller 才能创建 Ingress 资源，Ingress controller 是以一种插件的形式提供。
- Ingress controller 是部署在 Kubernetes 之上的 Docker 容器
- 它的 Docker 镜像包含一个像 nginx 或 HAProxy 的负载均衡器和一个控制器守护进程。
- 控制器守护程序从 Kubernetes 接收所需的 Ingress 配置。它会生成一个 nginx 或 HAProxy 配置文件，并重新启动负载平衡器进程以使更改生效。
- 换句话说，Ingress controller 是由 Kubernetes 管理的负载均衡器。

## 参考

- [从外部访问 Kubernetes 中的 Pod](https://jimmysong.io/kubernetes-handbook/guide/accessing-kubernetes-pods-from-outside-of-the-cluster.html)
