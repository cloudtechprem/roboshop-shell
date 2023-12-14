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

dnf module disable nodejs -y $>> $LOGFILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:18 -y $>> $LOGFILE
VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y $>> $LOGFILE
VALIDATE $? "Installing NodeJS"

useradd roboshop $>> $LOGFILE
VALIDATE $? "creating Roboshop user"

mkdir /app $>> $LOGFILE
VALIDATE $? "creating App directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip $>> $LOGFILE
VALIDATE $? "Download the Application Code"

cd /app $>> $LOGFILE
VALIDATE $? "Download the Application Code"

unzip /tmp/catalogue.zip $>> $LOGFILE
VALIDATE $? "Unzipping catalogue.zip"

cd /app $>> $LOGFILE
VALIDATE $? "Change Directory"

npm install $>> $LOGFILE
VALIDATE $? "Download the Application Code"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service $>> $LOGFILE
VALIDATE $? "Copying and creating catalogue.service"

systemctl daemon-reload $>> $LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable catalogue $>> $LOGFILE
VALIDATE $? "Enabling the catalogue.service"

systemctl start catalogue $>> $LOGFILE
VALIDATE $? "Starting the catalogue.service"

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo $>> $LOGFILE
VALIDATE $? "Copying and creating mongodb repo"

dnf install mongodb-org-shell -y $>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.learndevops.space </app/schema/catalogue.js $>> $LOGFILE
VALIDATE $? "Loading catalogue data into MongoDB"