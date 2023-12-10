#!/bin/bash

# 避免出现报错dpkg-preconfigure: unable to re-open stdin: No such file or directory
# https://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory
export DEBIAN_FRONTEND=noninteractive

sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
apt-get update

apt-get install -y net-tools \
    iproute2 \
    dnsutils \
    iputils-ping \
    bridge-utils \
    curl wget tcpdump telnet lsof \
    ipvsadm

apt-get install -y \
    vim \
    git \
    nginx

echo `hostname` > /var/www/html/index.html
