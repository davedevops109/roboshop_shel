source common.sh

if [ -z "${root_mysql_password}" ]; then
  echo "variable root_mysql_password is missing"
  exit
fi

print_head "disable mysql default module"
dnf module disable mysql -y
status_check

print_head "copy mysql repo file"
cp ${script_location}/file/mysql.repo /etc/yum.repos.d/mysql.repo &>>${LOG}
status_check

print_head "Install mysql"
yum install mysql-community-server -y &>>${LOG}
status_check

print_head "Install mongodb"
systemctl enable mongod &>>${LOG}
status_check

print_head "Install mongodb"
systemctl restart mongod &>>${LOG}
status_check

print_head "Reset database password"
mysql_secure_installation --set-root-pass RoboShop@1
status_check