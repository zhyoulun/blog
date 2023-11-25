- git@github.com:zhyoulun/kind.git

```
make kind
```

- https://kind.sigs.k8s.io/docs/contributing/development/#building-the-base-image

```
make quick
```

```
docker run -it --privileged gcr.io/k8s-staging-kind/base:v20231112-b8c6bf48-dirty bash
```

测试新image的时候，需要`--privileged`


- https://kind.sigs.k8s.io/docs/design/node-image/

```
./bin/kind build node-image /root/codes/github/kubernetes --base-image gcr.io/k8s-staging-kind/base:v20231112-b8c6bf48-dirty --image kindest/node:z01
```