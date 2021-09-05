一个最简单的epoll例子，但是非常不完整

```c
#include <sys/socket.h> //socket(),bind(),listen(),accept() in it
#include <netinet/in.h> //struct sockaddr_in, htonl(), htons() in it

#include <string.h>  //strerror() in it
#include <strings.h> //bzero() in it
#include <errno.h>   //errno in it

#include <unistd.h>   //fork(),close(),read(),write() in it
#include <stdlib.h>   //exit() in it
#include <sys/wait.h> //wait() in it

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

void handle_conn(int);
int http_hello(int);
int do_epoll(int);
int set_non_blocking(int);
int http_hello_read(int);
int http_hello_write(int);

int main(int argc, char **argv)
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
        printf("socket() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }

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
        printf("setsockopt() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }

    //bind
    result = bind(listen_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (result == -1)
    {
        printf("bind() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }

    //listen
    result = listen(listen_fd, BACKLOG);
    if (result == -1)
    {
        printf("listen() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }

    result = do_epoll(listen_fd);
    return result;
}

int do_epoll(int listen_fd)
{
    int epoll_fd;
    int conn_fd;
    struct epoll_event ev;
    struct epoll_event events[EPOLL_MAX_EVENTS];
    int result;
    int num_fds;
    int i;
    struct sockaddr_in client_addr;
    int client_addr_len;

    /*
    epoll_create
    自从Linux 2.6.8, size参数就被忽略了，但是必须大于0
    */
    epoll_fd = epoll_create(1);
    if (epoll_fd == -1)
    {
        printf("epoll_create() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }

    /*
    epoll_ctl
    函数声明：int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);

    op参数可选值：
        EPOLL_CTL_ADD
        EPOLL_CTL_MOD
        EPOLL_CTL_DEL

    event参数定义：
    typedef union epoll_data {
        void        *ptr;
        int          fd;
        uint32_t     u32;
        uint64_t     u64;
    } epoll_data_t;
    struct epoll_event {
        uint32_t     events; //Epoll events
        epoll_data_t data;   //User data variable
    };
    data成员: 当fd准备好的时候，epoll_wait返回，返回值会返回data成员
    event成员可选值：
        EPOLLIN：关联的文件可read()
        EPOLLOUT：关联的文件可write()
        EPOLLRDHUP
        EPOLLPRI
        EPOLLERR
        EPOLLHUP
        EPOLLET：边缘触发，edge-triggered，默认为水平触发，level-triggered
        EPOLLONESHOT
        EPOLLWAKEUP
        EPOLLEXCLUSIVE
    */
    ev.events = EPOLLIN;
    ev.data.fd = listen_fd;
    result = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, listen_fd, &ev);
    if (result == -1)
    {
        printf("epoll_ctl() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }

    for (;;)
    {
        //epoll_wait，返回值是可读的fd数量
        num_fds = epoll_wait(epoll_fd, events, EPOLL_MAX_EVENTS, -1);
        if (num_fds == -1)
        {
            printf("epoll_wait() err: %s\n", strerror(errno));
            return ERR_FAIL;
        }
        printf("epoll_wait result, num_fds: %d\n", num_fds);
        for (i = 0; i < num_fds; i++)
        {
            if (events[i].data.fd == listen_fd)
            {
                printf("[active]listen fd\n");
                client_addr_len = sizeof(client_addr);
                conn_fd = accept(listen_fd, (struct sockaddr *)&client_addr, &client_addr_len);
                if (conn_fd == -1)
                {
                    printf("accept() err: %s\n", strerror(errno));
                    return ERR_FAIL;
                }
                result = set_non_blocking(conn_fd);
                if (result != 0)
                {
                    printf("set_non_blocking() err: %d\n", result);
                    return ERR_FAIL;
                }
                ev.events = EPOLLIN | EPOLLET;
                ev.data.fd = conn_fd;
                result = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, conn_fd, &ev);
                if (result == -1)
                {
                    printf("epoll_ctl() err: %d\n", result);
                    return ERR_FAIL;
                }
            }
            else
            {
                handle_conn(events[i].data.fd);
            }
        }
    }
    return 0;
}

void handle_conn(int conn_fd)
{
    int result;
    result = http_hello(conn_fd);
    if (result != 0)
    {
        printf("http_hello() err: %d\n", result);
    }
    result = close(conn_fd);
    if (result != 0)
    {
        printf("close() err: %d\n", result);
    }
}

int http_hello(int conn_fd)
{
    char buf[MAX_LINE + 1];
    char *resp = "HTTP/1.1 200 OK\nConnection: close\n\nhello\n";
    char resp_len = strlen(resp);
    int total;
    int left;
    int n;
    int result;
    int i;
    int last = 0;
    while (1)
    {
        total = read(conn_fd, buf, MAX_LINE);
        if (total == -1)
        {
            printf("read() err: %s\n", strerror(errno));
            return ERR_FAIL;
        }
        else if (total == 0)
        { //eof
            printf("read eof\n");
            return 0;
        }
        else
        {
            //log
            buf[total] = '\0';
            printf("receive length: [%d], content: [%s], ascii: [", total, buf);
            for (i = 0; i < total; i++)
            {
                printf("%d, ", buf[i]);
            }
            printf("]\n");

            for (i = 0; i < total - 1; i++)
            {
                if (last == 1)
                {
                    if (buf[i] == '\r' && buf[i + 1] == '\n')
                    {
                        //end of http request
                        goto WRITE;
                    }
                    else
                    {
                        last = 0;
                    }
                }
                else
                {
                    if (buf[i] == '\r' && buf[i + 1] == '\n')
                    {
                        i++;
                        last = 1;
                    }
                    else
                    {
                        last = 0;
                    }
                }
            }
        }
    }
WRITE:
    //write
    left = resp_len;
    while (left > 0)
    {
        n = write(conn_fd, resp + (resp_len - left), left);
        if (n == -1)
        {
            printf("write() err: %s\n", strerror(errno));
            return ERR_FAIL;
        }
        else
        {
            left -= n;
        }
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
        printf("fcntl() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }
    opts |= O_NONBLOCK;
    result = fcntl(fd, F_SETFL, opts);
    if (result == -1)
    {
        printf("fcntl() err: %s\n", strerror(errno));
        return ERR_FAIL;
    }
    return 0;
}
```
