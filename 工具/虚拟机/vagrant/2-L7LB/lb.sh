#!/bin/bash
echo "start provision: lb1"
sudo apt update
sudo apt install -y nginx
sudo service nginx stop
sudo rm -rf /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-enabled/default
echo "upstream testapp {
    server 192.168.56.131;
    server 192.168.56.132;
}
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html index.htm;
    location / {
        proxy_pass http://testapp;
    }
}
" >> /etc/nginx/sites-enabled/default
sudo service nginx start
echo "Machine: lb1" > /var/www/html/index.html
echo "provision lb1 complete"