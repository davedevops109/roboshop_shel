source common.sh

print_head "setup redis file"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${LOG}
status_check

print_head "Enable redis 6.2 dnf module"
dnf module enable redis:remi-6.2 -y &>>${LOG}
status_check

print_head "Install redis"
yum install redis -y &>>${LOG}
status_check

print_head "update redis listen address"
sed -i -e 's/127.0.0.1/0.0.0.0' /etc/redis.conf &>>${LOG}
status_check

print_head "Enable redis"
systemctl enable redis &>>${LOG}
status_check

print_head "start redis"
systemctl start redis &>>${LOG}
status_check