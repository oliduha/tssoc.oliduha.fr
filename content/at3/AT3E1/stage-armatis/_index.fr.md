+++
archetype = "example"
title = "Stage Armatis"
weight = 3
+++

---

## **Déploiement Armatis**

Le déploiement des postes s'effectue en 2 étapes :

1. déploiement de l'image souche (l'hôte) *- environ 30 min*
2. déploiement de la VM (VMWare) selon l'activité à laquelle sera affectée la machine *- environ 2 h*

Les machines sont déployées une à une.

### **Déploiement image souche**

Sur chaque machine, le déploiement de l'image souche s'effectue par boot PXE, puis sélection dans Clonezilla de l'image à déployer. Plusieurs scripts de configuration sont ensuite appelés automatiquement.

- **[F10]** au démarrage de la machine pour accès au BIOS
    - Boot Options
        - Mettre un délai de 5 secondes
        - `Activer le démarrage sur PXE`
        - Désactiver l'alerte audio
    - Sécurité
        - `Désactiver le Secure Boot (disable-disable)`
    - **[F10]** pour sauvegarder les modifications et quitter le BIOS
-> La machine reboot
- **[F9]]** pour le menu de boot
    - `Démarrer sur PXE IPV4`
- Dans le menu de CloneZilla qui s'affiche, choisir `TAUX - Direct Restore HP Universal`
    - Sur certaine machine (les plus récentes) une demande de confirmation apparaît après environ 1 minute => [Entrée]

*Cette étape dure environ 1/2 heure.*

L'opération terminée, la machine doit rebooter sur un compte en auto-login ; sinon (administrateur) redémarrer la machine jusqu'à l'obtenir.

Suivant les machines il y a de petites différence (version BIOS...) :

- 400/600-G2 : C'est la démarche de base

- 400-G3 : Un code pin est demandé pour désactiver le Secure Boot

- 400-G6 : Secure Boot déjà désactivé, normalement

- 400-G9 :
    - Vérifier Secure Boot + Boot Options + MdP BIOS (à définir si machine neuve)
    - Il peut être nécessaire de redémarrer la machine plusieurs fois pour obtenir une session avec le compte en auto-login

---

### **Déploiement image VM**

- Une fois la machine démarrée sur le compte en auto-login :
    - Lancer Post-EDF-NG -> Continue + Finish
    - Fermer VM
- Déco + reco en administrateur
    - Post-EDF-NG -> Continue + Finish (éventuellement : Take Ownership)
    - Fermer VM
    - Menu Démarrer :
        - TAU-INST-NG-PRO-V2 (pour un poste EDF-PRO)
        - TAU-INST-NG-PART-V2 (pour un poste EDF-PART)
    - -> Si hostname en `DESKTOP[...]` : le PC reboot, il faut alors se re-co en administrateur et relancer le script TAU...  
    - -> Si clic-auto manqué : le faire manuellement = Clic + [Entrée]

*Cette étape dure approximativement 2h30.*

### **Configuration d'une machine pour le TAD (Travail A Distance) structurel**

Une fois le déploiement de la VM terminé ou sur une machine déjà en production sur site :

1. Fermer la VM
2. Se déconnecter du compte utilisateur actif (en auto-login)
3. Se connecter en administrateur
4. Menu démarrer > TAU-INST-TAD

*L'opération dure environ une minute.*

---
