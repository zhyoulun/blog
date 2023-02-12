# nacos quick start in docker

## 步骤

下载代码

```
git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
```

启动服务

```
docker-compose -f example/standalone-mysql-5.7.yaml up
```

访问http://127.0.0.1:8848/nacos/

默认账号密码：nacos/nacos

## 截图示例

![](/static/images/2212/p005.png)

## 参考

- https://nacos.io/zh-cn/docs/quick-start-docker.html