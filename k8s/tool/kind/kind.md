创建集群

```
kind create cluster
```

确保源码放到`$(go env GOPATH)/src/k8s.io/kubernetes`

```
kind build node-image
kind create cluster --image kindest/node:latest
```