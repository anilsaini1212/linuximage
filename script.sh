#!/bin/sh -x

sudo yum install httpd
sudo systemctl enable httpd
sudo systemctl start httpd
