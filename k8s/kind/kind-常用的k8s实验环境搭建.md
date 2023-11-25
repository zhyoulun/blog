## 创建有三个node的集群

kind配置文件，`config.yaml`：

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "0.0.0.0"
nodes:
- role: control-plane
- role: worker
  image: kindest/node:z01
- role: worker
  image: kindest/node:z01
- role: worker
  image: kindest/node:z01
```

其中：

- apiServerAddress：可以做到远程访问apiserver

创建：

```
kind create cluster --config config.yaml --name kind-test1
```

预期会有如下运行结果：

```
Creating cluster "kind-test1" ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼
 ✓ Ensuring node image (kindest/node:z01) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-kind-test1"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-test1

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

## 安装web ui dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

```
kubectl port-forward -n kubernetes-dashboard --address 0.0.0.0 service/kubernetes-dashboard 8081:443
```

获取token，用token登录

```
# cat /tmp/2.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

`kubectl apply -f /tmp/2.yaml`

```
# cat /tmp/3.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

`kubectl apply -f /tmp/3.yaml`

```
kubectl -n kubernetes-dashboard create token admin-user
```

## 启动nginx

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
```

```
kubectl apply -f /tmp/4.yaml
```

```
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
```

```
kubectl apply -f /tmp/5.yaml
```

登陆两个pod，在目录`/usr/share/nginx/html`中分别写入`1.html`文件，内容是`server1`和`server2`

访问serviceIP/1.html，可以看到内容不停的轮转

## SCTP实验，里边有好几个工具

https://isovalent.com/labs/sctp-on-cilium/


## 参考

- https://kind.sigs.k8s.io/docs/user/configuration/
- https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/web-ui-dashboard/
- https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md