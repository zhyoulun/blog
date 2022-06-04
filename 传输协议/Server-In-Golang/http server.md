## 概要

### 接口列表

- Listener
  - Accept() (Conn, error)
  - Close() error
  - Addr() Addr
- ResponseWriter
  - Header() Header
  - Write([]byte) (int, error)
  - WriteHeader(statusCode int)

### 类列表

- Server
  - 重要的方法
    - ListenAndServe() error
    - Serve(l net.Listener) error
    - Shutdown(ctx context.Context) error
    - Close() error
  - 不重要的方法
    - ListenAndServeTLS(certFile, keyFile string) error
    - ServeTLS(l net.Listener, certFile, keyFile string) error
    - ExportAllConnsByState() map[ConnState]int
    - ExportAllConnsIdle() bool
    - SetKeepAlivesEnabled(v bool)
    - RegisterOnShutdown(f func())
- ServeMux
  - Handle(pattern string, handler Handler)
  - HandleFunc(pattern string, handler func(ResponseWriter, *Request))
  - Handler(r *Request) (h Handler, pattern string)
  - ServeHTTP(w ResponseWriter, r *Request)
- Request
  - 略，方法比较多

### 关系

//todo
