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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disabling MySQL module"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copying MySQL repo is"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enable MySQL"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Creating MySQL root user and password"
