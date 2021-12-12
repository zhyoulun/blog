### 查询所有的keys，或者以某个前缀的keys

```
etcdctl get --prefix ""
etcdctl get --prefix "/my-prefix"
```

### 只列出keys，不显示值

```
etcdctl get --prefix --keys-only ""
etcdctl get --prefix --keys-only "/my-prefix"
```

## 参考

- [etcd客户端查询所有keys或者列出某个前缀的keys](https://github.com/nange/blog/issues/24)