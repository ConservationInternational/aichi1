#!/bin/bash

#Make sure to:
# 1) Name this file `backup.sh` and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region)
# 4) Fill in DB host + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run chmod +x backup.sh
# 7) Test it out via ./backup.sh
# 8) Set up a daily backup at midnight via `crontab -e`:
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log

# DB host (secondary preferred as to avoid impacting primary performance)
HOST=localhost

# DB name
DBNAME=TWITTER

# S3 bucket name
BUCKET=aichi-mongo-backups

# Linux user account
USER=ec2-user

# Current time
TIME=`/bin/date -u +"%Y-%m-%dT%H%M%SZ"`

# Backup directory
DEST=/home/$USER/tmp

# Tar file of backup directory
TAR=$DEST/../$TIME.tar

# Create backup dir (-p to avoid warning if already exists)
/bin/mkdir -p $DEST

# Log
#echo "Backing up $HOST/$DBNAME to s3://$BUCKET/ on $TIME";

# Dump from mongodb host into backup directory
/usr/bin/mongodump -h $HOST -d $DBNAME -o $DEST --quiet

# Create tar of backup directory
/bin/tar cf $TAR -C $DEST . 

# Upload tar to s3
/usr/bin/aws s3 cp $TAR s3://$BUCKET/ --quiet

# Remove tar file locally
/bin/rm -f $TAR

# Remove backup directory
/bin/rm -rf $DEST

# All done
#echo "Backup available at https://s3.amazonaws.com/$BUCKET/$TIME.tar"

#TO RESTORE
# wget -O backup.tar https://s3.amazonaws.com/my-bucket/xx-xx-xxxx-xx:xx:xx.tar
# tar xvf backup.tar
# mongorestore --host {db.example.com} --db {my-db} {db-name}/

#Source: https://gist.github.com/eladnava/96bd9771cd2e01fb4427230563991c8d
