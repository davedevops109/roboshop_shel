source common.sh

echo -e "\e[35m configuring nodejs repos\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

echo -e "\e[35m Install nodejs repos\e[0m"
yum install nodejs -y &>>${LOG}
status_check

echo -e "\e[35m Add application user\e[0m"
useradd roboshop &>>${LOG}
status_check

mkdir -p /app &>>${LOG}
status_check

echo -e "\e[35m downloading app content\e[0m"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check

echo -e "\e[35m cleanup old content\e[0m"
rm -rf /app/* &>>${LOG}
status_check

echo -e "\e[35m extracting app content\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
status_check

echo -e "\e[35m installing nodejs dependencies\e[0m"
cd /app
npm install &>>${LOG}
status_check

echo -e "\e[35m configuring catalogue service\e[0m"
cp ${script_location}/file/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check

echo -e "\e[35m reload system \e[0m"
systemctl daemon-reload &>>${LOG}
status_check

echo -e "\e[35m enable catalogue service\e[0m"
systemctl enable catalogue &>>${LOG}
status_check

echo -e "\e[35m start catalogue service \e[0m"
systemctl start catalogue &>>${LOG}
status_check

echo -e "\e[35m configuring mongo repo\e[0m"
cp ${script_location}/file/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

echo -e "\e[35m install mongo client\e[0m"
yum install mongodb-org-shell -y &>>${LOG}
status_check

echo -e "\e[35m load schema\e[0m"
mongo --host mongodb-dev.davedevops.tech </app/schema/catalogue.js &>>${LOG}
status_check