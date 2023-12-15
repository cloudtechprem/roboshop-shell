#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log" 

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 $R...FAILED $N" # $R - For Red Colour
    else
        echo -e "$2 $G...SUCCESS $N" # $G - For Green Colour
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: you are not a root user"
    exit 1
else
    echo -e "You are a root user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Installing Redis Repo is"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling Redis module is"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing Redis is"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "Remote access to Redis"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting redis"