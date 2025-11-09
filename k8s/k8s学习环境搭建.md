## 别人搭建好的

- https://github.com/opsnull/follow-me-install-kubernetes-cluster
  - 手把手搭建
- https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster
  - 当我们需要在本地开发时，更希望能够有一个开箱即用又可以方便定制的分布式开发环境，这样才能对Kubernetes本身和应用进行更好的测试。现在我们使用Vagrant和VirtualBox来创建一个这样的环境。
- https://github.com/rootsongjc/cloud-native-sandbox
  - 因为使用虚拟机创建分布式Kubernetes集群比较耗费资源，所以我又仅使用Docker创建Standalone的Kubernetes的轻量级Cloud Native Sandbox


## 我的搭建

https://github.com/zhyoulun/build/tree/master/k8s

参考：
- https://github.com/dotless-de/vagrant-vbguest/issues/56
- https://www.gylinux.cn/2795.html
- Adding insecure registry in containerd, https://stackoverflow.com/questions/65681045/adding-insecure-registry-in-containerd
- 修改镜像tag，并上传在本地的私有仓库, https://www.cnblogs.com/Christine-ting/p/12837250.html
- 安装运行 docker-registry, https://yeasy.gitbook.io/docker_practice/repository/registry
