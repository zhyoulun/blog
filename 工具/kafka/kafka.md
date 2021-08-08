kafka常用命令

```
查看topic列表
./kafka-topics.sh --bootstrap-server localhost:9092 --list

创建一个topic
./kafka-topics.sh --bootstrap-server localhost:9092 --create --topic hello_topic

生产消息
./kafka-console-producer.sh --bootstrap-server localhost:9092 --topic hello_topic

消费消息
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic hello_topic --from-beginning
```

## 参考

- [https://kafka.apache.org/quickstart](https://kafka.apache.org/quickstart)