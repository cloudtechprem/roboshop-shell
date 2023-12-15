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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing Python"

useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding roboshop user"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading the Payment.zip"

cd /app &>> $LOGFILE
VALIDATE $? "changing the directory"

unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping payment.zip contents"

cd /app &>> $LOGFILE
VALIDATE $? "changing the directory"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Downloading dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "creating payment.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon realod"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling payment.service"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting payment.service"
