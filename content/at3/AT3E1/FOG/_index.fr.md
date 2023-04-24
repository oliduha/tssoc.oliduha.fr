+++
archetype = "example"
title = "FOG"
weight = 2
+++

---

## > [FOG Project](https://fogproject.org/)

{{% notice info %}}
TP : On crée 4 VMs dans un réseau en "Host Only" :

- 1 IPFire avec 2 cartes réseau qui ont des adresses MAC différentes.
    - 1 carte RED en Bridge vers l'extérieur du réseau (DHCP ou fixe)
    - 1 carte GREEN en Host Only comme passerelle du réseau H.O. en 192.168.13.254 fixe
- 1 Debian 11 en Serveur FOG (DD 60 GO) en Host Only en 192.168.13.222 fixe - Serveur DHCP ! (+ TFTP &  iPXE)
- 1 Poste "Master" Windows 10 en H.O. DHCP
- 1 Poste sans OS (config pour win10 - DD >= au master)
{{% /notice %}}

![reseau](00_schema_reseau.png)

---

## 1 - IPFire

Télécharger l'ISO et en faire une VM.

Doc : [Installation d'IPFire](https://wiki.ipfire.org/installation) ou sur [neptunet](https://neptunet.fr/ipfire-install/)


{{% notice warning %}}
>Ne pas activer le DHCP et configurer les cartes réseau comme demandé (noter les adresses MAC de chaque carte pour bien les différencier)
{{% /notice %}}

![IPFire](01_ipfire.png)

>En cas de besoin, on peut entrer dans la configuration d'IPFire à posteriori via la commande :

```bash
setup
```

---

## 2 - FOG

{{% notice warning %}}
Bien être en **Bridge** jusqu'à la fin du téléchargement, puis repasser en **Host Only AVANT** de lancer l'installation !
{{% /notice %}}

{{% notice note %}}
*Une doc en ligne sur https://chrtophe.developpez.com/tutoriels/deploiement-fogproject/*
{{% /notice %}}

Partir d'une debian 11 vierge.

Se logger en root :

**Configurer IP Fixe, masque (192.168.13.222/24) et gateway (192.168.13.254)**

Puis :

```bash
apt install git -y
```

```bash
cd /root
git clone https://github.com/fogproject/fogproject.git
cd fogproject-dev-branch
```

{{% notice note %}}
Pour debian 11 il faut passer sur la dev-branch (pour la version actuelle 1.5.9)

```bash
git checkout dev-branch
```

{{% /notice %}}

{{% notice warning %}}
Passer la carte réseau en Host Only **MAINTENANT** !
{{% /notice %}}

Installation :

```bash
cd bin
```

...si toujours dans /root/fogproject-dev-branch ; sinon : ``cd /root/fogproject-dev-branch/bin``

puis

```bash
./installfog.sh
```

{{% notice info %}}
*Les réponses en MAJUSCULES sont celles par défaut*
{{% /notice %}}

**``Choisir : Debian``**

**``Choisir : installation Normale``**

**``Configurer l'IP``**

**``Ne pas changer la carte réseau par défaut``**

**``Activer DNS et DHCP``**

**``Installer les packs de langues``**

**``Activer HTTPS``**

**``Renommer la machine si besoin (Hostname)``**

Récap. + validation => le script d'install se lance...

Lorque c'est terminé, il affiche une URL qu'il demande d'ouvrir dans le navigateur avant de pouvoir finaliser l'install : `https://ip_du_serveur/fog/management`

Une fois l'url ouverte dans le navigateur de notre hôte (la machine qui fait tourner VMWare) on doit cliquer sur ``Install/Update Database``. 

![Fog_Validate_Database](02_1_Fog_Validate_Database.png)

On peut ensuite retourner sur la VM FOG pour finaliser l'installation avec "Entrée".

![Fog_Install_End](02_2_Fog_Install_End.png)

Il faut ensuite se rendre dans le navigateur à `https://ip_du_serveur/fog/`

...et se logger avec **``fog/password``** *(par défaut)* pour atterrir sur le Dashboard de FOG.

![Dashboard FOG](02_3_fog_dashboard.png)

### Serveur DHCP

{{% notice warning %}}
**Il faut impérativement désactiver tout DHCP présent sur le réseau local.** Ici c'est notre serveur FOG qui servira de DHCP.  
*Si ce n'est pas possible, le client lors du boot PXE demandera l'IP du serveur TFTP, il faudra indiquer l'IP de FOG*
{{% /notice %}}

### Désinstallation/Reconfiguration de fog

En cas d'erreur ou simplement de besoin de reconfiguration du serveur FOG, il suffit de renommer le fichier .fogsettings situé dans le dossier /opt/fog/

```bash
mv /opt/fog/.fogsettings /opt/fog/fogsettings.bak
```

On peut ensuite relancer le script shell d'installation

**En Production il est important de créer un nouvel utilisateur pour remplacer celui par défaut qui doit être ensuite désactivé.**

---

## 3 - Enregistrement et inventaire du Master

---

>Un master est une machine qui servira de modèle pour le déploiement sur les autres postes. Elle doit avoir un OS installé et configuré de manière générique (réseau en DHCP...) et peut contenir des logiciels et/ou des scripts à répliquer sur toutes les autres machines.  
*Les possibilités de FOG dans ce domaine en font un outil très puissant*.

{{% notice warning %}}
**Ne PAS spécifier de domaine dans le master ! Celui-ci devra être intégré post-déploiement, machine par machine, avec nom utilisateur, mdp, et en forçant le reboot.**
{{% /notice %}}

Pour enregistrer un poste de travail dans fog, il faut le faire démarrer sur la carte réseau en PXE (Network boot dans le bios ou UEFI de la machine).

![Config_Bios](03_vmw_master_bios_pxe.png)

>*Une autre méthode pour inventorier le Master (uniquement) automatiquement est d'y installer le "FOG client smart installer" au préalable, en lui spécifiant l'IP du serveur FOG à l'install.*
>
> *Le poste sera alors reconnu et inventorié automatiquement après un redémarrage ordinaire.*
>
> *Autre avantage de cette méthode, le client sera intégré à l'image de déploiement !*
>
> *SmartInstaller à télécharger sur* **https://github.com/FOGProject/fog-client/releases**

Lors du boot PXE, la machine est interceptée par FOG et arrive sur un menu spécifique :

![Menu_Fog_unregistered](04_1_vwm_master_fog_menu_1.png)

Sélectionner **``Quick Registration and Inventory``** pour lancer la procédure d'enregistrement de la machine qui va se dérouler sans autre intervention, et après un reboot, revenir à ce menu en indiquant le nom qui lui a été affecté par FOG, en en-tête *(peut être son adresse MAC)* :

![Menu_fog_registered](04_2_vwm_master_fog_menu_2.png)

On peut vérifier dans l'interface web de FOG que la machine est enregistrée en cliquant l'icone **Hosts** dans la barre du haut puis **List All Hosts** dans le menu de gauche.

![Fog_hosts_master](05_1_fog_host_master.png)

On peut changer ses nom et description en cliquant dessus :

{{% notice warning %}}
**Ne pas oublier de valider chaque action effectuée dans l'interface web**
{{% /notice %}}

![Fog_hosts_master_details](05_2_fog_host_master_details.png)

### 4 - Capture de l'image du Master

**On doit ensuite faire une *image* de notre master... Mais avant, il faut créer un conteneur pour la stocker.**

Il faut donc cliquer sur l'icone **Images** *(barre du haut)* puis **Create New Image** *(menu de gauche)* et lui donner un nom explicite. Il faut également lui spécifier le système d'exploitation ainsi que le type d'image.

{{% notice warning %}}
Pour une image windows 10 il faut choisir l'option 3 (ou 2 si 1 seul dd) : **Multiple partition image - All disks (not resizable)**
{{% /notice %}}

![Master_Image](06_1_fog_image_master_details.png)

Ce qui donne :

![Imges](06_2_fog_images_master.png)

Nous pouvons à présent créer une tâche de capture assignée à notre master : de retour sur la page **Host Management** cliquer sur le nom du master pour lui indiquer le conteneur où stocker l'image à la ligne **Host image**. Sélectionner ensuite **Basic Tasks** dans les onglets juste au-dessus et enfin l'icone **Capture** :

![Master_Capture](07_1_fog_host_task.png)

Dans la fenêtre suivante, sélectionner **Wake On Lan** et **Schedule Instant**. Valider.

La tâche doit apparaître dans la page Task Management acessible via l'icone **Tasks** *(barre du haut)* > **Active Tasks** *(menu de gauche)*. On peut également suivre sont avancement à cet endroit.

Il suffit désormais de (re)démarrer la VM master en PXE pour obtenir le menu FOG et y choisir l'option **Capture** pour démarrer la procédure automatique :

![Master_Capture_VM](07_2_master_capture.png)

Opération qu'on peut donc aussi suivre sur l'interface web (et donc à distance) :

![Master_Capture_Fog](07_3_fog_master_capture.png)

Une fois l'opération terminée, l'image est disponible pour déploiement...

![Master_Capture_Done](07_4_Master_capture_done.png)

À ce stade, nous n'avons plus besoin de la machine Master. On peut lui remettre son mode de boot précédent et/ou l'éteindre.

---

## Déploiement

> Nous n'allons ici déployer l'image créée précédemment que sur une seule machine ; dans le cas d'un déploiement sur un parc entier, nous stockerions nos enregistrements de machines dans un groupe afin de l'effectuer en une seule opération.

Nous créons une VM en Host Only, sans OS mais configurée pour recevoir un Windows 10 et avec au moins autant de capacité de disque dur que le master.

Les machines cibles du déploiement doivent au préalable être enregistrées et inventoriées dans FOG par la même procédure que pour le Master (boot en PXE et Quick registration and Inventory).

![VMW_Client_Inventaire](08_vmw_client_apres_enreg.png)

Une fois notre machine inventoriée, on clique sur **Hosts** *(barre du haut)*, **List All Hosts** *(menu de gauche)* puis sur notre nouvelle machine pour la renommer et lui spécifier notre image précédemment créée *(Host image)*. Enfin on clique sur **Basic Tasks** *(onglet)* et l'icone **Deploy** puis les options **Wake On Lan** et **Schedule Instant** dans la fenêtre suivante. On valide cette tâche qui se retrouve à présent dans la liste des tâches actives *(comme pour la tâche de capture du master)*.

![Fog_Hosts_Client](09_Fog_Hosts_Client.png)

![Fog_Client_Task_Deploy](10_1_Client_Deploy_New_Task_.png)

![Fog_Client_Tasks_Deploy_Options](10_2_Client_Deploy_Task_Options.png)

![Fog_Client_Task_added](10_3_Client_Deploy_Task_Added.png)

![fog_Client_Deploy_Active_Tasks](10_4_Client_Active_Tasks.png)

On (re)démarre la machine cliente et le déploiement démarre automatiquement :

![VMW_Client_Deploy_Running](10_5_Client_VMW_Deploy_Running.png)

![Fog_Client_Deploy_Running](10_6_Client_Deploy_fog_Running.png)

** Pour déployer une machine sans avoir créé de tâche au préalable :**

On (re)démarre la machine à déployer et on choisit **Deploy Image** dans le menu FOG pour démarrer la tâche de déploiement. Le processus demande alors un login/mot de passe qu'on renseigne avec ``fog/pqsszord`` (pour fog/password, le clavier étant en disposition QWERTY à ce moment là).

![VMW_Client_Deploy_Menu](11_1_Client_VMW_Menu_Deploy.png)

![VMW_Client_Deploy_login](11_2_Client_VMW_Deploy_Login.png)

Une fois l'opération terminée, on reboot la machine clonée pour modifier son BIOS afin qu'elle boot sur son disque dur. Elle possède la même configuration que la master avec cependant un nom d'hôte correspondant au nom qu'on a spécifié dans FOG *(tout comme le master)*.

![Master-Client](12_Master-Client.png.png)

---

## Installation de l'agent FOG Client

**L'agent FOG permet de changer le nom de la machine via l'interface web, d'y ajouter des logiciels, des scripts et d'autres fonctionnalités avancées (AD...)**

Sur le(s) poste(s) client(s), l'agent FOG peut :

- avoir été installé sur le master donc automatiquement déployé
- être téléchargé manuellement via *SmartInstaller sur* **https://github.com/FOGProject/fog-client/releases** *(ou avec git)*
- être téléchargé depuis l'interface web de FOG dans un navigateur (éviter Edge) par le bouton en bas à gaughe.

Durant l'installation *(procédure classique)* il faut renseigner l'adresse IP du serveur FOG :

![Install_Agent_Fog](13_Install_Agent.png)

... et sélectionner ``HTTPS`` si c'est le cas.

Une fois l'agent installé, un redémarrage est nécessaire, un fichier log.fog est créé à la racine du disque C:

Si le fichier log n’apparaît pas après un redémarrage, on peut lancer le service "FOGService" à la main.

---

## Déploiement de logiciels

**Pour déployer des logiciels post-déploiement, on utilise les ``snapins``**

On y accède via l'icone **snapin** *(barre du haut)* et on crée un nouveau via le menu de gauche **Create New Snapin**.

Il faut au minimum lui donner un nom, un template, un fichier d'installation + les éventuels arguments de ligne de commande pour installation silencieuse (se référer à la doc du logiciel) et valider.

![New_Snapin](14_1_New_Snapin.png)

Ensuite, il faut affecter notre nouveau snapin au(x) poste(s) client(s) en cliquant  **Membership** dans les onglets de la page

![Snapin_Membership](14_2_Snapin_Membership.png)

On le retrouve dans la liste **All Snapins**

![All_Snapins](14_3_All_Snapins.png)

De retour sur le poste client dans la gestion des hôtes, on clique sur "Basic Tasks" puis sur "Advanced"

![Snapin_Host_New_Task](14_4_Snapin_Host_New_Task.png)

Et enfin, dans la liste, sur "Single Snapin" car nous n'avons qu'un logiciel à installer.

![Snapin_Host_New_Task_Config](14_5_Snapin_Host_New_Task_Config.png)

Sélectionner le package à installer et valider

![Single_Snapin_Task](14_6_Single_Snapin_Task.png)

La tâche apparaît dans les tâches actives

Quand l'agent entrera en contact avec le serveur FOG, il recevra l'ordre de télécharger le snapin sur le serveur FOG et l'installera sur le poste client.

Le fichier log.fog contiendra un rapport d'installation

---

## Déploiement d'Office

Pour office on crée un dossier partagé Samba publique sur le serveur FOG.

### **Samba**

- Création et configuration du dossier partagé sur le serveur FOG :

```bash
cd /
mkdir share
cd share
mkdir partage
chmod 777 partage
```

- Installation et configuration de Samba :

```bash
apt install samba
nano /etc/samba/smb.conf
```

smb.conf :

```
[global]
   workgroup = WORKGROUP
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = yes
[partage]
   comment = Partage de fichiers
   path = /share/partage
   guest ok = yes
   read only = no
   browseable = yes
```

### **ODT**

### Sur la machine hôte qui fait tourner les VMs, télécharger et décompresser ODT **dans un dossier où on mettra tous nos scripts et fichiers de configuration suivants**.

- On crée un fichier de configuration pour le téléchargement d'Office.

``downloadOffice.xml`` :

```xml
<Configuration>
  <Add SourcePath="\\192.168.13.222\partage" 
       OfficeClientEdition="64"
       Channel="MonthlyEnterprise" >
    <Product ID="O365ProPlusRetail">
	   <Language ID="fr-fr" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" 
           UpdatePath="\\192.168.13.222\partage" />
   <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
```

- Un fichier pour la configuration de l'installation. 

``installOffice.xml`` :

```xml
<Configuration ID="d3297aa9-1a8d-4c14-af9b-9e243abb0f12">
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise" SourcePath="\\192.168.13.222\partage" AllowCdnFallback="TRUE">
    <Product ID="O365ProPlusRetail">
      <Language ID="fr-fr" />
      <ExcludeApp ID="Bing" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Updates Enabled="TRUE" />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="60" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="52" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="ODT" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
```

{{% notice note %}}
Un générateur pour ce fichier [https://config.office.com/deploymentsettings](https://config.office.com/deploymentsettings)
{{% /notice %}}

![outils_en_ligne](15_0_outil_ms.png)

- Un script batch pour lancer le téléchargement puis la copie des 2 fichiers dont on aura besoin dans le dossier partagé.

``odt.bat`` :

```batch
@echo off
setup /download downloadOffice.xml
echo "Telechargement des fichiers d'installation d'office termine !"
pause
copy setup.exe  \\192.168.13.222\partage\setup.exe
echo "Fichier setup.exe copie sur le serveur FOG"
copy InstallOffice.xml  \\192.168.13.222\partage\InstallOffice.xml
echo "Fichier de configuration installOffice.xml copie sur le serveur FOG"
echo "Scipt termine !"
pause
```

- Et enfin un fichier `.cmd` d'une seule ligne qu'on passera en snapin.

``snapinSetupOffice.cmd`` :

```cmd
\\192.168.13.222\partage\setup.exe /configure \\192.168.13.222\partage\InstallOffice.xml
```

On doit obtenir ceci :

![Dossier_ODT](15_1_Dossier_ODT.png)

On exécute ensuite le fichier ``odt.bat`` et on attend que le téléchargement d'Office soit terminé (*Appuyer sur une touche pour continer...* apparaît dans le terminal).

On vérifie qu'on a bien peuplé notre dossier partagé sur le serveur FOG à l'adresse du partage **``\\192.168.13.222\partage``** :

![Dossier_partage](15_2_Dossier_partage.png)

{{% notice warning %}}
**Il faut faire passer le dossier ``Office`` dans le dossier partagé du serveur FOG en *public* avec :**

```bash
chmod -R 777 /var/share
```

{{% /notice %}}

>On peut temporairement désactiver l'UAC sur le poste client pour éviter les messages de sécurité *(via le panneau de configuration > Sécurité et maintenance > Modifier les paramètres du centre de sécurité et maintenance > et décocher la case Contrôle de compte d'utilisateur)*.

On va ensuite créer notre snapin contenant le script ``snapinSetupOffice.cmd`` comme ceci :

![add_office_snapin](15_3_add_office_snapin.png)

Puis l'affecter à notre hôte cible comme un snapin simple.

![Affect_Office_Snapin](15_4_Affect_Office_Snapin.png)

Et elle doit figurer dans la liste des tâches actives.

Avec la configuration choisie, une barre de progression doit apparaître sur le poste client durant l'installation d'Office *(n'a pas fonctionné lors de ce test)*.

![Office_Installed](15_5_Office_installed.png)

---

## Changement de nom de poste

Il est possible de changer le nom d'un poste client directement depuis l'interface web du serveur FOG.

Il n'est pas nécessaire d'avoir l'agent d'installé sur le client.

Dans l'interface web de FOG cliquez sur **Services Configuration**

Puis **Hostname Changer** pour vérifier l'état du service

La case doit être cochée

![Hostname_Changer](16_1_Hostname_Changer.png)

Ensuite on peut changer le nom de l'hôte dans la page de l'hôte à Host name.

![Host_Name_Change](16_2_Host_Name_Change.png)

Le poste redémarrera automatiquement lors du prochain contact de l'agent pour prendre le nom spécifié dans FOG

{{% notice warning %}}
Pour que le poste client puisse redémarrer alors que l'utilisateur est logué, il faut cocher l'option **ENFORCE HOST CHANGES** dans **FOG Configuration** *(barre du haut)* > **FOG Settings** *(menu de gauche)* > section **Active Directory Defaults**, sinon le renommage se fera au prochain démarrage du poste.
{{% /notice %}}

![AD_Defaults](16_3_AD_Defaults.png)

---

## Déploiement de scripts

Pour le déploiement d'un script, c'est la même chose que pour un logiciel.

Il suffira de sélectionner le type de script et de l'uploader.

Exemple création d'un dossier toto à la racine de C:
créer un batch "script.cmd" qui contient :

```batch
@echo off
mkdir c:\TestScript
ping 192.168.13.254 > c:\TestScript\ping_gw.txt
```

![Script_Snapin](17_Script_Snapin.png)

Ensuite il suffira d'affecter le snapin au poste client voulu et de planifier la tâche au niveau de l'hôte.

---

## Les plugins

{{% notice info %}}
*Ce chapitre - texte et images - est entièrement extrait du support de  cours de Bertand Girault - CEFIM Tours*
{{% /notice %}}

Fog project intègre un système de plugin afin de proposer des fonctionnalités supplémentaires (en développement)

Cliquez sur l'icone' de configuration

![18_1](18_1.jpg)

Puis sur "plugin system" en bas de la liste

![18_2](18_2.jpg)

Et enfin il faut activer le PlugIn System

![18_3](18_3.jpg)

Un nouveau menu apparaît maintenant, cliquez dessus pour voir la liste des plugins.

![18_4](18_4.jpg)

Il faut commencer par activer le plugin en cliquant dessus.

![18_5](18_5.jpg)

cliquez sur le plugin choisi, ici c'est Pushbullet un service qui permet de recevoir des notifications des tâches faites sous FOG

Cliquez sur le menu "install plugins" et enfin sur l'icone de "Pushbullet"

![18_6](18_6.jpg)

Puis sur le menu "installer Plugins"

![18_7](18_7.jpg)

Le plugin est installé et apparaît dans le menu

![18_8](18_8.jpg)

Il faut avoir un compte Pushbullet :

[https://www.pushbullet.com/](https://www.pushbullet.com/)

Sur votre compte pushbullet, vous devez créer un "access token" qui sera copié dans FOG et sur une application installée sur votre smartphone/tablette.

---

## Créer un autre noeud de stockage

Installer FOG sur une autre VM debian en choisissant **[S] Stockage** à la 2ème question de l'installeur. 
Outre le serveur FOG principal il faudra spécifier les nom et mdp de l'utilisateur MySQL qui est renseigné dans l'interface web du serveur sous l'icone **``FOG configuration``** *(barre du haut)* > **``FOG Settings``** *(menu de gauche)* > section **``FOG Storage Nodes``**

![Database_User_Infos](19_Database_user_Infos.png)

{{% notice tip %}}
*Plus sur [**cette page**](https://chrtophe.developpez.com/tutoriels/deploiement-fogproject/#L9)*
{{% /notice %}}

---
