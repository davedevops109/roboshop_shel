source common.sh

print_head -e "configuring nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

print_head "Install nodejs repos"
yum install nodejs -y &>>${LOG}
status_check

print_head -e "Add application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
fi
status_check

mkdir -p /app &>>${LOG}
status_check

print_head " downloading app content"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check

print_head " cleanup old content"
rm -rf /app/* &>>${LOG}
status_check

print_head " extracting app content"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
status_check

print_head " installing nodejs dependencies"
cd /app
npm install &>>${LOG}
status_check

print_head " configuring catalogue service"
cp ${script_location}/file/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check

print_head " reload system "
systemctl daemon-reload &>>${LOG}
status_check

print_head " enable catalogue service"
systemctl enable catalogue &>>${LOG}
status_check

print_head " start catalogue service "
systemctl start catalogue &>>${LOG}
status_check

print_head " configuring mongo repo"
cp ${script_location}/file/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

print_head " install mongo client"
yum install mongodb-org-shell -y &>>${LOG}
status_check

print_head " load schema"
mongo --host mongodb-dev.davedevops.tech </app/schema/catalogue.js &>>${LOG}
status_check