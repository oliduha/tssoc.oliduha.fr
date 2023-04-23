+++
archetype = "example"
title = "PowerShell"
weight = 3
+++

---

## **Scripts PowerShell**

---

### 1. Script PowerShell d’import d’utilisateurs dans un AD à partir d’un .csv

```powershell
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# Script d'import d'utisateur dans un AD depuis un .csv
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$users = import-csv -path "C:\Users\Olivier\Desktop\import.csv" -delimiter ";"
foreach($user in $users)
{
    $nom = $user.nom
    $prenom= $user.prenom
    $nomComplet = $prenom + " " +$nom
    $idSAM = $prenom.substring(0,1) + $nom
    $id = $idSAM + "@tssr.lan"
    $pass= ConvertTo-SecureString "1234" -AsPlaintext -Force
    
    New-ADuser -name $idSAM -DisplayName $nomComplet -givenname $prenom -surname $nom -Path "OU=usagers,DC=tssr,DC=lan" -UserPrincipalName $id -AccountPassword $pass -Enabled $true
}
```

{{% notice warning %}}
**Pour l'option `-Path` de la commande `New-ADuser` l'ordre des OU et DC est important (surtout dans le cas d'OU imbiquées) : il faut commencer par l'extrémité et décrire le chemin en remontant dans l'arborescence.**

*Par exemple* : pour une sous-OU telle que `users\si\network` du domaine `tssr.lan` il faudrait indiquer : `-Path "OU=network,OU=si,OU=users,DC=tssr,DC=lan"`.
{{% /notice %}}

---

### 2. Script PowerShell d’ajout d’utilisateurs fictifs dans un AD pour tests

*Cette variante du script précédent ne nécessite pas de fichier .csv et génère des noms d'utilisateurs fictifs*

```powershell
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# Script d’ajout d’utilisateurs fictifs dans un AD pour tests
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
for($num=1; $num -le 50; $num++)
{
    $nom = "utilisateur"
    $nomComplet = $nom.ToTitleCase + " " + $num
    $idSAM = $nom + $num
    $id = $idSAM + "@lyon2024.intra"
    $mail = $idSAM + "@lyon.com"
    $city = "Lyon"
    $company = "Worldskills"
    $group = "Finances"
    $pass= ConvertTo-SecureString "P@ssw0rd" -AsPlaintext -Force
    
    New-ADuser -name $idSAM -DisplayName $nomComplet -Path "OU=Worldskills,OU=Utilisateurs,OU=auto,DC=lyon2024,DC=intra" -UserPrincipalName $id -AccountPassword $pass -Enabled $true -MailAddress $mail -City $city -Company $company
    Add-ADGroupMember -identity "Finances" -Members $idSaAM
```

---
