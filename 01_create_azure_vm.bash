#!/bin/bash
#set -x

# check if command 'az' is present
echo "if nothing happens after you see this text, the command 'az' is missing"
command -v az &>/dev/null || exit

configfile='GLOBAL_CONFIG.conf' # only filename, no paths!
if [ ! -f "./$configfile" ]; then
    echo "./$configfile does not exist - ending."
    exit
fi
# source the configuration file
source "./$configfile"

# check if all variables are set
echo '----------------------------------------------------------------------'
echo 'Your preferences'
echo '----------------------------------------------------------------------'
echo "RESOURCE_GROUP_NAME: $RESOURCE_GROUP_NAME"
echo "LOCATION           : $LOCATION"
echo "VM_IMAGE           : $VM_IMAGE"
echo "VM_NAME            : $VM_NAME"
echo "VM_SIZE            : $VM_SIZE"
echo "ADMIN_USERNAME     : $ADMIN_USERNAME"
echo "DNS_HOSTNAME |     : $DNS_HOSTNAME"
echo "DNS_ZONE     |     : $DNS_ZONE"
echo "              \--> : $DNS_HOSTNAME.$DNS_ZONE"
echo '----------------------------------------------------------------------'

# wait for user to press enter
read -s -p "Press enter to continue or Ctrl+C to stop here"
echo -e "\nStarting deployment"

# create resource group
echo "command: az group create --name $RESOURCE_GROUP_NAME --location $LOCATION"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# create virtual machine
echo "command: az vm create --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --image $VM_IMAGE --admin-username $ADMIN_USERNAME --generate-ssh-keys --public-ip-sku 'Standard' --size $VM_SIZE --verbose"
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VM_NAME \
  --image $VM_IMAGE \
  --admin-username $ADMIN_USERNAME \
  --generate-ssh-keys \
  --public-ip-sku 'Standard'  \
  --size $VM_SIZE \
  --verbose

# get public ip and store it as $IP_ADDRESS
export IP_ADDRESS=$(az vm show --show-details --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --query publicIps --output tsv)
echo "IP_ADDRESS         : $IP_ADDRESS"
# update IP_ADDRESS to config file
sed -i "s@^.*IP_ADDRESS.*@export IP_ADDRESS='$IP_ADDRESS' # do not edit manually@g" $configfile

# get resourcename of public IP resource
export IP_NAME=$(az network public-ip list --resource-group $RESOURCE_GROUP_NAME | jq -r '.[].name')
echo "IP_NAME            : $IP_NAME"

# add configured DNS_HOSTNAME to IP resource
az network public-ip update --dns-name $DNS_HOSTNAME --resource-group $RESOURCE_GROUP_NAME -n $IP_NAME
# output DNS name
echo "command: az network public-ip list --resource-group $RESOURCE_GROUP_NAME | jq -r '.[].dnsSettings.fqdn'"
az network public-ip list --resource-group $RESOURCE_GROUP_NAME | jq -r '.[].dnsSettings.fqdn'
echo "DNS_HOSTNAME (azure): $(az network public-ip list --resource-group $RESOURCE_GROUP_NAME | jq -r '.[].dnsSettings.fqdn')"

# open port 80 and 443 in firewall
export PORT=443
echo "command: az vm open-port --port $PORT --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --priority 100"
az vm open-port --port $PORT --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --priority 100
export PORT=80
echo "command: az vm open-port --port $PORT --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --priority 101"
az vm open-port --port $PORT --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --priority 101

# show final output
echo "You can now login to your vm using ssh ${ADMIN_USERNAME}@${IP_ADDRESS} using ssh keys only."
echo "If you want to delete the entire resource group $RESOURCE_GROUP_NAME"
echo "then type az group delete --name ${RESOURCE_GROUP_NAME} --no-wait --yes --verbose"
