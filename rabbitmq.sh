source common.sh

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "variable root_mysql_password is missing"
  exit
fi

print_head "configuring erlang yum repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${LOG}
status_check

print_head "configuring rabbitmq yum repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${LOG}
status_check

print_head "install erlang rabbitmq"
yum install erlang rabbitmq-server -y &>>${LOG}
status_check

print_head "enable rabbitmq server"
systemctl enable rabbitmq-server &>>${LOG}
status_check

print_head "start rabbitmq server"
systemctl start rabbitmq-server &>>${LOG}
status_check

print_head "adding roboshop add_user"
rabbitmqctl list_users | grep roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop ${roboshop_rabbitmq_password} &>>${LOG}
fi
status_check

print_head "set user for roboshop administrator"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG}
status_check

print_head "adding set_permissions"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
status_check