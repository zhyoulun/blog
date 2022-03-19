### webrtc架构

![](/static/images/2203/p001.jpeg)

### 通话基本流程

![](/static/images/2203/p002.jpeg)

- SDP：session description protocol，绘画描述协议

### 网络协商/网络穿透

- 需求：NAT穿透：借助一台公网IP服务器，PeerA和PeerB都往公网IP/PORT发包，然后也可以反方向发包；公网IP将PeerB的IP/PORT发给PeerA，PeerA的IP/PORT发给PeerB，这样PeerA和PeerB之间就可以直接相互通信了
- 解决需求的框架：ICE（interactive connectivity establishment，互动式连接建立）：使各种NAT穿透技术（STUN/TURN等）实现统一
- STUN（simple traversal of UDP through NAT，简单UDP穿透NAT）
  - NAT有不同类型，四种主要类型只能处理其中三种：完全圆锥形NAT、受限型NAT、端口受限圆锥形NAT
  - 一般处理不了对称性NAT（也称双向NAT），这样就得需要TURN技术
- TURN (traversal Using Relays around NAT，使用中继穿透NAT)：将公网服务器作为中继，对往来数据进行 转发

### 服务端需要部署的组件列表

- 信令服务器：解决媒体协商需求（sdp）
- 媒体服务器：解决网络协程需求（stun）和媒体数据转发需求（turn）

开源的信令服务器：

开源的媒体服务器：

- https://github.com/coturn/coturn
- https://github.com/pion/turn

webrtc项目：

- https://github.com/node-webrtc/node-webrtc-examples

webrtc-book代码：

- https://github.com/kangshaojun/webrtc-book
