## 使用

- kibana: http://localhost:5601/app/home#/
  - 配置index pattern后可以使用
- prometheus webUI: http://localhost:9090/

## 调试

### 查看kafka topic列表

进入kafka container，kafka bin目录在`/opt/bitnami/kafka/bin/`

```
kafka-topics.sh --list --zookeeper zookeeper:2181
```

### kafka消费测试

进入kafka container，kafka bin目录在`/opt/bitnami/kafka/bin/`

```
kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic prometheus_metrics --from-beginning
```

### logstash配置文件

```
input {
    kafka {
        bootstrap_servers => ["kafka:9092"]
        client_id => "logstash_1"
        group_id => "consumer_group_1"
        auto_offset_reset => "latest"
        decorate_events => "true"
        topics => "prometheus_metrics"
        codec => "json"
    }
}
output {
    elasticsearch {
        hosts => ["elasticsearch:9200"]
        index => "prometheus_metrics"
    }
}
```