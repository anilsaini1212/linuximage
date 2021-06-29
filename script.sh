#!/bin/sh -x

sudo yum install httpd* -y 
sudo systemctl enable httpd
sudo systemctl start httpd
