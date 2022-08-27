## 别人搭建好的

- https://github.com/opsnull/follow-me-install-kubernetes-cluster
  - 手把手搭建
- https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster
  - 当我们需要在本地开发时，更希望能够有一个开箱即用又可以方便定制的分布式开发环境，这样才能对Kubernetes本身和应用进行更好的测试。现在我们使用Vagrant和VirtualBox来创建一个这样的环境。
- https://github.com/rootsongjc/cloud-native-sandbox
  - 因为使用虚拟机创建分布式Kubernetes集群比较耗费资源，所以我又仅使用Docker创建Standalone的Kubernetes的轻量级Cloud Native Sandbox


## 我的搭建



## 问题备忘

报错

`* Unknown configuration section 'vbguest'.`

如何解决

`vagrant plugin install vagrant-vbguest`

报错

```
Aug 24 05:39:47 vm2 kube-proxy[19394]: I0824 05:39:47.997498   19394 proxier.go:793] Not using `--random-fully` in the MASQUERADE rule for iptables because the local version of iptables does not support it
```

如何解决

//todo

报错

```
E0825 05:50:04.363750    8279 server_others.go:340] can't determine whether to use ipvs proxy, error: error getting ipset version, error: executable file not found in $PATH
```

如何解决

```
apt install ipset
```

```
Failed to pull image "calico/node:v3.16.10": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/calico/node:v3.16.10": failed to resolve reference "docker.io/calico/node:v3.16.10": failed to authorize: failed to fetch anonymous token: Get https://auth.docker.io/token?scope=repository%3Acalico%2Fnode%3Apull&service=registry.docker.io: net/http: TLS handshake timeout
```

如何解决

```
root@vm1:/opt/k8s/work/calico# diff calico.yaml calico.yaml.orig
3568c3568
<           image: ustc-edu-cn.mirror.aliyuncs.com/calico/cni:v3.16.10
---
>           image: calico/cni:v3.16.10
```

```bash
# cat containerd-config.toml
version = 2
root = "/data/k8s/containerd/root"
state = "/data/k8s/containerd/state"

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.cn-beijing.aliyuncs.com/zhoujun/pause-amd64:3.1"
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/k8s/bin"
      conf_dir = "/etc/cni/net.d"
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.56.1:5000"]
          endpoint = ["http://192.168.56.1:5000"]
  [plugins."io.containerd.runtime.v1.linux"]
    shim = "containerd-shim"
    runtime = "runc"
    runtime_root = ""
    no_shim = false
    shim_debug = false
```


参考：
- https://github.com/dotless-de/vagrant-vbguest/issues/56
- https://www.gylinux.cn/2795.html
- Adding insecure registry in containerd, https://stackoverflow.com/questions/65681045/adding-insecure-registry-in-containerd
- 修改镜像tag，并上传在本地的私有仓库, https://www.cnblogs.com/Christine-ting/p/12837250.html
- 安装运行 docker-registry, https://yeasy.gitbook.io/docker_practice/repository/registry
