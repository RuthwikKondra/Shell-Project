#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB Password:"
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

dnf install mysql-server -y &>>LOGFILE
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "Enabling MYSQL SERVER"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "Starting MYSQL-Server."
 
#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

mysql -h mysql-server -uroot -p${mysql_root_password} -e 'show databases;' &>>LOGFILE
if [ $? -ne 0 ]
then
    mysql secure installation --set-root-pass ${mysql_root_password} &>>LOGFILE&
else
    echo "MySQK Root password is already setup ...$Y SKIPPING $N" &>>LOGFILE
fi 






