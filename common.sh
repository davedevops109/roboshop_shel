script_location=$(pwd)
LOG=/tmp/roboshop.log

status_check() {
 if [ $? -eq 0 ]; then
   echo -e "\e[1;032msuccess\e[0m"
 else
   echo -e "\e[1;031mfailure\e[0m"
   echo "Refer log file for more information, LOG - ${LOG}"
   exit
 fi
}

print_head() {
  echo -e "\e[1m $1 \e[0m"
}

APP_PREREQ() {
  print_head "Add application user"
    id roboshop &>>${LOG}
    if [ $? -ne 0 ]; then
      useradd roboshop &>>${LOG}
    fi
    status_check

    mkdir -p /app &>>${LOG}

     print_head "downloading app content"
      curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
      status_check

      print_head "cleanup old content"
      rm -rf /app/* &>>${LOG}
      status_check

      print_head "extracting app content"
      cd /app
      unzip /tmp/${component}.zip &>>${LOG}
      status_check
}

SYSTEMD_SETUP() {
    print_head "configuring ${component} service"
    cp ${script_location}/file/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
    status_check

    print_head "reload system"
    systemctl daemon-reload &>>${LOG}
    status_check

    print_head "enable ${component} service"
    systemctl enable ${component} &>>${LOG}
    status_check

    print_head "start ${component} service"
    systemctl start ${component} &>>${LOG}
    status_check
}

LOAD_SCHEMA() {
    if [ ${schema_load} == "true" ]; then
      if [ ${schema_type} == "mongo" ]; then
    print_head "configuring mongo repo"
    cp ${script_location}/file/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
    status_check

    print_head "install mongo client"
    yum install mongodb-org-shell -y &>>${LOG}mongodb.sh
    status_check

    print_head "load schema"
    mongo --host mongodb-dev.davedevops.tech </app/schema/${component}.js &>>${LOG}
    status_check
    fi

    if [ ${schema_load} == "mysql" ]; then

       print_head "install mongo client"
       yum install mongodb-org-shell -y &>>${LOG}mongodb.sh
       status_check

       print_head "load schema"
       mysql -h mysql-dev.davedevops.tech -uroot -p${root_mysql_password} < /app/schema/shipping.sql
       status_check
     fi ];

    fi

}
NODEJS() {
  print_head "configuring nodejs repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  status_check

  print_head "Install nodejs repos"
  yum install nodejs -y &>>${LOG}
  status_check

  APP_PREREQ

  print_head "installing nodejs dependencies"
  cd /app &>>${LOG}
  npm install &>>${LOG}
  status_check

  SYSTEMD_SETUP

  LOAD_SCHEMA
}

MAVEN() {
  print_head "Install maven"
  yum install maven -y &>>${LOG}
  status_check

  APP_PREREQ

  print_head "Build a package"
  mvn clean package
  status_check

  print_head "copy app file to app location"
  mv target/${component}-1.0.jar {component}.jar
  status_check

  SYSTEMD_SETUP

  LOAD_SCHEMA
}