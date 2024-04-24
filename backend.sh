#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB password:"
read -s mysql_root_password

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}


if [ $USERID -ne 0 ]
then 
    echo "Please run the script with root user."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi
 
dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabiling default nodejs."

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabiling nodejs:20."

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Starting nodejs:20"

id expense
if [ $? -ne 0 ]
then 
   useradd expense
   VALIDATE $? "Creating expense user"
else
   echo -e "Expense user already created....$Y SKIPPING $N"
fi 

mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Dowloading Backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>LOGFILE
VALIDATE $? "Installing nodejs dependences"

#check your repo and path
cp /home/ec2-user/Shell-Project/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"


systemctl daemon-reload &>>LOGFILE
VALIDATE $? "Daemon reload"

systemctl start backend &>>LOGFILE
VALIDATE $? "Starting Backend"

systemctl enable  backend &>>LOGFILE
VALIDATE $? "Enabiling backend"

dnf install mysql -y &>LOGFILE
VALIDATE $? "installing mysql"

mysql -h 172.31.87.172 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>LOGFILE
VALIDATE $? "Restarting Backend"
