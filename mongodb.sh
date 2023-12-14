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

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongodb.repo $>> $LOGFILE
VALIDATE $? "Copying MongoDB repo is"

dnf install mongodb-org -y $>> $LOGFILE
VALIDATE $? "Installing MongoDB is"

systemctl enable mongod $>> $LOGFILE
VALIDATE $? "Enabling MongoDb is"

systemctl start mongod $>> $LOGFILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf $>> $LOGFILE
VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod $>> $LOGFILE
VALIDATE $? "Restarting MongoDB"