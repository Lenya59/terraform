#!/bin/bash
sudo su-
yum update -y
yum install httpd -y
myip =`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>ITA DevOps</h2><br>"  >>  /var/www/html/index.html
service httpd start
chkconfig httpd on
