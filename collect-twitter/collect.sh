#!/bin/sh
#cd /home/ec2-user/aichi1

today=`date +"20%y-%m-%d"`

sleep 10

start=`aws s3 ls geo-raw/$today/ | wc -l`

sleep 60

stop=`aws s3 ls geo-raw/$today/ | wc -l`

if [ $start -eq $stop ]; then
	pkill -f collect.py
	python aichi1/collect-twitter/collect.py
fi

