### 安装环境

再docker中运行，https://www.jenkins.io/zh/doc/book/installing/#docker

```
docker run \
  -u root \
  --rm \
  -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean
```

配置，https://www.jenkins.io/zh/doc/book/installing/#setup-wizard

访问地址：http://localhost:8080/

初始密码在/var/jenkins_home/secrets/initialAdminPassword




## 参考

- [53个Jenkins面试题](https://www.cnblogs.com/www-jsdaima-com/p/16288754.html)
