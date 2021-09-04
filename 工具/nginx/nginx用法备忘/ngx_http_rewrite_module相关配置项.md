### rewrite用法

```conf
http {
    server {
        listen       0.0.0.0:8082;

        # 默认响应403
        location / {
            return 403;
        }

        # 响应301
        location /permanent {
            rewrite ^(.*)$ /v1$1 permanent;
        }
        # 响应302
        location /redirect {
            rewrite ^(.*)$ /v1$1 redirect;
        }
        # 响应200，内部rewrite到/v1/last并请求后端server
        # 停止处理当前的一组 `ngx_http_rewrite_module`指令并开始搜索与改变的URI匹配的新位置;
        location /last {
            rewrite ^(.*)$ /v1$1 last;
        }
        # 响应404
        location /break {
            rewrite ^(.*)$ /v1$1 break; # 当改语句被执行时，该语句就是最终结果
        }

        # 用于接收rewrite请求
        location /v1 {
            proxy_pass http://localhost:8080;
        }
    }
}
```

### if用法

```conf
http {
    server {
        listen       0.0.0.0:8082;

        # 默认响应403
        location / {
            return 403;
        }

        location /if {
            # 如果为POST方法，响应405
            if ($request_method = POST) {
                return 405;
            }
        }

        # 用于接收rewrite请求
        location /v1 {
            proxy_pass http://localhost:8080;
        }
    }
}
```



## 参考

- [http://nginx.org/en/docs/http/ngx_http_rewrite_module.html](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)
- [第七章：nginx的rewrite规则详解](https://www.jianshu.com/p/3b2345f7347d)