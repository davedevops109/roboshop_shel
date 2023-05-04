source common.sh

component=payment
schema_load=false

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "variable root_mysql_password is missing"
  exit
fi

PYTHON