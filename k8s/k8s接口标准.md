- CRI （Container Runtime Interface）：容器运行时接口，CRI中定义了容器和镜像两个接口，实现了这两个接口的目前主流的是：CRI-O、Containerd。（目前 PCI 产品使用的即为 Containerd）。
- OCI（Open Container Initiative）：开放容器标准，OCI 中定义了两个标准：容器运行时标准和容器镜像标准，实现了这一标准的主流是：runc（也即我们日常说的 Docker）、Kata-Container
- CNI（Container Network Interface）：容器网络接口，CNI接口只有两个：容器创建分配网络资源、容器删除释放网络资源。
- CSI（Container Storage Interface）：容器存储接口，用于 Kubernetes 中。


## 参考

- [容器概念：OCI、CRI、CNI介绍](https://github.com/penglongli/blog/issues/126)
