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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing maven"

useradd roboshop &>> $LOGFILE
VALIDATE $? "creating Roboshop user"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating App directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

cd /app &>> $LOGFILE
VALIDATE $? "Download the Application Code"

unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping.zip"

cd /app &>> $LOGFILE
VALIDATE $? "Change Directory"

mvn clean package &>> $LOGFILE
VALIDATE $? "Downloading the dependecies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying and creating user.service"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Renaming the shipping-1.jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying and creating mongodb repo"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling the shipping.service"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting the shipping.service"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL client"

mysql -h mysql.learndevops.space -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE $? "Loading schema"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping.service"

echo -e "$G COMPLETED"