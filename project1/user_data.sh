#!/bin/bash

sudo apt-get update -y

sudo apt-get install apache2 -y

sudo systemctl start apache2

sudo systemctl enable apache2



# Create a custom landing page

HOSTNAME=$(hostname)

echo "<html><head><title>Project 1</title></head><body>" > /var/www/html/index.html

echo "<h1>Project 1: Web Server Deployed via Terraform</h1>" >> /var/www/html/index.html

echo "<p>Welcome to your first infrastructure as code deployment.</p>" >> /var/www/html/index.html

echo "<p>Server Hostname: $HOSTNAME</p></body></html>" >> /var/www/html/index.html
