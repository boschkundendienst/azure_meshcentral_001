#!/bin/bash

configfile='GLOBAL_CONFIG.conf' # only filename, no paths!
if [ ! -f "./$configfile" ]; then
    echo "./$configfile does not exist - ending."
    exit
fi

playbook='./PLAYBOOK.yml'

# source the configuration file
source "./$configfile"

# check if all variables are set
echo '----------------------------------------------------------------------------'
echo 'Your preferences'
echo '----------------------------------------------------------------------------'
echo "title              :"
echo "adminuser          : $adminuser" # make sure to write it down!
echo "adminpass          : $adminpass" # make sure to write it down!
echo "adminmail          : $adminemail"
echo "adminname          : $adminname"
echo "fqdn               : $fqdn"
echo "le_email           : $le_email # domain part must be valid or LE will fail"
echo "le_names           : $le_names"
echo "le_keysize         : $le_keysize"
echo "le_prod            : $le_prod"
echo ""
echo "SSH Login with     : ssh $ADMIN_USERNAME@IP_ADDRESS
echo '----------------------------------------------------------------------------'

# wait for user to press enter
read -s -p "Press enter to continue or Ctrl+C to stop here"
echo -e "\nStarting deployment phase 2 using ansible on the remote host"

ansible-playbook -v -i $IP_ADDRESS,  -b -u $ADMIN_USERNAME "$playbook"

# show final message
echo "If everything went fine you should be able to reach your Meshcentral instance at"
echo ""
echo " https://$fqdn"
echo ""
echo "It can take some minutes until the LE certificates are created."
echo "SSH Login should be possible with:
echo ""
echo "ssh $ADMIN_USERNAME@IP_ADDRESS"
