#!/bin/bash
echo "start provision: web"$1
sudo apt update
sudo apt install -y nginx
echo "<h1>machine: web"$1"</h1>" > /var/www/html/index.html
echo "provision web"$1" complete"