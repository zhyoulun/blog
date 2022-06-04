## 概要

### 接口列表

- Addr
  - Network() string
  - String() string


### 类列表

- UDPConn
  - WriteTo(b []byte, addr Addr) (int, error)
  - ReadFrom(b []byte) (int, Addr, error)
  - WriteToUDP(b []byte, addr *UDPAddr) (int, error)
  - ReadFromUDP(b []byte) (int, *UDPAddr, error)
  - WriteMsgUDP(b, oob []byte, addr *UDPAddr) (n, oobn int, err error)
  - ReadMsgUDP(b, oob []byte) (n, oobn, flags int, addr *UDPAddr, err error)
  - SyscallConn() (syscall.RawConn, error)

- UDPAddr
  - Network() string
  - String() string


### 关系

//todo
