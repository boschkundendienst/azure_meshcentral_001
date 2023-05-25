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



