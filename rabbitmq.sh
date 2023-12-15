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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Installing erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Installing rabbitMQ script"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "Enabling RabbitMQ"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "Starting RabbitMQ"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "creating roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "Giving the Permissions to the roboshop user"
