## 概要

### 接口列表

- Listener
  - Accept() (Conn, error)
  - Close() error
  - Addr() Addr
- Conn
  - Read(b []byte) (n int, err error)
  - Write(b []byte) (n int, err error)
  - Close() error
  - LocalAddr() Addr
  - RemoteAddr() Addr
  - SetDeadline(t time.Time) error
  - SetReadDeadline(t time.Time) error
  - SetWriteDeadline(t time.Time) error

备注：

- kcp的接口和tcp的接口是一致的
- 这里似乎没有server的概念

### 类列表

//todo

### 关系

//todo
