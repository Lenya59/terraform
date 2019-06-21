#! /bin/bash
sudo yum update
sudo yum install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Welcome to DevOps_ITA_demo</h1>" | sudo tee /var/www/html/index.html
