### hello world

```
logstash --path.data /tmp -e 'input { stdin { } } output { stdout {} }'
```

- `--path.data`必须可写，并且不能和另外一个logstash有冲突

输入与输出示例

```
abc
{
    "@timestamp" => 2021-09-21T09:45:43.632Z,
          "host" => "9fd8a8f16e68",
      "@version" => "1",
       "message" => "abc"
}
def
{
    "@timestamp" => 2021-09-21T09:45:45.664Z,
          "host" => "9fd8a8f16e68",
      "@version" => "1",
       "message" => "def"
}
```

## 参考

- [https://www.elastic.co/guide/en/logstash/current/first-event.html](https://www.elastic.co/guide/en/logstash/current/first-event.html)
- [Logstash消费kafka同步数据到Elasticsearch](https://www.codenong.com/cs106004915/)