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