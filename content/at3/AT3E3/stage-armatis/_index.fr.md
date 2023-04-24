+++
archetype = "example"
title = "Stage Armatis"
weight = 1
+++


## Sécurisation du réseau Armatis sur un plateau EDF

Lors de la mise en place d'un poste de travail, le brassage du poste n'est pas toujours de fait. Si le poste n'a pas de connexion réseau, il faut procéder à divers vérifications :

On connecte un pc portable dont on connaît l'adresse MAC au cable Ethernet du poste à vérifier, puis on se connecte en admin à un autre poste et via Putty et le CLI Cisco on recherche à quel port de quel switch le poste est connecté.

```bash
show mac address-table address xxxx.xxxx.xxxx
```

- Si la réponse indique que l'adresse MAC a été trouvée sur un port Gi0/x, cela signifie que la machine est connectée à un autre switch (lien inter-switch).
- Si la réponse indique un port du type Fa0/x, nous sommes sur le bon switch et nous savons donc sur quel port.
- Si la commande ne trouve pas cette adresse MAC, c'est que la prise Ethernet n'est pas brassée. Il faut alors :
    1. Relever le numéro de la prise réseau du poste
    2. Aller en salle blanche contrôler le brassage en suivant le cable correspondant au numéro de prise relevé vers le switch
    3. Si aucun cable ne sort du numéro de prise en salle blanche, on va chercher à connecter le poste à une autre prise disponible proche du poste de travail (certains switchs sont saturés).
    4. alternativement, si au moins un port de switch est libre, on pourra tirer un nouveau cable pour faire la liaison.
    5. Relever le port du switch connecté
    6. Depuis un poste en admin, configurer le port du switch concerné, l'activer si besoin et effectuer les réglages de sécurisation (voir ci-après)

---

La sécurisation réseau consiste à limiter le nombre d'adresses Mac différentes qu'il est possible de connecter sur chaque ports du switch (maximum) et une fois qu'une machine est connectée au switch, elle n'est plus autorisée à utiliser un autre port (mac-address sticky) sous peine de provoquer la désactivation automatique du port.

On différencie 2 cas :

* Les postes fixes :
    - 3 adresses Mac maximum autorisées (souche, VM + administration)
    - le mode sticky activé
* Les postes TAD Structurel :
    - 30 adresses Mac
    - pas de sticky

En effet, le TAD structurel mis en place chez Armatis consiste en une alternance de 2 jours à domicile et 3 jours sur site. Les téléconseillers concernés se voient donc attribuée une UC qu'ils emmènent chez eux et rapportent avec eux lorsqu'ils travaillent sur site. Des postes sont donc aménagés spécifiquement avec une sécurité réseau permettant d'accepter différentes machines (contrairement à un poste de travail fixe).

On va reconfigurer tous les ports du switch durant la manipulation. On sait déjà quels ports correspondent à quels cas :

1. Pour accéder à switch, il faut préalablement se connecter sur un poste en admin et créer une règle temporaire de contournement du pare-feu autorisant tous les ports en sortie.
2. On accède ensuite au switch via Putty et en utilisant le CLI Cisco
3. On vérifie l'état des interfaces : `sh int status`
4. Puis l'état des vlan : `sh vlan`
5. On réinitialise le port-security sticky pour tous les ports :

```bash
clear port-security sticky
```

6. On peut vérifier l'état d'un port en particulier : `sh run int fa0/4`
7. On passe en mode configuration terminal avec

```bash
conf t
```

{{% notice note %}}
***On commence maintenant la configuration.** On va agir sur des plages de ports consécutifs.*
{{% /notice %}}

1. Cas d'une plage des 4 premiers ports pour des postes fixes :

```bash
int r fa0/1-4
switchport port-security maximum 3
switchport port-security mac-address sticky
switchport port-security
```

{{% notice warning %}}
Cette dernière commande est indispensable pour activer la sécurité
{{% /notice %}}

1. Cas d'une plage de 2 ports pour des postes TAD

```bash
int r fa0/5-6
switchport port-security maximum 30
no switchport port-security mac-address sticky
switchport port-security
description **** TAD STRUCT ****
```

10. On répète ces opérations autant de fois que nécessaire pour configurer tous les ports du switch (24 ou 48)
11. On sort du mode configuration avec `end`
12. Pour finir on enregistre la configuration avec

```bash
wr mem
```

13. Et on quitte le CLI avec `exit`

---
