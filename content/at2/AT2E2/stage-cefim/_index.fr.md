+++
archetype = "example"
title = "Stage Cefim"
weight = 1
+++

## **Automatisation vouchers CEFIM_PEDAGO**

***Les vouchers sont des codes d'accès temporaires à un réseau WiFi sécurisé.***

---

## Mission initiale

Simplifier l'extraction de vouchers pour connexion au réseau WiFi CEFIM_PEDAGO des utilisateurs apportant leur propre matériel (ordinateur, tablette, smartphone).

---

## Contexte

Dans les locaux du CEFIM, le réseau WiFi CEFIM_PEDAGO est utilisé par la majorité des étudiants, formateurs, intervenants extérieurs et jurys.

L'accès courant au réseau est autorisé par un système de filtrage MAC au niveau du portail captif de la passerelle/pare-feu (pfSense).
Les adresses MAC des machines CEFIM (pc/mac) fournies aux étudiants et formateurs internes sont enregistrées dans la configuration du portail captif.

Pour autoriser la connexion d'une machine inconnue, un système d'authentification par vouchers est mis en place au niveau du portail captif.
Il s'agit de séries (appelées Rolls) de codes d'accès temporaires générés manuellement dans l'interface web du pfSense (menu 'Services' > 'Captive Portal' > 'Edit Zone' > 'Vouchers').

En général, une série de 1000 vouchers valides pendant cinq jours est générée par l'administrateur quand la série précédente arrive à épuisement.
La série générée est téléchargée depuis l'interface web du pfSense au format .csv puis importée dans un google sheet partagé.

Lorsqu'un groupe d'utilisateurs a besoin de se connecter temporairement à Internet avec des machines non connues du portail captif, il faut lui fournir une liste de vouchers (1 par personne).
Pour cela, un opérateur doit renseigner les divers éléments du tableau (le statut réservé, son nom, la date et le nom du groupe ou de la personne) pour chaque voucher, puis copier le nombre de codes souhaités depuis le tableau partagé et les coller dans un autre document (tableur ou texte) qu'il doit ensuite imprimer.
L'utilisateur final peut ainsi se connecter au réseau en renseignant le voucher qui lui est fourni lorsque le portail captif lui demande.

---

## Problèmes relevés

1. Plusieurs manipulations sont nécessaires pour imprimer les vouchers.
2. Les opérateurs n'utilisent pas toujours des codes contigus dans la liste, rendant parfois encore plus fastidieuses les extractions ultérieures.
3. L'administrateur doit surveiller l'évolution de l'utilisation de la liste de vouchers afin d'en générer de nouveau lorsqu'elle arrive à épuisement.
4. Les vouchers sont le plus souvent attribués à des groupes d'utilisateurs. Une fois la formation terminée il n'y a aucun moyen de relier un utilisateur au code de connexion utilisé, ce qui représente un risque légal.
5. Une partie des vouchers n'a pas été utilisée une fois la formation terminée, ce qui représente un autre risque car ces codes se retrouvent alors "dans la nature".

---

## Objectifs fonctionnels

- Simplifier et rationaliser le système.
- Avertir l'administrateur lorsque la liste de vouchers atteint un seuil critique.
- Relier les utilisateurs aux vouchers qu'ils ont utilisé.
- Invalider les vouchers non utilisés.

---

## Solution envisagée

Développer un script 'Apps Script' (le langage de script Google Workspace - une version de javascript spécifiquement développée par Google) qui devra :

- Afficher un formulaire simplifiant la saisie des informations nécessaires à l'extraction par les opérateurs.
- Extraire et réserver le nombre de vouchers nécessaires de la liste.
- Créer un Google Document présentant les vouchers mis en page, prêt à être imprimé.
- Envoyer un email d'alerte à l'administrateur lorsque la liste de vouchers disponibles arrive à épuisement.

Fonctionnalité supplémentaire : Disposer d'une liste de secours afin de simplifier l'ajout de vouchers par l'admin s'il n'est pas présent sur site (en congés, en déplacement, etc.) lorsque la liste courante arrive à épuisement.

L'invalidation des vouchers non utilisés n'est possible que par l'intermédiaire de l'interface web du pfSense et donc relève de la responsabilité de l'administrateur. Il faut simplement intégrer cette opération dans une procédure de maintenance.

---

## Prérequis

Arborescence Google Drive :

- 1 dossier principal Google Drive partagé avec :
  - 1 sous-dossier accessible uniquement par l'administrateur.
  - 1 sous-dossier partagé

Documents Google :

- 1 Google Sheet dans le dossier principal contenant la liste courante de vouchers disponibles. Le partage de ce fichier doit être nominatif (l'accès nécessite une connection aux services Google). Il contiendra :
  - 1 feuille de calcul pour la liste des vouchers disponible.
  - 1 feuille de calcul pour la liste des vouchers utilisés.
  - 1 feuille de calcul masquée contenant les paramètres généraux des scripts :
    - L'Id du modèle de document.
    - L'Id du sous-dossier contenant les documents générés.
    - L'adresse email de l'administrateur.
    - Le seuil d'alerte.
- 1 modèle Google Document dans le dossier principal pour impression des vouchers sur demande contenant :
  - Le logo du CEFIM.
  - 1 emplacement pour le nom du groupe ou de la personne.
  - 1 emplacement pour la date.
  - 1 tableau sur 2 colonnes avec :
    - 1 ligne de titres
    - 25 lignes avec chacune 1 emplacement pour un voucher dans la 1ère colonne et 1 cellule vide pour recevoir les nom et prénom de l'utilisateur dans la 2ème colonne.
  - Un message "Bonne formation" sous le tableau.
- 1 Google Sheet dans le dossier privé contenant la liste des vouchers de secours.

---

## Mise en oeuvre

### Côté serveur

Un script serveur attaché à la liste courante qui implémente les fonctionnalités suivantes :

- Ajout d'un menu permettant d'afficher le formulaire de demande de vouchers.
- Ajout d'un déclencheur personnalisé affichant le formulaire à l'ouverture de la feuille de calcul.
- Le formulaire est affiché de manière modale.
- Post-traitement du formulaire :
  - Récupération des données saisies.
  - Récupération de l'adresse email de l'opérateur.
  - Extraction du nombre de vouchers demandés vers une autre feuille de calcul avec les infos de réservation.
  - Mise en forme des données déplacées.
  - Création d'un Google Document à partir d'un modèle.
  - Insertion des données dans le Document.
  - Suppression des éléments inutiles.
  - Enregistrement du Document dans un sous-dossier spécifique du Drive.
  - Affichage du lien vers le Document généré.
- Envoi d'un email d'alerte à l'administrateur lorsque le nombre de vouchers disponibles est en dessous du seuil défini, avec :
  - 1 lien vers l'interface web du pfSense pour générer un nouveau roll.
  - 1 lien pour ouvrir la liste de secours.
  - 1 lien vers la liste courante.

Un script serveur attaché à la liste de secours qui implémente ces fonctionnalités :

- Ajout d'un menu permettant de lancer la procédure d'ajout de vouchers de secours à la liste courante.
- Le chargement de la configuration contenue dans une feuille spécifique du classeur.
- La procédure d'ajout de vouchers de secours à la liste courante avec demande de confirmation préalable et gestion des erreurs (authentification, ouverture de fichier).
- Envoi d'un email indiquant le succès ou l'échec éventuel de l'opération ainsi que le nombre de vouchers de secours restants.

### Coté client

Un fichier html contenant le formulaire de réservation de vouchers avec :

- 1 champ pour renseigner le nom du ou des destinataires (groupe ou personne).
- 1 champ pour la date.
- 1 champ pour le nombre de vouchers à réserver.
- Formatage CSS :
  - Mise en page générale.
  - Indication des champs requis.
- Javascript :
  - Validation des données saisies pour éviter les erreurs, avec retour visuel.
  - Indication de chargement.
  - Déclenchement du script serveur suite à la validation du formulaire.

Un fichier Html d'indication de chargement comportant :

- 1 titre
- 1 gif animé hébergé sur le Google Drive partagé

---

## Utilisation

### Par les opérateurs

À l'ouverture du Google Sheet partagé contenant la liste des vouchers disponibles, un script est automatiquement exécuté. Il ajoute une entrée de menu et affiche le formulaire permettant de saisir les informations nécessaires à la réservation de vouchers :

- Un nom de groupe ou personne.
- La date de début de formation.
- Le nombre de vouchers à réserver.

L'opérateur étant connecté pour avoir accès au document, son adresse email est automatiquement récupérée par le script.

Une fois le formulaire correctement renseigné (les données saisies sont vérifiées) le script déplace le nombre de vouchers réservés dans une autre feuille où sont également renseignés les informations propres à la réservation, puis génère une copie du modèle Google Document en y insérant le nom du groupe, la date et la liste de vouchers réservés.

Une boite de dialogue affichant le lien vers le document généré est alors présentée à l'opérateur. En suivant ce lien le document s'ouvre dans un nouvel onglet de son navigateur, il peut directement l'imprimer ou le modifier au préalable si besoin (par ex. : renseigner la colonne des noms d'utilisateurs si connus par l'opérateur). Si non remplis avant impression, les utilisateurs devront renseigner leur nom et prénom en regard du voucher utilisé.

Une fois le tableau rempli et récupéré, l'opérateur devra reporter ces renseignements dans le tableau des vouchers utilisés. Pour se conformer à la législation, ces données devront être conservées pendant une durée minimum d'1 an.

### Par l'administrateur

L'administrateur génère un roll initial de 1000 vouchers ayants une durée de validité de 5 jours.

Lorsque le nombre de vouchers disponible atteint le seuil minimal, il reçoit un email d'alerte lui indiquant le nombre de vouchers disponibles restant et lui présentant :

- Un lien vers l'interface web du pfSense (adresse ip publique accessible de l'extérieur).
- Un lien vers le Google Sheet contenant les vouchers de secours pour un ajout rapide.
- Un lien vers la liste courante pour vérification.

S'il décide d'activer des vouchers de secours, un menu ou un bouton lui permettent d'ajouter 100 vouchers de secours à la liste courante. Il peut répéter l'opération jusqu'à épuisement de la liste de secours. Un email de confirmation (ou d'erreur) lui est automatiquement envoyé à chaque ajout lui indiquant le succès (ou l'échec le cas échéant) de l'opération ainsi que le nombre de vouchers de secours restants.

Ensuite, lorsque son emploi du temps lui permettra, il devra générer un nouveau roll de vouchers par le biais de l'interface web du pfSense et les ajouter à la liste courante. Il devra également s'assurer de disposer d'un nombre suffisant de vouchers de secours en cas de besoin.

---

## Mise en production

Le document Google Sheet contenant la liste courante de voucher doit être stocké dans un dossier principal Google Drive ('CEFIM_PEDAGO'). Ce document doit être partagé nominativement (utiliser le partage "Limité") en renseignant une adresse email pour chaque collaborateur devant avoir un accès à cette liste. Ceci est nécessaire pour pouvoir récupérer automatiquement son adresse email via le script. Ce document comportera 3 feuilles de calcul :

- 1 feuille nommée **"Vouchers"** contenant la liste des vouchers disponibles.
- 1 feuille nommée **"Utilisés"** contenant la liste des vouchers réservés.
- 1 feuille nommée **"Config"** (masquée) contenant les paramètres des scripts.

Le modèle Google Document sera hébergé dans le dossier principal avec la liste courante et pourra être partagé de manière plus permissive (option de partage "Tous les utilisateurs qui ont le lien").

Le document Google Sheet contenant les vouchers de secours doit être, quant-à-lui, stocké dans un sous dossier privé ('PRIVATE') du dossier principal et n'être accessible que par l'administrateur en charge de la génération des rolls de vouchers (détenant un accès au pfSense). Il ne comportera qu'une seule feuille nommée **"Liste_Secours"**.

**Important : Bien respecter les noms des feuilles de calcul pour les 2 Google Sheet tels qu'indiqués ci-dessus en gras : Les scripts s'appuient sur ces noms de feuille.**

### Partages

- Dossier principal 'CEFIM_PEDAGO' : Tous les utilisateurs qui ont le lien
- Sous-dossier 'DOCS' : Tous les utilisateurs qui ont le lien
- Sous-dossier 'PRIVATE' : Non partagé
- Google Sheet 'Vouchers_CEFIM_PEDAGO' : Partage limité
- Google Document 'Template_Vouchers_CEFIM_PEAGO' : Tous les utilisateurs qui ont le lien
- Google Sheet 'Vouchers_CEFIM_PEDAGO_SECOURS' : Non partagé

---

## Améliorations ultérieures éventuelles

- Création et gestion de plusieurs rolls avec des durées de validité différentes (1/2 journée - 1 jour - 2 jours - 3 jours - 4 jours - 1 semaine - 2 semaines - 1 mois) pour correspondre aux durées des différentes formations dispensées. Autant de rolls de secours devront être prévus.

- Dans le cas où l'opérateur renseigne les noms/prénoms des utilisateurs avant impression, disposer d'un script attaché au document permettant de reporter automatiquement ces infos dans le tableau des vouchers utilisés.

- Export des vouchers réservés à l'issue de chaque formation afin d'en faciliter la vérification (s'ils ont été utilisés ou non) ou l'invalidation (interface web du pfSense dans les 2 cas).

---

## Annexes

### Caractéristiques des rolls de vouchers

- Ils comportent un numéro unique parmi les rolls actifs.
- On leur affecte un nombre de vouchers (1023 maximum avec le nombre de bits de ticket par défaut).
- On leur définit une durée de validité en heures.
- Une description leur est associée.

**Attention : Tout changement dans les champs de nombre de bits (roll, ticket ou somme de contrôle - voir ci-après) invalide immédiatement tout roll créé précédemment.**

### Caractéristiques générales des vouchers pfSense

>*Le texte en italique ci-dessous est une traduction de la documentation officielle.*

- Clés RSA : `64 bits maximum` (32 bits par défaut).
- Jeu de caractères (utilisé pour la création des vouchers) : `2345678abcdefhijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ` (par défaut - les caractères pouvant prêter à confusion sont retirés).

Bits des vouchers : *Les champs de bits suivants contrôlent la manière dont les vouchers sont généré par le portail. Il est recommandé d'utiliser les valeurs par défaut mais celles-ci peuvent être ajustées si nécessaire. Le total de tous les champs de bits doit être inférieur au nombre de bits de la clé RSA (exemple avec les valeurs par défaut : 16 + 10 + 5 = 31 => 32 - 1).*

- Bits de roll : [1-31], défaut : `16` => définit le nombre maximum de rolls actifs simultanément = 65535 avec 16 bits (2^16 - 1, défaut).
- Bits de ticket : [1-16], défaut : `10` => définit le nombre maximum de vouchers par roll = 1023 avec 10 bits (2^10 - 1, défaut).
- Bits de somme de contrôle : [0-31], défaut : `5` => bits de contrôle d'intégrité.

*Le 'nombre magique' est présent dans chaque voucher et est vérifié par le portail lors de la vérification du voucher. La taille du nombre magique dépend du nombre de bits restant après avoir additionné les bits de roll, voucher et somme de contrôle. S'il ne reste aucun bit disponible, le nombre magique n'est pas utilisé.*

Les deux derniers champs de la page de configuration permettent de personnaliser les messages d'erreur en cas de tentative de connexion avec un code invalide ou avec un code expiré.

En résumé : Pour augmenter le nombre maximum de vouchers générés par roll il faut augmenter le nombre de bits de ticket tout en diminuant d'autant le nombre de bits de roll (en conséquence les vouchers générés comporteront davantage de caractères).

### Caractéristiques des vouchers pour CEFIM_PEDAGO

- Générés par roll de 1000 vouchers.
- Durée de validité de 5 jours à compter du moment d'activation par l'utilisateur.

Les options suivantes conservent les valeurs par défaut :

- Clés RSA de 32 Bit (Public/Private).
- Jeu de caractères : 2345678abcdefhijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ
- Bits de roll : 16
- Bits de tickets : 10
- Bits de somme de contrôle : 5
- Nombre magique à 10 chiffres.

---

### Captures d'écrans

- Le formulaire de réservation :

![Formulaire de réservation](01-Furmulaire%20r%C3%A9servation.png)

- Le modèle de document :

![Modèle de document](02-Template%20Vouchers%20CEFIM_PEDAGO.png)

- La présentation du lien vers le document généré :

![Lien document généré](03-Lien%20document%20g%C3%A9n%C3%A9r%C3%A9.png)

- Le document généré :

![Document généré](04-Document%20g%C3%A9n%C3%A9r%C3%A9.png)

- Le document généré modifié :

![Document généré modifié](05-Document%20g%C3%A9n%C3%A9r%C3%A9%20modifi%C3%A9.png)

- L'email d'alerte de liste épuisée :

![Email alerte liste épuisée](06-email%20alete%20liste%20%C3%A9puis%C3%A9e.png)

- L'email de confirmation d'activation de vouchers de secours :

![Email confirmation secours](07-email%20confirm%20secours.png)

---

### Code

Vouchers CEFIM_PEDAGO

Code.gs :

```javascript
// Global config object
let config = {};

// Add a menu entry to UI
function onOpen() {
  SpreadsheetApp.getUi()
      .createMenu('🔑VOUCHERS')
      .addItem('Reserver', 'openFormDialog')
      .addToUi();
}

// Open the form dialog (triggered by opening the spreadsheet or by the VOUCHERS menu)
function openFormDialog() {
  let sheet = SpreadsheetApp.getActive().getSheetByName('Vouchers');
  sheet.activate();
  let html = HtmlService.createHtmlOutputFromFile('Form')
      .setWidth(520)
      .setHeight(320);
  SpreadsheetApp.getUi()
      .showModalDialog(html, 'Vouchers CEFIM_PEDAGO');
}

// Show the loading dialog
function openLoadingModal() {
  let html = HtmlService.createHtmlOutputFromFile('Loading')
      .setWidth(520)
      .setHeight(360);
  SpreadsheetApp.getUi()
      .showModalDialog(html, 'Chargement...');
}

// Populate the config object
function getConfig() {
  let configSheet = SpreadsheetApp.getActive().getSheetByName('Config');
  config.templateId = configSheet.getRange(2, 2).getValue();
  config.docFolderId = configSheet.getRange(3, 2).getValue();
  config.email = configSheet.getRange(4, 2).getValue();
  config.lowlimit = parseInt(configSheet.getRange(5, 2).getValue(), 10);
  Logger.log(`*CONFIG* templateId: ${config.templateId}
        docFolderId: ${config.docFolderId}
        email: ${config.email}
        lowlimit: ${config.lowLimit}`);
}

// Create a Google Document with form response data
function createDocumentFromFormData(form) {
  config = getConfig();
  let html = '';
  let ui = null;
  // Form response (or test data if debugging)
  let grp = form.group ? form.group : 'DEBUG TEST GRP [' + new Date() + ']';
  let date = form.date ? form.date : '2022-12-31';
  let nb = form.nb ? parseInt(form.nb, 10) : 2;
  // Localized date
  let fdate = Utilities.formatDate(new Date(date), 'Europe/Paris', 'dd/MM/yyyy');
  // Get email of the user executing the script
  let user = Session.getActiveUser().getEmail();
  let ss = SpreadsheetApp.getActive();
  // Store the working Sheets
  let vlist = ss.getSheetByName('Vouchers');
  let used = ss.getSheetByName('Utilisés');
  let rows = vlist.getDataRange().getValues();
  // Make a copy of the template Document & store its ID
  let documentId = DriveApp.getFileById(config.templateId).makeCopy().getId();
  // Using string interpolation
  let title = `${date} - ${grp} - ${Date.now()}`;
  let docFile = DriveApp.getFileById(documentId)
  docFile.setName(title);
  // Add the docFile to the doc sub-folder
  DriveApp.getFolderById(config.docFolderId).addFile(docFile);
  // Remove the docFile ref from the current folder
  docFile.getParents().next().removeFile(docFile);
  let documentUrl = `https://docs.google.com/document/d/${documentId}/edit`;
  let docBody = DocumentApp.openById(documentId).getBody();
  docBody.replaceText('##Groupe##', grp);
  docBody.replaceText('##Date##', fdate);
  let placeholder = '';
  // Store the 1st empty row from the used Sheet before insertion
  let firstRow = used.getLastRow() + 1;
  // Get & move the needed number of Vouchers from the vlist Sheet to the used Sheet,
  // starting from the end of the list (one by one to timestamp each of them)
  for (let i = rows.length, j = 1, row; i >= 2 && j <= nb; i--, j++) {
    row = rows[i - 1];
    vlist.deleteRow(i);
    placeholder = `##voucher${j}##`;
    // row[0] is the voucher
    docBody.replaceText(placeholder, row[0]);
    // add the timestamp
    row[1] = Utilities.formatDate(new Date(), 'Europe/Paris', 'yyyy/MM/dd  HH:mm:ss.SSS');
    row[2] = '';
    // Following data need to be written 1 time only
    if (j === 1) {
      row[3] = fdate;
      row[4] = user;
      row[5] = grp;
      row[6] = documentUrl;
    }
    // Append the row to the used list
    used.appendRow(row);
  }
  // Count remaining vouchers en send an alert if <= config.lowlimit
  rows = vlist.getDataRange().getValues();
  let vouchersLeft = rows.length - 1;
  if (vouchersLeft <= config.lowlimit) {sendAlertEmail(vouchersLeft);}

  // Format inserted data inside the used Sheet (merge - valign - borders - columns auto resize)
  let lastRow = used.getLastRow();
  let range = `D${firstRow}:G${lastRow}`;
  // merge & align
  used.getRange(range).mergeVertically().setVerticalAlignment('middle').setHorizontalAlignment('center');
  range = `A${firstRow}:G${lastRow}`;
  // borders
  used.getRange(range).setBorder(true, true, true, true, null, null);
  // autoresize colums
  used.autoResizeColumns(1, 7);
  
  // Delete unused placeholders in the Document
  for (let i = nb + 1; i <= 25; i++) {
    placeholder = `##voucher${i}##`;
    docBody.replaceText(placeholder, '');
  }

  let search = null;
  let tables = [];
  // Extract all the tables inside the Document
  while (search = docBody.findElement(DocumentApp.ElementType.TABLE, search)) {
      tables.push(search.getElement().asTable());
  }
  // Delete all empty rows from the Document tables
  tables.forEach(function (table) {
      let trows = table.getNumRows();
      // Iterate through each row of the table
      for (let r = trows - 1; r >= 0; r--) {
          // If the table row contains no text, delete it
          if (table.getRow(r).getText().replace(/\s/g, '') === '') {
              table.removeRow(r);
          }
      }
  });

  // Show the ready to print Document link in a modal dialog
  SpreadsheetApp.getActive().toast(`${nb} vouchers réservés pour le groupe ${grp} pour le ${fdate} par ${user}`);
  html = '<html><head><style>* {font-family: "Google Sans",Roboto,RobotoDraft,Helvetica,Arial,sans-serif;}</style></head>'
    + '<body><h1><a href="' + documentUrl + '" target="_blank">Ouvrir le document</a></h1>'
    + '<h3>Une fois ouvert, le document peut être modifié et/ou imprimé.</h3>'
    + '<p>Le lien du document est également accessible via la feuille "Utilisés".</p>'
    + '<div style="margin: 80px auto auto 200px;">'
    + '<input type="button" value="Fermer" id="btnclose" onclick="google.script.host.close();" style=" width: 80px; height: 30px;" /></div>'
    + '</body></html>';
  ui = HtmlService.createHtmlOutput(html);
  SpreadsheetApp.getUi().showModalDialog(ui, title);
}

function sendAlertEmail(nbleft) {
  Logger.log(`sendAlertEmail a démarré avec le paramètre nbleft=${nbleft}`);
  let subject = 'Alerte CEFIM_PEDAGO Vouchers : Liste épuisée';
  let body = '<html><body><h1 style="color: red;">La liste de vouchers CEFIM_PEDAGO disponibles arrive à épuisement.</h1>'
    + '<h2>Il reste <b>' + nbleft + ' vouchers disponibles</b> dans la liste courante.</h2>'
    + '<h3><p>Options :</p>'
    + '<ul><li><a href="https://46.247.250.13:666//" target="_blank">'
    + 'Se connecter à l\'inteface web du pfSense CEFIM_PEDAGO afin de générer un nouveau Roll</a></li>'
    + '<li><a href="https://docs.google.com/spreadsheets/d/12vdKWwv6jeDFzN9X8V79do9gQrcitEgQPXLvzj6H91w" target="_blank">'
    + 'Ouvrir la liste de secours pour ajout rapide de vouchers</a></li>'
    + '<li><a href="https://docs.google.com/spreadsheets/d/16eqNvG-Z5y9pHuQbCb80A3K3q3gIcX9S6Ja_7TwtFZ0/edit#gid=1505767989" target="_blank">'
    + 'Ouvrir la liste régulière pour vérifications</a></li></ul></h3></body></html>';
  MailApp.sendEmail({
    to:config.email,
    subject:subject,
    htmlBody:body,
    name:'CEFIM_PEDAGO - Vouchers alerte'
  });
}
```

Form.html :

```javascript
<!DOCTYPE html>
<html>
  <head>
    <base target="_top">
    <style>
      * {font-family: "Google Sans",Roboto,RobotoDraft,Helvetica,Arial,sans-serif;}
      #info {font-size: 14px; color: red; margin-bottom: 10px;}
      p {font-weight: 600;}
      label {display: inline-block; width: 210px;}
      label::after {content: " *"; color: red;}
      input {display: inline-block; width: 260px; color: blue;}
      #date {width: 120px;}
      #nb {width: 40px;}
      .sep {font-size: 10px;}
      .msg {display: none; color: red; font-size: 10px; margin-left: 110px;}
      #btnsubmit, #btncancel {width: 210px; margin: 0 12px 0 12px; padding: 5px 0;}
      #loading {display: none;}
      #loadtxt {position: absolute; top: 2px; left: 2px;}
      #loadimg {position: relative;}
    </style>
  </head>
  <body>
    <div id="form">
      <p>Les vouchers CEFIM_PEDAGO sont valides 5 jours</p>
      <hr />
      <div id="info">* Requis</div>
      <form id="resaForm">
        <label for="grp">Nom ou Groupe</label>
        <input type="text" id="grp" name="group" />
        <div id="badgrp" class="msg">
          <p>Indiquer un nom de personne ou de groupe</p>
        </div>
        <div id="sepgrp" class="sep"><p>&nbsp;</p></div>
        <label for="date">Date</label>
        <input type="date" id="date" name="date" />
        <div id="baddate" class="msg">
          <p>Choisir une date</p>
        </div>
        <div id="sepdate" class="sep"><p>&nbsp;</p></div>
        <label for="nb">Nombre de vouchers (1-25)</label>
        <input type="number" min="1" max="25" id="nb" name="nb" />
        <div id="badnb" class="msg">
          <p>Choisir un nombre entre 1 et 25</p>
        </div>
        <div id="sepnb" class="sep"><p>&nbsp;</p></div>
        <hr /><br />
        <input type="button" value="Annuler" id="btncancel"
            onclick="google.script.host.close();" />
        <input type="button" value="Valider" id="btnsubmit"
            onclick="submitForm();" />
      </form>
    </div>
    <script>
      window.onload = function() {
        document.getElementById("grp").focus();
      }
      // Called right after the form is submited
      function submitForm() {
        let err = 0;
        let grp = document.getElementById("grp").value;
        if (grp === "") {
          document.getElementById("badgrp").style.display = "block";
          document.getElementById("sepgrp").style.display = "none";
          err += 1;
        } else {
          document.getElementById("badgrp").style.display = "none";
          document.getElementById("sepgrp").style.display = "block";
        }
        let dat = document.getElementById("date").value;
        if (dat === "") {
          document.getElementById("baddate").style.display = "block";
          document.getElementById("sepdate").style.display = "none";
          err += 1;
        } else {
          document.getElementById("baddate").style.display = "none";
          document.getElementById("sepdate").style.display = "block";
        }
        let num = document.getElementById("nb").value;
        if ((num < 1) || (num > 25)) {
          document.getElementById("badnb").style.display = "block";
          document.getElementById("sepnb").style.display = "none";
          err += 1;
        } else {
          document.getElementById("badnb").style.display = "none";
          document.getElementById("sepnb").style.display = "block";
        }
        if (err > 0) {return;}
        google.script.run
          .openLoadingModal();
        google.script.run
          .withSuccessHandler(onSubmitSuccess)
          .createDocumentFromFormData(document.getElementById("resaForm"));
      }
      // Called when the form is successfully submited - google.script.run is asynchronous
      function onSubmitSuccess(/*serverFunctionOutput, userObj*/) {
        google.script.run
          .withSuccessHandler(onLoadSuccess)
          .openLoadingModal();
      }
      // Called when the process is finished
      function onLoadSuccess() {
        google.script.host.close();
      }
    </script>
  </body>
</html>
```

Loading.html :

```javascript
<!DOCTYPE html>
<html>
  <head>
    <base target="_top">
    <style>
      * {font-family: "Google Sans",Roboto,RobotoDraft,Helvetica,Arial,sans-serif;}
      img {
        display: block;
        margin-left: auto;
        margin-right: auto;
        width: 90%;
      }
      h2 {
        position: absolute;
        top: 2px;
        left: 50px;
      }
    </style>
  </head>
  <body>
    <div id="loading">
      <img id="loadimg" src="https://lh3.googleusercontent.com/M7YzZMHlX9FO4tQC_o3FbCHXzA1GpYKSmP1h-w0EeGR40CNppuVzEkNZio8lRI9ZwLM=w2400" title="Loading..." style="" />
      <h2 id="loadtxt">Patientez svp</h2>
    </div>
  </body>
</html>
```
