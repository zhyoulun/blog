epoll的反应堆模式实现

### 我自己优化后的实现，tcp server echo

```c
#include <sys/socket.h> //socket(),bind(),listen(),accept() in it
#include <netinet/in.h> //struct sockaddr_in, htonl(), htons() in it

#include <string.h>  //strerror() in it
#include <strings.h> //bzero() in it
#include <errno.h>   //errno in it

#include <unistd.h>   //fork(),close(),read(),write() in it
#include <stdlib.h>   //exit() in it
#include <sys/wait.h> //wait() in it
#include <time.h>     //time() in it
#include <sys/time.h> //gettimeofday() in it
#include <stdarg.h>   //va_list in it

#include <sys/select.h> //select() in it
#include <poll.h>       //poll() in it
#include <sys/epoll.h>  //epoll_xx() in it
#include <fcntl.h>      //fcntl() in it

#include <stdio.h>

#define ERR_FAIL 1
#define ERR_EOF 2
#define SERVER_PORT 12345
#define BACKLOG 1024
#define MAX_LINE 1024
#define POLL_MAX_OPEN 1000
#define EPOLL_MAX_EVENTS 10
#define BUF_SIZE 128
#define IDLE_TIMEOUT_S 10
#define EPOLL_WAIT_TIMEOUT_MS 1000

struct myevent_s
{
    int fd;
    int events;
    void *arg;
    void (*callback)(void *arg);
    int status;
    char buf[BUF_SIZE];
    int len;
    long last_active;
};

struct myevent_s g_events[EPOLL_MAX_EVENTS + 1];
int g_epoll_fd;

void mylog(int, const char *, ...);
int http_hello(int);

int init_listen_socket();
int set_non_blocking(int);

void event_new(struct myevent_s *ev, int fd, void (*callback)(void *), void *arg);
void event_del(struct myevent_s *);
void event_add(int, struct myevent_s *);

void callback_accept(void *);
void callback_recv(void *);
void callback_send(void *);

int main(int argc, char **argv)
{
    int result;
    int checkpos, i;

    g_epoll_fd = epoll_create(1);
    if (g_epoll_fd == -1)
    {
        mylog(1, "epoll_create() err");
        return ERR_FAIL;
    }

    result = init_listen_socket();
    if (result != 0)
    {
        mylog(0, "init_listen_socket() err: %d", result);
        return ERR_FAIL;
    }

    checkpos = 0;
    struct epoll_event events[EPOLL_MAX_EVENTS + 1];
    for (;;)
    {
        long now = time(NULL);
        for (i = 0; i < 100; i++, checkpos++)
        {
            if (checkpos == EPOLL_MAX_EVENTS)
            {
                checkpos = 0;
            }
            if (g_events[checkpos].status != 1)
            {
                continue;
            }
            long duration = now - g_events[checkpos].last_active;
            if (duration >= IDLE_TIMEOUT_S)
            {
                event_del(&g_events[checkpos]);

                result = close(g_events[checkpos].fd);
                if (result != 0)
                {
                    mylog(1, "close() err");
                }
                mylog(0, "[fd=%d] timeout", g_events[checkpos].fd);
            }
        }
        int num_fds = epoll_wait(g_epoll_fd, events, EPOLL_MAX_EVENTS + 1, EPOLL_WAIT_TIMEOUT_MS);
        if (num_fds == -1)
        {
            mylog(1, "epoll_wait() err");
            return ERR_FAIL;
        }
        mylog(0, "epoll_wait result, num_fds: %d", num_fds);
        for (i = 0; i < num_fds; i++)
        {
            struct myevent_s *ev = (struct myevent_s *)events[i].data.ptr;
            if ((events[i].events & EPOLLIN) && (ev->events & EPOLLIN))
            {
                ev->callback(ev->arg);
            }
            if ((events[i].events & EPOLLOUT) && (ev->events & EPOLLOUT))
            {
                ev->callback(ev->arg);
            }
        }
    }

    return 0;
}

void event_new(struct myevent_s *ev, int fd, void (*callback)(void *), void *arg)
{
    /*
    int fd;
    int events;
    void *arg;
    void (*callback)(void *arg);
    int status;
    char buf[BUF_SIZE];
    int len;
    long last_active;
    */
    ev->fd = fd;
    ev->events = 0;
    ev->arg = arg;
    ev->callback = callback;
    ev->status = 0;
    //ev->buf
    //ev->len
    ev->last_active = time(NULL);
}

void event_add(int events, struct myevent_s *ev)
{
    struct epoll_event epv;
    int op;
    int result;

    epv.data.ptr = ev;
    epv.events = ev->events = events;

    if (ev->status == 1)
    {
        op = EPOLL_CTL_MOD;
    }
    else
    {
        op = EPOLL_CTL_ADD;
        ev->status = 1;
    }

    result = epoll_ctl(g_epoll_fd, op, ev->fd, &epv);
    if (result == -1)
    {
        mylog(1, "[fd=%d] epoll_ctl() fail: events=%0X", ev->fd, events);
    }
    else
    {
        mylog(0, "[fd=%d] epoll_ctl() success: op=%d, events=%0X", ev->fd, op, events);
    }
}

void event_del(struct myevent_s *ev)
{
    struct epoll_event epv;
    int result;
    int op;

    if (ev->status != 1)
    {
        return;
    }

    op = EPOLL_CTL_DEL;
    epv.data.ptr = ev;
    ev->status = 0;

    result = epoll_ctl(g_epoll_fd, EPOLL_CTL_DEL, ev->fd, &epv);
    if (result == -1)
    {
        mylog(1, "[fd=%d] epoll_ctl() fail", ev->fd);
    }
    else
    {
        mylog(0, "[fd=%d] epoll_ctl() success: op=%d", ev->fd, op);
    }
}

void callback_accept(void *arg)
{
    struct sockaddr_in client_addr;
    int client_addr_len;
    int conn_fd;
    int i;
    int result;
    struct myevent_s *ev;

    ev = (struct myevent_s *)arg;

    client_addr_len = sizeof(client_addr);
    conn_fd = accept(ev->fd, (struct sockaddr *)&client_addr, &client_addr_len);
    if (conn_fd == -1)
    {
        if (errno == EWOULDBLOCK || errno == ECONNABORTED || errno == EPROTO || errno == EINTR)
        {
            //unp P363, 配合listen_fd被设置为非阻塞，忽略这些错误
            mylog(1, "[ln_fd=%d] accept() err, ignore", ev->fd);
            return;
        }
        else
        {
            mylog(1, "[ln_fd=%d] accept() err", ev->fd);
            return;
        }
    }
    mylog(0, "[ln_fd=%d][fd=%d] accept", ev->fd, conn_fd);

    for (i = 0; i < EPOLL_MAX_EVENTS; i++)
    {
        if (g_events[i].status == 0)
        {
            break;
        }
    }
    if (i == EPOLL_MAX_EVENTS)
    {
        mylog(0, "[ln_fd=%d][fd=%d] max connect limit execeed: %d", ev->fd, conn_fd, EPOLL_MAX_EVENTS);
        return;
    }
    //设置conn_fd为非阻塞模式
    result = set_non_blocking(conn_fd);
    if (result != 0)
    {
        mylog(0, "[ln_fd=%d][fd=%d] set_non_blocking() err: %d", ev->fd, conn_fd, result);
        return;
    }
    event_new(&g_events[i], conn_fd, callback_recv, &g_events[i]);
    event_add(EPOLLIN, &g_events[i]);
    return;
}

void callback_recv(void *arg)
{
    struct myevent_s *ev = (struct myevent_s *)arg;
    int len;
    int result;
    len = recv(ev->fd, ev->buf, sizeof(ev->buf), 0);
    event_del(ev);

    if (len > 0)
    {
        ev->len = len;
        ev->buf[len] = '\0';
        mylog(0, "[fd=%d][pos=%d] recv: %s", ev->fd, (int)(ev - g_events), ev->buf);
        event_new(ev, ev->fd, callback_send, ev);
        event_add(EPOLLOUT, ev);
    }
    else if (len == 0)
    {
        mylog(0, "[fd=%d][pos=%d] closed", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
    }
    else
    {
        mylog(1, "[fd=%d][pos=%d] revc() err", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
    }
}
void callback_send(void *arg)
{
    struct myevent_s *ev = (struct myevent_s *)arg;
    int len;
    int result;

    len = send(ev->fd, ev->buf, ev->len, 0);
    event_del(ev);

    if (len > 0)
    {
        mylog(0, "[fd=%d][pos=%d] send: %s", ev->fd, (int)(ev - g_events), ev->buf);
        event_new(ev, ev->fd, callback_recv, ev);
        event_add(EPOLLIN, ev);
    }
    else
    {
        mylog(1, "[fd=%d][pos=%d] send err", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
    }
}

int init_listen_socket()
{
    struct sockaddr_in server_addr, client_addr;
    int client_addr_len;
    int listen_fd;
    int result;
    int child_pid;

    //创建socket
    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_fd == -1)
    {
        mylog(1, "socket() err");
        return ERR_FAIL;
    }
    mylog(0, "[ln_fd=%d] listen", listen_fd);

    //设置listen_fd为非阻塞模式
    result = set_non_blocking(listen_fd);
    if (result != 0)
    {
        mylog(0, "set_non_blocking() err: %d", result);
        return ERR_FAIL;
    }

    event_new(&g_events[EPOLL_MAX_EVENTS], listen_fd, callback_accept, &g_events[EPOLL_MAX_EVENTS]);
    event_add(EPOLLIN, &g_events[EPOLL_MAX_EVENTS]);

    //设置监听的地址和端口
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_port = htons(SERVER_PORT);

    //复用端口
    int on = 1;
    result = setsockopt(listen_fd, SOL_SOCKET, SO_REUSEPORT, &on, sizeof(on));
    if (result == -1)
    {
        mylog(1, "setsockopt() err");
        return ERR_FAIL;
    }

    //bind
    result = bind(listen_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (result == -1)
    {
        mylog(1, "bind() err: %s");
        return ERR_FAIL;
    }

    //listen
    result = listen(listen_fd, BACKLOG);
    if (result == -1)
    {
        mylog(1, "listen() err: %s");
        return ERR_FAIL;
    }
    return 0;
}

int set_non_blocking(int fd)
{
    int opts;
    int result;
    opts = fcntl(fd, F_GETFL);
    if (opts == -1)
    {
        mylog(1, "fcntl() err");
        return ERR_FAIL;
    }
    opts |= O_NONBLOCK;
    result = fcntl(fd, F_SETFL, opts);
    if (result == -1)
    {
        mylog(1, "fcntl() err");
        return ERR_FAIL;
    }
    return 0;
}

void mylog(int errorflag, const char *fmt, ...)
{
    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);
    char buf[MAX_LINE + 1];
    strftime(buf, 23, "[%Y-%m-%d %H:%M:%S] ", tm_info); //[2021-09-05 11:55:37]
    buf[23] = '\0';
    printf("%s", buf);

    char buf2[MAX_LINE + 1];
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(buf2, MAX_LINE, fmt, ap);
    va_end(ap);
    buf2[n] = '\0';
    printf("%s", buf2);
    if (errorflag == 1)
    {
        printf(": %s", strerror(errno));
    }
    printf("\n");
}
```

### 我自己优化后的实现，http server hello

```c
#include <sys/socket.h> //socket(),bind(),listen(),accept() in it
#include <netinet/in.h> //struct sockaddr_in, htonl(), htons() in it

#include <string.h>  //strerror() in it
#include <strings.h> //bzero() in it
#include <errno.h>   //errno in it

#include <unistd.h>   //fork(),close(),read(),write() in it
#include <stdlib.h>   //exit() in it
#include <sys/wait.h> //wait() in it
#include <time.h>     //time() in it
#include <sys/time.h> //gettimeofday() in it
#include <stdarg.h>   //va_list in it

#include <sys/select.h> //select() in it
#include <poll.h>       //poll() in it
#include <sys/epoll.h>  //epoll_xx() in it
#include <fcntl.h>      //fcntl() in it

#include <stdio.h>

#define ERR_FAIL 1
#define ERR_EOF 2
#define SERVER_PORT 12345
#define BACKLOG 1024
#define MAX_LINE 1024
#define POLL_MAX_OPEN 1000
#define EPOLL_MAX_EVENTS 1000
#define BUF_SIZE 128
#define IDLE_TIMEOUT_S 10
#define EPOLL_WAIT_TIMEOUT_MS 1000

struct myevent_s
{
    int fd;
    int events;
    void *arg;
    void (*callback)(void *arg);
    int status;
    // char buf[BUF_SIZE];
    // int len;
    long last_active;
};

struct myevent_s g_events[EPOLL_MAX_EVENTS + 1];
int g_epoll_fd;

void mylog(int, const char *, ...);
int http_hello(int);

int init_listen_socket();
int set_non_blocking(int);

void event_new(struct myevent_s *ev, int fd, void (*callback)(void *), void *arg);
void event_del(struct myevent_s *);
void event_add(int, struct myevent_s *);

void callback_accept(void *);
void callback_recv(void *);
void callback_send(void *);

int main(int argc, char **argv)
{
    int result;
    int checkpos, i;

    g_epoll_fd = epoll_create(1);
    if (g_epoll_fd == -1)
    {
        mylog(1, "epoll_create() err");
        return ERR_FAIL;
    }

    result = init_listen_socket();
    if (result != 0)
    {
        mylog(0, "init_listen_socket() err: %d", result);
        return ERR_FAIL;
    }

    checkpos = 0;
    struct epoll_event events[EPOLL_MAX_EVENTS + 1];
    for (;;)
    {
        long now = time(NULL);
        for (i = 0; i < 100; i++, checkpos++)
        {
            if (checkpos == EPOLL_MAX_EVENTS)
            {
                checkpos = 0;
            }
            if (g_events[checkpos].status != 1)
            {
                continue;
            }
            long duration = now - g_events[checkpos].last_active;
            if (duration >= IDLE_TIMEOUT_S)
            {
                event_del(&g_events[checkpos]);

                result = close(g_events[checkpos].fd);
                if (result != 0)
                {
                    mylog(1, "close() err");
                }
                mylog(0, "[fd=%d] timeout", g_events[checkpos].fd);
            }
        }
        int num_fds = epoll_wait(g_epoll_fd, events, EPOLL_MAX_EVENTS + 1, EPOLL_WAIT_TIMEOUT_MS);
        if (num_fds == -1)
        {
            mylog(1, "epoll_wait() err");
            return ERR_FAIL;
        }
        mylog(0, "epoll_wait result, num_fds: %d", num_fds);
        for (i = 0; i < num_fds; i++)
        {
            struct myevent_s *ev = (struct myevent_s *)events[i].data.ptr;
            if ((events[i].events & EPOLLIN) && (ev->events & EPOLLIN))
            {
                ev->callback(ev->arg);
            }
            if ((events[i].events & EPOLLOUT) && (ev->events & EPOLLOUT))
            {
                ev->callback(ev->arg);
            }
        }
    }

    return 0;
}

void event_new(struct myevent_s *ev, int fd, void (*callback)(void *), void *arg)
{
    /*
    int fd;
    int events;
    void *arg;
    void (*callback)(void *arg);
    int status;
    char buf[BUF_SIZE];
    int len;
    long last_active;
    */
    ev->fd = fd;
    ev->events = 0;
    ev->arg = arg;
    ev->callback = callback;
    ev->status = 0;
    //ev->buf
    //ev->len
    ev->last_active = time(NULL);
}

void event_add(int events, struct myevent_s *ev)
{
    struct epoll_event epv;
    int op;
    int result;

    epv.data.ptr = ev;
    epv.events = ev->events = events;

    if (ev->status == 1)
    {
        op = EPOLL_CTL_MOD;
    }
    else
    {
        op = EPOLL_CTL_ADD;
        ev->status = 1;
    }

    result = epoll_ctl(g_epoll_fd, op, ev->fd, &epv);
    if (result == -1)
    {
        mylog(1, "[fd=%d] epoll_ctl() fail: events=%0X", ev->fd, events);
    }
    else
    {
        mylog(0, "[fd=%d] epoll_ctl() success: op=%d, events=%0X", ev->fd, op, events);
    }
}

void event_del(struct myevent_s *ev)
{
    struct epoll_event epv;
    int result;
    int op;

    if (ev->status != 1)
    {
        return;
    }

    op = EPOLL_CTL_DEL;
    epv.data.ptr = ev;
    ev->status = 0;

    result = epoll_ctl(g_epoll_fd, EPOLL_CTL_DEL, ev->fd, &epv);
    if (result == -1)
    {
        mylog(1, "[fd=%d] epoll_ctl() fail", ev->fd);
    }
    else
    {
        mylog(0, "[fd=%d] epoll_ctl() success: op=%d", ev->fd, op);
    }
}

void callback_accept(void *arg)
{
    struct sockaddr_in client_addr;
    int client_addr_len;
    int conn_fd;
    int i;
    int result;
    struct myevent_s *ev;

    ev = (struct myevent_s *)arg;

    client_addr_len = sizeof(client_addr);
    conn_fd = accept(ev->fd, (struct sockaddr *)&client_addr, &client_addr_len);
    if (conn_fd == -1)
    {
        if (errno == EWOULDBLOCK || errno == ECONNABORTED || errno == EPROTO || errno == EINTR)
        {
            //unp P363, 配合listen_fd被设置为非阻塞，忽略这些错误
            mylog(1, "[ln_fd=%d] accept() err, ignore", ev->fd);
            return;
        }
        else
        {
            mylog(1, "[ln_fd=%d] accept() err", ev->fd);
            return;
        }
    }
    mylog(0, "[ln_fd=%d][fd=%d] accept", ev->fd, conn_fd);

    for (i = 0; i < EPOLL_MAX_EVENTS; i++)
    {
        if (g_events[i].status == 0)
        {
            break;
        }
    }
    if (i == EPOLL_MAX_EVENTS)
    {
        mylog(0, "[ln_fd=%d][fd=%d] max connect limit execeed: %d", ev->fd, conn_fd, EPOLL_MAX_EVENTS);
        return;
    }
    //设置conn_fd为非阻塞模式
    result = set_non_blocking(conn_fd);
    if (result != 0)
    {
        mylog(0, "[ln_fd=%d][fd=%d] set_non_blocking() err: %d", ev->fd, conn_fd, result);
        return;
    }
    event_new(&g_events[i], conn_fd, callback_recv, &g_events[i]);
    event_add(EPOLLIN, &g_events[i]);
    return;
}

void callback_recv(void *arg)
{
    struct myevent_s *ev = (struct myevent_s *)arg;
    int len;
    int result;
    int i;
    int endflag;
    char buf[BUF_SIZE + 1];
    len = recv(ev->fd, buf, sizeof(buf), 0);
    event_del(ev);

    if (len > 0)
    {
        endflag = 0;
        for (i = 0; i < len - 1; i++)
        {
            if (buf[i] == '\r' && buf[i + 1] == '\n')
            {
                endflag = 1;
                break;
            }
        }
        if (endflag == 1) //开始写
        {
            event_new(ev, ev->fd, callback_send, ev);
            event_add(EPOLLOUT, ev);
        }
        else //继续读
        {
            event_new(ev, ev->fd, callback_recv, ev);
            event_add(EPOLLIN, ev);
        }
        // ev->len = len;
        // ev->buf[len] = '\0';
        // mylog(0, "[fd=%d][pos=%d] recv: %s", ev->fd, (int)(ev - g_events), ev->buf);
        // event_new(ev, ev->fd, callback_send, ev);
        // event_add(EPOLLOUT, ev);
    }
    else if (len == 0) //eof
    {
        mylog(0, "[fd=%d][pos=%d] closed", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
    }
    else
    {
        mylog(1, "[fd=%d][pos=%d] revc() err", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
    }
}
void callback_send(void *arg)
{
    char *resp = "HTTP/1.1 200 OK\nConnection: close\n\nhello\n";

    struct myevent_s *ev = (struct myevent_s *)arg;
    int len;
    int result;

    len = send(ev->fd, resp, strlen(resp), 0);
    event_del(ev);

    // if (len > 0)
    // {
    //     mylog(0, "[fd=%d][pos=%d] send: %s", ev->fd, (int)(ev - g_events), ev->buf);
    //     event_new(ev, ev->fd, callback_recv, ev);
    //     event_add(EPOLLIN, ev);
    // }
    if (len == strlen(resp)) //写完
    {
        mylog(0, "[fd=%d][pos=%d] send success", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
        else
        {
            mylog(0, "[fd=%d][pos=%d] close success", ev->fd, (int)(ev - g_events));
        }
    }
    else if (len > 0) //需要继续写
    {
        event_new(ev, ev->fd, callback_recv, ev);
        event_add(EPOLLOUT, ev);
    }
    else
    {
        mylog(1, "[fd=%d][pos=%d] send err", ev->fd, (int)(ev - g_events));
        result = close(ev->fd);
        if (result != 0)
        {
            mylog(1, "[fd=%d][pos=%d] close err", ev->fd, (int)(ev - g_events));
        }
        else
        {
            mylog(0, "[fd=%d][pos=%d] close success", ev->fd, (int)(ev - g_events));
        }
    }
}

int init_listen_socket()
{
    struct sockaddr_in server_addr, client_addr;
    int client_addr_len;
    int listen_fd;
    int result;
    int child_pid;

    //创建socket
    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_fd == -1)
    {
        mylog(1, "socket() err");
        return ERR_FAIL;
    }
    mylog(0, "[ln_fd=%d] listen", listen_fd);

    //设置listen_fd为非阻塞模式
    result = set_non_blocking(listen_fd);
    if (result != 0)
    {
        mylog(0, "set_non_blocking() err: %d", result);
        return ERR_FAIL;
    }

    event_new(&g_events[EPOLL_MAX_EVENTS], listen_fd, callback_accept, &g_events[EPOLL_MAX_EVENTS]);
    event_add(EPOLLIN, &g_events[EPOLL_MAX_EVENTS]);

    //设置监听的地址和端口
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_port = htons(SERVER_PORT);

    //复用端口
    int on = 1;
    result = setsockopt(listen_fd, SOL_SOCKET, SO_REUSEPORT, &on, sizeof(on));
    if (result == -1)
    {
        mylog(1, "setsockopt() err");
        return ERR_FAIL;
    }

    //bind
    result = bind(listen_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (result == -1)
    {
        mylog(1, "bind() err: %s");
        return ERR_FAIL;
    }

    //listen
    result = listen(listen_fd, BACKLOG);
    if (result == -1)
    {
        mylog(1, "listen() err: %s");
        return ERR_FAIL;
    }
    return 0;
}

int set_non_blocking(int fd)
{
    int opts;
    int result;
    opts = fcntl(fd, F_GETFL);
    if (opts == -1)
    {
        mylog(1, "fcntl() err");
        return ERR_FAIL;
    }
    opts |= O_NONBLOCK;
    result = fcntl(fd, F_SETFL, opts);
    if (result == -1)
    {
        mylog(1, "fcntl() err");
        return ERR_FAIL;
    }
    return 0;
}

void mylog(int errorflag, const char *fmt, ...)
{
    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);
    char buf[MAX_LINE + 1];
    strftime(buf, 23, "[%Y-%m-%d %H:%M:%S] ", tm_info); //[2021-09-05 11:55:37]
    buf[23] = '\0';
    printf("%s", buf);

    char buf2[MAX_LINE + 1];
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(buf2, MAX_LINE, fmt, ap);
    va_end(ap);
    buf2[n] = '\0';
    printf("%s", buf2);
    if (errorflag == 1)
    {
        printf(": %s", strerror(errno));
    }
    printf("\n");
}
```

### 参考文档的实现

```c
#include <stdlib.h>
#include <stdio.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/epoll.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#define MAX_EVENTS 1024
#define BUFLEN 128
#define SERV_PORT 8080

/*
 * status:1表示在监听事件中，0表示不在
 * last_active:记录最后一次响应时间,做超时处理
 */
struct myevent_s
{
    int fd;     //cfd listenfd
    int events; //EPOLLIN  EPLLOUT
    void *arg;  //指向自己结构体指针
    void (*call_back)(int fd, int events, void *arg);
    int status;
    char buf[BUFLEN];
    int len;
    long last_active;
};

int g_efd;                                 /* epoll_create返回的句柄 */
struct myevent_s g_events[MAX_EVENTS + 1]; /* +1 最后一个用于 listen fd */

void eventset(struct myevent_s *ev, int fd, void (*call_back)(int, int, void *), void *arg)
{
    ev->fd = fd;
    ev->call_back = call_back;
    ev->events = 0;
    ev->arg = arg;
    ev->status = 0;
    //memset(ev->buf, 0, sizeof(ev->buf));
    //ev->len = 0;
    ev->last_active = time(NULL);

    return;
}

void recvdata(int fd, int events, void *arg);
void senddata(int fd, int events, void *arg);

void eventadd(int efd, int events, struct myevent_s *ev)
{
    struct epoll_event epv = {0, {0}};
    int op;
    epv.data.ptr = ev;
    epv.events = ev->events = events;

    if (ev->status == 1)
    {
        op = EPOLL_CTL_MOD;
    }
    else
    {
        op = EPOLL_CTL_ADD;
        ev->status = 1;
    }

    if (epoll_ctl(efd, op, ev->fd, &epv) < 0)
        printf("event add failed [fd=%d], events[%d]\n", ev->fd, events);
    else
        printf("event add OK [fd=%d], op=%d, events[%0X]\n", ev->fd, op, events);

    return;
}

void eventdel(int efd, struct myevent_s *ev)
{
    struct epoll_event epv = {0, {0}};

    if (ev->status != 1)
        return;

    epv.data.ptr = ev;
    ev->status = 0;
    epoll_ctl(efd, EPOLL_CTL_DEL, ev->fd, &epv);

    return;
}

void acceptconn(int lfd, int events, void *arg)
{
    struct sockaddr_in cin;
    socklen_t len = sizeof(cin);
    int cfd, i;

    if ((cfd = accept(lfd, (struct sockaddr *)&cin, &len)) == -1)
    {
        if (errno != EAGAIN && errno != EINTR)
        {
            /* 暂时不做出错处理 */
        }
        printf("%s: accept, %s\n", __func__, strerror(errno));
        return;
    }

    do
    {
        for (i = 0; i < MAX_EVENTS; i++)
        {
            if (g_events[i].status == 0)
                break;
        }

        if (i == MAX_EVENTS)
        {
            printf("%s: max connect limit[%d]\n", __func__, MAX_EVENTS);
            break;
        }

        int flag = 0;
        if ((flag = fcntl(cfd, F_SETFL, O_NONBLOCK)) < 0)
        {
            printf("%s: fcntl nonblocking failed, %s\n", __func__, strerror(errno));
            break;
        }

        eventset(&g_events[i], cfd, recvdata, &g_events[i]);
        eventadd(g_efd, EPOLLIN, &g_events[i]);
    } while (0);

    printf("new connect [%s:%d][time:%ld], pos[%d]\n", inet_ntoa(cin.sin_addr), ntohs(cin.sin_port), g_events[i].last_active, i);

    return;
}

void recvdata(int fd, int events, void *arg)
{
    struct myevent_s *ev = (struct myevent_s *)arg;
    int len;

    len = recv(fd, ev->buf, sizeof(ev->buf), 0);
    eventdel(g_efd, ev);

    if (len > 0)
    {
        ev->len = len;
        ev->buf[len] = '\0';
        printf("C[%d]:%s\n", fd, ev->buf);
        /* 转换为发送事件 */
        eventset(ev, fd, senddata, ev);
        eventadd(g_efd, EPOLLOUT, ev);
    }
    else if (len == 0)
    {
        close(ev->fd);
        /* ev-g_events 地址相减得到偏移元素位置 */
        printf("[fd=%d] pos[%d], closed\n", fd, (int)(ev - g_events));
    }
    else
    {
        close(ev->fd);
        printf("recv[fd=%d] error[%d]:%s\n", fd, errno, strerror(errno));
    }

    return;
}

void senddata(int fd, int events, void *arg)
{
    struct myevent_s *ev = (struct myevent_s *)arg;
    int len;

    len = send(fd, ev->buf, ev->len, 0);
    //printf("fd=%d\tev->buf=%s\ttev->len=%d\n", fd, ev->buf, ev->len);
    //printf("send len = %d\n", len);

    eventdel(g_efd, ev);
    if (len > 0)
    {
        printf("send[fd=%d], [%d]%s\n", fd, len, ev->buf);
        eventset(ev, fd, recvdata, ev);
        eventadd(g_efd, EPOLLIN, ev);
    }
    else
    {
        close(ev->fd);
        printf("send[fd=%d] error %s\n", fd, strerror(errno));
    }

    return;
}

void initlistensocket(int efd, short port)
{
    int lfd = socket(AF_INET, SOCK_STREAM, 0);
    fcntl(lfd, F_SETFL, O_NONBLOCK);
    eventset(&g_events[MAX_EVENTS], lfd, acceptconn, &g_events[MAX_EVENTS]);
    eventadd(efd, EPOLLIN, &g_events[MAX_EVENTS]);

    struct sockaddr_in sin;

    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = INADDR_ANY;
    sin.sin_port = htons(port);

    bind(lfd, (struct sockaddr *)&sin, sizeof(sin));

    listen(lfd, 20);

    return;
}

int main(int argc, char *argv[])
{
    unsigned short port = SERV_PORT;

    if (argc == 2)
        port = atoi(argv[1]);

    g_efd = epoll_create(MAX_EVENTS + 1);

    if (g_efd <= 0)
        printf("create efd in %s err %s\n", __func__, strerror(errno));

    initlistensocket(g_efd, port);

    /* 事件循环 */
    struct epoll_event events[MAX_EVENTS + 1];

    printf("server running:port[%d]\n", port);
    int checkpos = 0, i;
    while (1)
    {
        /* 超时验证，每次测试100个链接，不测试listenfd 当客户端60秒内没有和服务器通信，则关闭此客户端链接 */
        long now = time(NULL);
        for (i = 0; i < 100; i++, checkpos++)
        {
            if (checkpos == MAX_EVENTS)
                checkpos = 0;
            if (g_events[checkpos].status != 1)
                continue;
            long duration = now - g_events[checkpos].last_active;
            if (duration >= 60)
            {
                close(g_events[checkpos].fd);
                printf("[fd=%d] timeout\n", g_events[checkpos].fd);
                eventdel(g_efd, &g_events[checkpos]);
            }
        }
        /* 等待事件发生 */
        int nfd = epoll_wait(g_efd, events, MAX_EVENTS + 1, 1000);
        if (nfd < 0)
        {
            printf("epoll_wait error, exit\n");
            break;
        }
        for (i = 0; i < nfd; i++)
        {
            struct myevent_s *ev = (struct myevent_s *)events[i].data.ptr;
            if ((events[i].events & EPOLLIN) && (ev->events & EPOLLIN))
            {
                ev->call_back(ev->fd, events[i].events, ev->arg);
            }
            if ((events[i].events & EPOLLOUT) && (ev->events & EPOLLOUT))
            {
                ev->call_back(ev->fd, events[i].events, ev->arg);
            }
        }
    }

    /* 退出前释放所有资源 */
    return 0;
}
```

## 参考

- [3.2 epoll的反应堆模式实现](https://aceld.gitbooks.io/libevent/content/32_epollde_fan_ying_dui_mo_shi_shi_xian.html)
