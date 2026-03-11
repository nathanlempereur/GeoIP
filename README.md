# GeoIP - IPSet Analyzer

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25.svg)
![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)
![Status](https://img.shields.io/badge/status-Libre-orange)

**GeoIP** est un outil en ligne de commande permettant d'analyser et de géolocaliser instantanément toutes les adresses IP contenues dans une liste `ipset` (comme une liste de bannissement `Deny`). 

Il génère un tableau coloré avec la provenance de chaque IP et fournit un résumé statistique des pays les plus représentés.

---

## Caractéristiques

* **Analyse Locale :** Utilise la base de données `geoip-bin`, donc aucune requête API externe n'est envoyée (pas de limite de débit).
* **Design Terminal :** Intégration de `Figlet` pour un logo stylisé et gestion des couleurs ANSI.
* **Statistiques Automatiques :** Classe les pays par volume d'adresses IP détectées.
* **Installation Intelligente :** Vérifie et installe automatiquement les dépendances manquantes (`figlet`, `geoip-bin`).
* **Flexible :** Vous pouvez changer la liste cible (Deny, Blocklist, etc.) directement dans le script.

<img width="595" height="551" alt="image" src="https://github.com/user-attachments/assets/bf6f913c-3ee3-49ee-95fa-4fc34eb251b3" />
<img width="399" height="937" alt="image" src="https://github.com/user-attachments/assets/401504f1-3d7c-4679-b6e3-96f193c1a5ca" />

---

## Installation

1. **Clonez le dépôt :**
   ```bash
   git clone [https://github.com/votre-utilisateur/GeoIP-IPSet-Analyzer.git](https://github.com/nathanlempereur/GeoIP.git)
   cd GeoIP
   ```
   
2. **Rendez le script exécutable :**
   ```bash
   chmod +x GeoIP.sh
   ```
3. ***Prérequis :*** Le script nécessite que ipset soit déjà installé et configuré sur votre machine. Pour l'installer sur Debian/Ubuntu :

---

## Utilisation

Lancez simplement le script en root pour lire vos listes ipset ou mettez la commande 'sudo' sur les lignes qui le requirent.

---

## Contribution & Licence

Ce script est **open-source**. Vous pouvez le modifier et proposer des améliorations via des **Pull Requests**.

**Licence** : Ce projet est sous licence libre. 
**Contact** : contact@nlempereur.ovh

---

### Contact
- Email : **contact@nlempereur.ovh**
- Site web : https://nlempereur.ovh/contact.php

---

Merci d'utiliser **GeoIP** ! 🚀
