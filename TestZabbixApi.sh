#!/bin/bash
#This is a shell test for ZABBIX api user get and delete by amin alizadeh @ 20220306
#contact : aminaminem@gmail.com
#the main idea is connect via API to ZABBIX frontend for user get or delete
#
#Require repositories:
#jq - commandline JSON processor 
#grep
#sed

#This part is about current script some info/note
echo
echo
echo "********************************"
echo "*ZABBIX User show/delete script*"
echo "********************************"
echo
echo "Note:"
echo "This method is only available to "
echo "Super admin user type. Permissions"
echo "to call the method can be revoked"
echo "in user role settings"
echo
echo
echo


#This part is first user interactive data get
#user must know about ZABBIX frontend URL and ZABBIX superadmin token
echo "at first need zabbix server access"
read -p "Enter ZABBIX API URL(http...php) :" ZABBIX_URL
read -p "Enter ZABBIX API Token :" ZABBIX_TOKEN
echo
echo


#This part is a semi menu about show or delete selection part
echo "you can check active user or just delete one user"
echo "[1] show all username"
echo "[2] delete specific username"
read -p "Choose one number (anything else to exit):" QUESTION_SELECT
echo


#This part is responsible for get users inos
#just a normal JASON format get and cut it use some shell tools/app to human readable and clean version
if [ $QUESTION_SELECT -eq 1 ];
then
echo "Current active user in this server :"
curl -i -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"user.get","params":{"output":"extend"},"auth":"'$ZABBIX_TOKEN'","id":1}' $ZABBIX_URL 2>&1 | grep result | jq '.' | grep username | sed 's/.*: "//' | sed 's/".*//'
echo
echo
echo "Thank you and goodbye"
echo
exit
#This part is responsible for delete specific user
elif [ $QUESTION_SELECT -eq 2 ];
then
#At first user must specify the user
read -p "Enter the user to delete :" USER_NAME
#one JASON query extract user.ID from selected user.name
USER_ID=( $(curl -i -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"user.get","params":{"output":"extend"},"auth":"'$ZABBIX_TOKEN'","id":1}' $ZABBIX_URL 2>&1 | grep result | jq  | jq '.result | map(select(.username == "'$USER_NAME'"))[0].userid' | sed 's/"//'  | sed 's/"//') )
#one JASON command set delete parameter for specified user.ID
curl -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"user.delete","params": ["'$USER_ID'"],"auth":"'$ZABBIX_TOKEN'","id":1}' $ZABBIX_URL
echo
echo
echo "User deleted"
echo "Thank you and goodbye"
echo
exit
else
echo
echo "you must choose only between shown itmes"
echo "Thank you and goodbye"
echo
exit
fi
