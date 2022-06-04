
### 对比

- ET模式下事件被触发的次数比LT模式下少很多
- 使用ET的注意事项
  - ET模式下的文件描述符都应该是非阻塞的，如果文件描述符是非阻塞的，那么读写操作将会因为没有后续的事件而一直处于阻塞状态（即刻状态）

### 运行


LT

```
./a.out 127.0.0.1 12345
event trigger once
get 9 bytes of content: abcdeabcd
event trigger once
get 8 bytes of content: eabcde
```

ET

```
./a.out 127.0.0.1 12345
event trigger once
get 9 bytes of content: abcdeabcd
get 8 bytes of content: eabcde
```

### 代码

```c
#include <sys/socket.h> //socket(),bind(),listen(),accept() in it
#include <netinet/in.h> //struct sockaddr_in, htonl(), htons() in it
#include <arpa/inet.h>  //inet_pton() in it

#include <string.h>  //strerror() in it
#include <strings.h> //bzero() in it
#include <errno.h>   //errno in it
#include <assert.h>  //assert() in it

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

#include <libgen.h> //basename() in it

#include <stdio.h>

#define MAX_EVENT_NUMBER 1024
#define BUFFER_SIZE 10
#define ERR_FAIL 1

int set_non_blocking(int);
void addfd(int epollfd, int fd, int enable_et);
void lt(struct epoll_event *events, int number, int epollfd, int listenfd);
void et(struct epoll_event *events, int number, int epollfd, int listenfd);

int main(int argc, char *argv[])
{
    if (argc <= 2)
    {
        printf("usage: %s ip_address port_number\n", basename(argv[0]));
        return 1;
    }

    const char *ip = argv[1];
    int port = atoi(argv[2]);

    int ret = 0;
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_family = AF_INET;
    inet_pton(AF_INET, ip, &address.sin_addr);
    address.sin_port = htons(port);

    int listenfd = socket(PF_INET, SOCK_STREAM, 0);
    assert(listenfd >= 0);
    ret = bind(listenfd, (struct sockaddr *)&address, sizeof(address));
    assert(ret != -1);
    ret = listen(listenfd, 5);
    assert(ret != -1);

    struct epoll_event events[MAX_EVENT_NUMBER];
    int epollfd = epoll_create(5);
    assert(epollfd != -1);
    addfd(epollfd, listenfd, 1);

    while (1)
    {
        int ret = epoll_wait(epollfd, events, MAX_EVENT_NUMBER, -1);
        if (ret < 0)
        {
            printf("epoll fail\n");
            break;
        }
        // lt(events, ret, epollfd, listenfd);
        et(events, ret, epollfd, listenfd);
    }

    close(listenfd);
    return 0;
}

void lt(struct epoll_event *events, int number, int epollfd, int listenfd)
{
    char buf[BUFFER_SIZE];
    for (int i = 0; i < number; i++)
    {
        int sockfd = events[i].data.fd;
        if (sockfd == listenfd)
        {
            struct sockaddr_in client_address;
            socklen_t client_addrlength = sizeof(client_address);
            int connfd = accept(listenfd, (struct sockaddr *)&client_address, &client_addrlength);
            addfd(epollfd, connfd, 0);
        }
        else if (events[i].events & EPOLLIN)
        {
            printf("event trigger once\n");
            memset(buf, '\0', BUFFER_SIZE);
            int ret = recv(sockfd, buf, BUFFER_SIZE - 1, 0);
            if (ret <= 0)
            {
                close(sockfd);
                continue;
            }
            printf("get %d bytes of content: %s\n", ret, buf);
        }
        else
        {
            printf("something else happen\n");
        }
    }
}

void et(struct epoll_event *events, int number, int epollfd, int listenfd)
{
    char buf[BUFFER_SIZE];
    for (int i = 0; i < number; i++)
    {
        int sockfd = events[i].data.fd;
        if (sockfd == listenfd)
        {
            struct sockaddr_in client_address;
            socklen_t client_addrlength = sizeof(client_address);
            int connfd = accept(listenfd, (struct sockaddr *)&client_address, &client_addrlength);
            addfd(epollfd, connfd, 1);
        }
        else if (events[i].events & EPOLLIN)
        {
            //对于ET模式，这段代码不会被重复触发，所以需要循环读取数据，以确保socket读缓存中的所有数据全部读出
            printf("event trigger once\n");
            while (1)
            {
                memset(buf, '\0', BUFFER_SIZE);
                int ret = recv(sockfd, buf, BUFFER_SIZE - 1, 0);
                if (ret < 0)
                {
                    //对于非阻塞IO，下面的条件成立表示数据已经全部读取完毕。此后，epoll就能再次触发sockfd上的EPOLLIN事件，以驱动下一次读操作
                    if (errno == EAGAIN || errno == EWOULDBLOCK)
                    {
                        printf("read later\n");
                        break;
                    }
                    close(sockfd);
                    break;
                }
                else if (ret == 0)
                {
                    close(sockfd);
                }
                else
                {
                    printf("get %d bytes of content: %s\n", ret, buf);
                }
            }
        }
        else
        {
            printf("something else happen\n");
        }
    }
}

void addfd(int epollfd, int fd, int enable_et)
{
    struct epoll_event event;
    event.data.fd = fd;
    event.events = EPOLLIN;
    if (enable_et)
    {
        event.events |= EPOLLET;
    }
    epoll_ctl(epollfd, EPOLL_CTL_ADD, fd, &event);
    set_non_blocking(fd);
}

void mylog(int errorflag, const char *fmt, ...)
{
    #define MAX_LINE 1024
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
```

## 参考
