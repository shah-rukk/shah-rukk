#The purpose of this script is to check error lines from different log file
#    and error count and send it on email.


#!/bin/bash

#Step1. Create log file to redirect all error details to single file.

log_date=`date +%d-%h-%y,%H:%M:%S`;
error_log_file=/home/ec2-user/.monitoring/error_log/error_log_$log_date.log;
touch $error_log_file;
exec >> $error_log_file;
exec 2>> $error_log_file;

#step2. read all log files one by one in loop

input="/home/ec2-user/.monitoring/script_list.txt" 
#above is list of location of all log files
while IFS= read -r line
do

printf "\n"
log_file=`ls -lrt $line | tail -1 | awk '{print $9}'`;
echo "*********** log file Errors for $log_file****************"
printf "\n"

printf "\n"
grep -v -e "Error converting" -e "Error parsing" $line/$log_file -e "Could not rename" -e "impala_shell.py"| grep -i 'error';
printf "\n error count is "
grep -i error $line/$log_file | wc -l

done < "$input"

#################################################
printf "\n"
printf "****** End Of Mail *********"
printf "\n"

mail_log_file=`ls -lrt /home/ec2-user/.monitoring/error_log  | tail -1 | awk '{print $9}'`;

mail_dl="shahrukh.khan@abc.com"

mailx -S ssl-verify=ignore -S smtp=smtp://10.250.1.58:25  -s "***Error Check***" -r pulse-monitoring-team@abc.com $mail_dl < /home/ec2-user/.monitoring/error_log/$mail_log_file
