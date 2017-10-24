#!/bin/sh
#cd /home/ec2-user/aichi1
ps aux | grep [c]ollect.py > /dev/null
if [ $? -eq 0 ]; then
  echo "Process is running."
else
  python aichi1/collect-twitter/collect.py
fi
