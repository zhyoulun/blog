### 安装Halyard

https://spinnaker.io/docs/setup/install/halyard/#install-halyard-on-docker

```
docker run -p 8084:8084 -p 9000:9000 \
    --name halyard --rm \
    --network kind \
    -v ~/.hal:/home/spinnaker/.hal \
    -v ~/.kind:/home/spinnaker/.kube \
    -it \
    us-docker.pkg.dev/spinnaker-community/docker/halyard:stable
```



### 创建kind集群

```
kind create cluster --config ./create_kind_cluster.yaml --name kind3
```

### 方便对外暴露服务

安装nginx ingress

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```



```
kubectl apply -f ./create_jenkins_deployment.yaml
```

```
kubectl apply -f ./create_jenkins_service.yaml
```

安装arkade

```
curl -sLS https://raw.githubusercontent.com/alexellis/arkade/master/get.sh | sudo sh
```

```
arkade install docker-registry
arkade install cert-manager
```

```
export DOCKER_REGISTRY=docker.spinbook.local
export DOCKER_EMAIL=docker@spinbook.local
arkade install docker-registry-ingress --email $DOCKER_EMAIL --domain $DOCKER_REGISTRY
```

```
curl -sLS https://raw.githubusercontent.com/spinnaker/halyard/master/install/macos/InstallHalyard.sh | sudo sh
```