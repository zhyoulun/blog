### 主页

https://github.com/thombashi/tcconfig

### 安装

debian/ubuntu安装命令如下

```
curl -sSL https://raw.githubusercontent.com/thombashi/tcconfig/master/scripts/installer.sh | sudo bash
```

### 示例

```bash
tcset --overwrite --device enp0s8 --delay 10
tcdel --device enp0s8
```

![](/static/images/2108/p002.png)

信息

192.168.56.108（本机）和对端通过网卡enp0s8通信

```
root@mydev:/home/zyl# ip route
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.108
```

### 基本功能

限速

```bash
tcset --overwrite --device enp0s8 --rate 100kbps
tcset --overwrite --device enp0s8 --rate 10mbps
tcdel --device enp0s8
```

增加延迟

```bash
tcset --overwrite --device enp0s8 --delay 10ms
tcdel --device enp0s8
```

增加丢包率

```bash
tcset --overwrite --device enp0s8 --loss 2%
tcdel --device enp0s8
```

![](/static/images/2108/p003.png)

查询配置

```bash
root@mydev:/home/zyl# tcshow enp0s8
{
    "enp0s8": {
        "outgoing": {
            "dst-network=192.168.56.109/32, dst-port=22, protocol=ip": {
                "filter_id": "800::800",
                "loss": "2%",
                "rate": "1Gbps"
            }
        },
        "incoming": {}
    }
}
```

### 过滤

指定对端IP丢包

```bash
tcset --overwrite --device enp0s8 --loss 2% --network 192.168.56.109
tcdel --device enp0s8 --all
```

指定对端IP+PORT丢包

```bash
tcset --overwrite --device enp0s8 --loss 2% --network 192.168.56.109 --port 22
tcdel --device enp0s8 --all
```
