+++
archetype = "example"
title = "Bash"
weight = 2
+++

---

## **Scripts bash**

---

### 1. Script de sauvegarde des fichiers et de la base de données du site wiki

{{% notice info %}}
**Contexte :** 1 VM debian 11 LAMPS avec mediawiki.

*L'objectif est de créer une tâche automatiquement éxecutée quotidiennement qui compresse en zip un dump de la BDD ainsi que le contenu du dossier wiki et le sauvegarde dans un dossier à la date du jour.*
{{% /notice %}}

- on se log en `root` on édite le script dans `/root`

```bash
su -

cd
nano backup.sh
```

- avec :

```bash
#!/bin/bash
#Scipt de backup auto de la BDD et du wiki pour le site user
#V1.0 par UserName le Date
clear
echo Compression des fichiers...
7zip -rq /home/user/$(date +%Y%m%d%H%M%S)_wiki_backup-fichiers.zip /home/user/wiki
echo Dump de la base de données...
mysqldump -u root -p 'toor' --databases user > /home/user/_wiki_backup-base.sql
echo Compression de la base de données...
# zip -m supprime l'original / -q quiet
zip -qm /home/user/$(date +%Y%m%d%H%M%S)_wiki_backup-base.zip /home/user/_wiki_backup-base.sql
echo Terminé !
```

{{% notice info %}}
La chaine `'toor'` est le mot de passe de root sur MySQL. ***Choisir un MDP fort pour un usage en production***
{{% /notice %}}

- on l'enregistre `[CTRL+S]` et on quitte nano `[CTRL+X]`
- on lui donne les droits d'exécution

```bash
chmod +x backup.sh
```

#### Pour tester le script

```bash
cd /root
./backup.sh
```

ou plus simplement

```bash
/root/backup.sh
```

#### Pour automatiser ce script

```bash
crontab -e
```

- choisir [1] pour ouverture avec nano

- rajouter la ligne (cf [http://crontab.guru](http://crontab.guru))

```bash
*/5 * * * * /root/backup.sh
```

-> cette directive exécute le script toutes les 5 minutes (pour tests)

ou

```bash
0 0 * * * /root/backup.sh
```

-> exécute le script tous les jours à 00h00

- **sortir du compte root avec `[CTRL+D]` ou `exit`**

---

### 2. Script de décompression suivant le format dans ~/.bash_aliases

Sur une machine à mon domicile installée sous Linux Bodhi, une distribution légère basée sur Ubuntu 20.04 et disposant de Moksha Desktop, j'ai mis en place ce fichier `.bash_aliases` pour mon compte utilisateur courant (*sudo configuré*). Il contient, outre des alias pour diverses commande que j'utilise plus ou moins fréquemment, une fonction en bash qui extrait un fichier passé en argument.

```bash
  GNU nano 4.8                                               .bash_aliases
# Personnal aliases
alias maj="sudo apt-get update && sudo apt-get upgrade -y"
alias tt="sudo watch sensors"
alias flic="sudo nmap -v -Pn -A"
alias pg="ping google.fr"
alias p1="ping 1.1.1.1"
alias logm="sudo tail -f /var/log/messages | ccze -A"
alias logs="sudo tail -f /var/log/syslog | ccze -A"
alias logi="sudo tail -f /var/log/iptables.log | ccze -A"
alias logii="sudo tail -f /var/log/iptables-input.log | ccze -A"
alias logio="sudo tail -f /var/log/iptables-output.log | ccze -A"
alias logif="sudo tail -f /var/log/iptables-forward.log | ccze -A"
alias iptln="sudo iptables -L --line-numbers"
alias beton="mplayer https://stream.radiobeton.com:8001/stream.mp3"
alias lynis="/usr/local/lynis/lynis audit system"
alias srcali="source ~/.bash_aliases"
alias srcrc="source ~/.bashrc"
alias rcwgui="rclone rcd --rc-web-gui"
alias bd="cd .."

# Fonction to extract file passed as arg
xtrct ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tar.xz)    tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' ne peut etre extrait par xtrct()" ;;
    esac
  else
    echo "'$1' : format de fichier invalide"
    echo "Usage : xtrct [fichier]"
  fi
}
```

---

### 3. Automatisation du renouvellement d'un certificat Let's Encrypt tous les 3 mois

*`certbot` doit être installé sur la machine et un certificat doit être configuré sur son nom de domaine.*

L'opération s'effectue uniquement via crontab

```bash
crontab -e
```

on ajoute :

```bash
0 0 1 */3 * certbot renew --apache --domain oduhamel.oliduha.fr -n
```

*La commande sera éxecutée tous les 3 mois, le 1er jour du mois*

---
