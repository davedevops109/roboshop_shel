source common.sh

print_head "Install Nginx"
yum install nginx -y &>>${LOG}
status_check

print_head "Remove nginx old content"
rm -rf /usr/share/nginx/html/* &>>${LOG}
status_check

print_head "download frontend content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${LOG}
status_check

cd /usr/share/nginx/html &>>${LOG}

print_head "extract frontend content"
unzip /tmp/frontend.zip &>>${LOG}
status_check

print_head "copy roboshop nginx config file"
cp ${script_location}/file/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}
status_check

print_head "Enable Nginx"
systemctl enable nginx &>>${LOG}
status_check

print_head "start Nginx"
systemctl start nginx &>>${LOG}
status_check