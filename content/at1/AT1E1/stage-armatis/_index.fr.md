+++
archetype = "example"
title = "Stage Armatis"
weight = 1
+++

---

Préparation et mise en place de postes de travail dans le cadre d’un renouvellement de matériel ou d’une modification d’affectation pour des télé-conseillés et configuration d’un switch Aruba neuf.

Mise à jour des équipements dans BMC Noumara (entrer le nouveau matériel et passer l’ancien en « spare ») avec une nomenclature normalisée reprenant le numéro de série de la machine.
Préparation des nouvelles machines par déploiement de l’image souche (l’hôte) via Clonezilla en PXE puis déploiement de l’image de la VM (VMWare Workstation) spécifique à l’activité ciblée via un script faisant appel à MDT et un ensemble de scripts (Powershell) de configuration.

Installation des équipements sur les positions de travail avec raccordement au réseau, configuration et sécurisation au niveau des switchs Cisco 2960 via Putty et le CLI Cisco. Brassage à effectuer si nécessaire.

Blanchiment du disque des machines sortant de production avec une solution maison basée sur diskpart résidant sur une clé USB bootable et consistant en un formatage de bas niveau en 5 passes.

Mise en service d’un switch Aruba neuf via son interface d’administration web accessible par son adresse IP par défaut (192.168.1.1) pour le site de Saumur (sans vlan car petite structure et une seule activité). 

---
