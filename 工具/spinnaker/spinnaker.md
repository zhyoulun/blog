### 安装Halyard

https://spinnaker.io/docs/setup/install/halyard/#install-halyard-on-docker

```
docker run -p 8084:8084 -p 9000:9000 \
    --name halyard --rm \
    -v /Users/zhangyoulun/study_space/spinnaker/halyard:/home/spinnaker/.hal \
    -it \
    us-docker.pkg.dev/spinnaker-community/docker/halyard:stable
```



