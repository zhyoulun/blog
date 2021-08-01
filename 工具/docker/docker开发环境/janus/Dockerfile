FROM ubuntu:18.04

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get clean
RUN apt-get update

RUN apt install -y net-tools \
    vim \
    wget \
    git \
    curl \
    telnet \
    cmake

RUN apt install -y aptitude

WORKDIR /root

# 基础依赖安装
RUN aptitude install -y libmicrohttpd-dev libjansson-dev \
	libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
	libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
	libconfig-dev pkg-config gengetopt libtool automake

# RUN aptitude install -y libsrtp-dev，安装的版本过低，需要手动安装，这里安装2.2.0版本
RUN wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz && tar -zxvf v2.2.0.tar.gz
RUN cd libsrtp-2.2.0 && ./configure --prefix=/usr --enable-openssl && make shared_library && make install
RUN cd /root

# usrsctp
RUN wget https://github.com/sctplab/usrsctp/archive/refs/tags/0.9.5.0.tar.gz && tar -zxvf 0.9.5.0.tar.gz
RUN cd usrsctp-0.9.5.0 && ./bootstrap && ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && make && make install
RUN cd /root

# libwebsockets
RUN wget https://github.com/warmcat/libwebsockets/archive/refs/tags/v4.2.1.tar.gz && tar -zxvf v4.2.1.tar.gz
RUN cd libwebsockets-4.2.1 && mkdir build && cd build && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && make && make install
RUN cd /root

# janus-gateway
RUN wget https://github.com/meetecho/janus-gateway/archive/refs/tags/v0.11.3.tar.gz && tar -zxvf v0.11.3.tar.gz

RUN cd /root

# ???
# RUN aptitude install -y libnice-dev，安装的版本过低，需要手动安装，这里安装2.2.0版本