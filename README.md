# AzureMeshCentral

AzureMeshCentral has been created to be able to quickly deploy a [MeshCentral intance](https://www.meshcommander.com/meshcentral2) on a virtual machine hosted in the Microsoft Azure Cloud. It can't be called perfect yet but it works. It took me about 2 days to develop.

The project was started in order to be able to establish remote access to a "foreign network" extremely quickly.

For example:
It could happen that a customer network has been infected with ransomware. Network communication with the Internet has been disconnected as much as possible but remote support is necessary to support the customer.
With this solution, a temporary MeshCentral server is simply deployed on the Internet, served exclusively via https. From there the MeshAgent can be created and installed on any number of hosts of the infected customer. The connectivity of the agents can be technically restricted so that they are only allowed to connect to the MeshCentral server via https/443(tcp) in the direction of the Internet. From this point on, customer hosts can be managed and supported in the MeshCentral Server web interface.

## Prerequisites

### Azure side

- a valid account for [Microsoft Azure](https://portal.azure.com/) with a working subscription
- the Azure login must be allowed to create new Resource Groups in Azure
- the ability to open an Azure Cloud Shell with the above login with a clouddrive available

### "Customer" side

Machines where the MeshAgent is deployed need outbound connectivity https/tcp(443) to public IP of the MeshCentral Server.

### "Admin" side

-After MeshCentral server is running Admin/Supporter needs outbound connectivity https/tcp(443) to public IP of the MeshCentral Server.

## Deployment

### Login to an Azure Cloud shell

If your cloud shell uses PowerShell enter `/bin/bash` to switch to a Bash shell.

```
Mandant 0: SUPPORTER Supporter Company (supporterxyzcom.onmicrosoft.com)
Geben Sie die gewünschte Mandantennummer ein.
Drücken Sie N, um sich mit einem neuen Konto anzumelden.
Geben Sie r ein, um die oben gespeicherten Verbindungseinstellungen zu entfernen.
> 0
Anfordern einer Cloud-Shell-Instanz...
Erfolgreich.
Ein Terminal wird angefordert (Dies kann eine Weile dauern)...

MOTD: Azure Cloud Shell now includes Predictive IntelliSense! Learn more: https://aka.ms/CloudShell/IntelliSense

VERBOSE: Authenticating to Azure ...
VERBOSE: Building your Azure drive ...
PS /home/supporter_adm> /bin/bash
supporter_adm [ ~ ]$
```

### Clone this git repository

```bash
supporter_adm [ ~ ]$ git clone 'https://github.com/boschkundendienst/azure_meshcentral_001.git'
Cloning into 'azure_meshcentral_001'...
remote: Enumerating objects: 22, done.
remote: Counting objects: 100% (22/22), done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 22 (delta 9), reused 9 (delta 2), pack-reused 0
Receiving objects: 100% (22/22), 8.26 KiB | 8.26 MiB/s, done.
Resolving deltas: 100% (9/9), done.
```

**Change into the repository**

```bash
supporter_adm [ ~ ]$ cd azure_meshcentral_001/
supporter_adm [ ~/azure_meshcentral_001 ]$
```

If you list the files in the directory using `ls -l` you should see the following files:

```
total 28
-rw-r--r-- 1 supporter_adm supporter_adm 3603 May 25 12:42 01_create_azure_vm.bash
-rw-r--r-- 1 supporter_adm supporter_adm 1606 May 25 12:42 02_run_playbook.bash
-rw-r--r-- 1 supporter_adm supporter_adm 2770 May 25 12:42 GLOBAL_CONFIG.conf.sample
-rw-r--r-- 1 supporter_adm supporter_adm 5410 May 25 12:42 PLAYBOOK.script
-rw-r--r-- 1 supporter_adm supporter_adm 2031 May 25 12:42 PLAYBOOK.yml
-rw-r--r-- 1 supporter_adm supporter_adm   85 May 25 12:42 README.md
```

**About the files**

```
01_create_azure_vm.bash    : Bash script to create an Azure Resource with a running Linux VM (Almalinux)
02_run_playbook.bash       : Bash script that uses ansible to prepare the Linux VM for MeshCentral deployment
GLOBAL_CONFIG.conf.sample  : Example configuration file (must be edited and stored as GLOBAL_CONFIG.conf)
PLAYBOOK.yml               : The Ansible Playbook to install MeshCentral on the Linux VM
PLAYBOOK.script            : Bash script used by the Playbook (not ment to be executed manually)
README.md                  : The file you are currently reading
```

### Create a copy of the configuration sample

```bash
supporter_adm [ ~/azure_meshcentral_001 ]$ cp ./GLOBAL_CONFIG.conf.sample ./GLOBAL_CONFIG.conf
```

### Edit the configuration file

Walk through the configuration file `GLOBAL_CONFIG.conf` and edit the following lines to your needs. I personally recommend to use the VIM Editor with syntax highlighing enabled to do this.

**LOCATION**

Change the line 

```bash
export LOCATION='eastus'
```

to your needs to represent a valid Azure Cloud Region. This is the location where your virtual machine will be deployed e.g. `eastus`.
You can list available regions with `az account list-locations | jq '.[].metadata.pairedRegion | .[]?.name'`

**DNS_HOSTNAME**

Change the line

```bash
export DNS_HOSTNAME='test-meshcentral'
```

to your needs to represent the **public** hostname of your machine (host part only). `DNS_HOSTNAME` must match the regex `^[a-z][a-z0-9-]{1,61}[a-z0-9]$` to be accepted by Azure Cloud.

**DNS_ZONE**

Do **not** edit. This variable will always be `$LOCATION.cloudapp.azure.com`


**VM_IMAGE**

Change the line

```bash
export VM_IMAGE='almalinux:almalinux:9-gen2:9.1.2022122801'
```

to your needs to represent a valid Azure Cloud Linux Image available in the Azure Region you specified earlier.
You can list available Almalinux images with `az vm image list --all --publisher almalinux | jq '.[] | .urn' | grep ':9'`

**RESOURCE_GROUP_NAME**

Change the line

```bash
export RESOURCE_GROUP_NAME='CUSTOMER_MESHCENTRAL'
```

to your needs. This will be the name of the Resource Group generated in the Azure Cloud that contains the entire setup.

**VM_NAME**

Change the line

```bash
export VM_NAME='test-meshcentral'
```

to your needs. This will be the local hostname of the meshcentral server. It makes sence to use the same value as previously used for DNS_HOSTNAME.

**VM_SIZE**

Change the line

```bash
export VM_SIZE='Standard_B2s'
```

to your needs to represent a valid Azure Cloud VM Size for a linux host. The standard `Standard_B2s` size works good for our purpose.

**ADMIN_USERNAME**

Change the line

```bash
export ADMIN_USERNAME='loginuser'
```

to your needs. This is the local user that will be allowed to connect to the linux host using SSH. The SSH keys present in your Azure Cloud Shell will be automatically added during deployment and you will be able to login with this user without using a password instead using your public/private key pair.

**Now we will setup some variables that are in 'lower case'. Those are all used to automatically configure MeshCentral.**

**title**

Change the line

```bash
export title="Customer RemoteControl"
```

to your needs. The string you enter here will be configured as the banner of the MeshCentral Server Website and visible at the login screen of the MeshCentral Server.


**adminuser, adminpass, adminmail,adminname**

These 4 variables will be used to generate the administrative user for the MeshCentral Server.

Change the following 4 lines

```bash
export adminuser='adminuser'
export adminpass='WellChoose@GoodPassword1!'
export adminmail='adminuser@customer.domain'
export adminname='Max Mustermann'
```

to your needs. The values are self explanatory. **Make sure you change the password to a different value than the sample provides.**

**le_email**

Change the following line

```bash
export le_email='adminuser@azure.com'
```

to your needs. You should use your personal email address here.

**You must specify a valid domain name after the `@` sign or the automatic certificate retrieval from Let's Encrypt will not work!**

### Make the scripts executable

**Verify all variables in `GLOBAL_CONFIG.conf` twice before you continue !!!**

Make the script `01_create_azure_vm.bash` and `02_run_playbook.bash`executable by entering:

```bash
supporter_adm [ ~/clouddrive/azure_meshcentral_001 ]$ chmod +x ./01_create_azure_vm.bash
supporter_adm [ ~/clouddrive/azure_meshcentral_001 ]$ chmod +x ./02_run_playbook.bash
```

### automatic creation of the Linux VM in Azure Cloud

Execute **01_create_azure_vm.bash** by entering

```
supporter_adm [ ~/clouddrive/azure_meshcentral_001 ]$ ./01_create_azure_vm.bash
```

This will initiate the process of creating the entire Azure Cloud setup.

- creating a resource group in Azure Cloud
- create the Linux VM in the resource group with a public IP
- retrieve the public IP and set the public FQDN
- open port 80 and 443 from the public internet to the Linux VM

### automatic deployment of MeshCentral on the Linux VM in Azure Cloud

**After and only if the execution of the previous script worked without errors** you can continue.

Execute **02_run_playbook.bash** by entering

```
supporter_adm [ ~/clouddrive/azure_meshcentral_001 ]$ ./02_run_playbook.bash
```

This will prepare the Linux VM for MeshCentral and then deploy MeshCentral.

The first part of the script uses Ansible to

- update all installed packages using DNF module
- reboot the machine if needed
- install necessary packages
- create a temporary virtual node environment for meshcentral (as normal user)
- activate a virtual node environment and installs meshcentral npm package (as normal user)
- copy a script to the VM that configures MeshCentral in `/opt` and creates the `meshcentral.service` file
- executes the the script on the VM
- stops `firewalld` on the VM since we use the Network Security Group (NSG) in Azure cloud as firewall

## Summary

You should now be able to connect to your MeshCentral Server from the public internet using https. MeshCentral should already have a valid SSL certificate (from Let's Encrypt) and you should be able to login with the admin credentials you configured as `adminuser` and `adminpass`.

## Links
