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

备注：这里似乎没有server的概念

### 类列表

- TCPConn
  - ReadFrom(r io.Reader) (int64, error)
  - SetKeepAlive(keepalive bool) error
  - SetKeepAlivePeriod(d time.Duration) error
  - SetLinger(sec int) error
  - SetNoDelay(noDelay bool) error
  - SyscallConn() (syscall.RawConn, error)
  - CloseRead() error
  - CloseWrite() error

### 关系

//todo
