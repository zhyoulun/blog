## 安装

- https://cluster-api.sigs.k8s.io/user/quick-start.html#install-andor-configure-a-kubernetes-cluster
- 安装kubectl
  - https://kubernetes.io/docs/tasks/tools/
- 安装docker
  - https://docs.docker.com/engine/install/ubuntu/
- 安装kind
  - https://kind.sigs.k8s.io/


## quick start

- digital ocean: https://github.com/kubernetes-sigs/cluster-api-provider-digitalocean/blob/main/docs/getting-started.md

### 遇到的问题

`User's Python3 binary directory must be in $PATH`

参考:https://github.com/kubernetes-sigs/image-builder/issues/630

解决方法：增加PATH环境变量

```
PATH=~/.local/bin:$PATH HTTP_PROXY="http://192.168.56.1:8123" HTTPS_PROXY="http://192.168.56.1:8123" make build-do-ubuntu-2004
```
