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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS"

useradd roboshop &>> $LOGFILE
VALIDATE $? "creating Roboshop user"

mkdir /app &>> $LOGFILE
VALIDATE $? "creating App directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

cd /app &>> $LOGFILE
VALIDATE $? "Download the Application Code"

unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart.zip"

cd /app &>> $LOGFILE
VALIDATE $? "Change Directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying and creating user.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling the cart.service"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting the cart.service"