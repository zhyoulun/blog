## routes.go

写路由表

代码

![](/static/images/2311/p003.png)

日志

```log
I1126 14:37:12.375169       1 main.go:223] Handling node with IPs: map[172.20.0.4:{}]
I1126 14:37:12.375172       1 main.go:227] handling current node
I1126 14:37:22.377494       1 main.go:223] Handling node with IPs: map[172.20.0.2:{}]
I1126 14:37:22.377507       1 main.go:250] Node kind-test1-control-plane has CIDR [10.244.0.0/24]
I1126 14:37:22.377572       1 main.go:223] Handling node with IPs: map[172.20.0.3:{}]
I1126 14:37:22.377577       1 main.go:250] Node kind-test1-worker has CIDR [10.244.1.0/24]
I1126 14:37:22.377597       1 main.go:223] Handling node with IPs: map[172.20.0.5:{}]
I1126 14:37:22.377601       1 main.go:250] Node kind-test1-worker2 has CIDR [10.244.3.0/24]
```

路由表

```bash
root@kind-test1-worker3:/# ip route
default via 172.20.0.1 dev eth0
10.244.0.0/24 via 172.20.0.2 dev eth0 //
10.244.1.0/24 via 172.20.0.3 dev eth0 //
10.244.3.0/24 via 172.20.0.5 dev eth0 //
10.244.2.2 dev vethbb7627ba scope host
10.244.2.3 dev vethe281cb12 scope host
172.20.0.0/16 dev eth0 proto kernel scope link src 172.20.0.4
```

写出的文件

```bash
root@kind-test1-worker3:/# cat /etc/cni/net.d/10-kindnet.conflist

{
	"cniVersion": "0.3.1",
	"name": "kindnet",
	"plugins": [
	{
		"type": "ptp",
		"ipMasq": false,
		"ipam": {
			"type": "host-local",
			"dataDir": "/run/cni-ipam-state",
			"routes": [


				{ "dst": "0.0.0.0/0" }
			],
			"ranges": [


				[ { "subnet": "10.244.2.0/24" } ]
			]
		}
		,
		"mtu": 1500

	},
	{
		"type": "portmap",
		"capabilities": {
			"portMappings": true
		}
	}
	]
}
```

## masq.go

代码

![](/static/images/2311/p004.png)

## cni

代码

![](/static/images/2311/p005.png)

在1.24之前，cni相关信息由kubelet读取

![](/static/images/2311/p006.png)

之后由容器运行时读取

https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/

![](/static/images/2311/p007.png)

```
root@kind-test1-worker3:/# /usr/local/bin/containerd config dump | grep cni
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
        cni_conf_dir = ""
        cni_max_conf_num = 0
          cni_conf_dir = ""
          cni_max_conf_num = 0
          cni_conf_dir = ""
          cni_max_conf_num = 0
        cni_conf_dir = ""
        cni_max_conf_num = 0
```