#!/bin/bash

# ==============================================================================
# NOM DU SCRIPT : GeoIP.sh
# DESCRIPTION    : Analyse et géolocalise les adresses IP d'une liste IPSet.
# VERSION        : 1.0
# ==============================================================================

# --- CONFIGURATION ---
# Nom de la liste ipset que vous souhaitez analyser
LISTE_CIBLE="Deny"
# Titre stylisé pour l'affichage
TITRE="GeoIP"

# COULEURS
CYAN='\033[0;36m'
OR='\033[0;33m'
BLANC='\033[1;37m'
RESET='\033[0m'

# --- VÉRIFICATION DES DÉPENDANCES ---
# Le script installe les outils manquants automatiquement (nécessite sudo)
for outil in figlet geoiplookup; do
    if ! command -v $outil &> /dev/null; then
        echo -e "${OR}[!] Outil manquant : $outil. Installation en cours...${RESET}"
        if [ "$outil" == "geoiplookup" ]; then
            sudo apt-get update && sudo apt-get install geoip-bin -y &> /dev/null
        else
            sudo apt-get update && sudo apt-get install $outil -y &> /dev/null
        fi
    fi
done

clear

# --- AFFICHAGE DU LOGO ---
echo -e "${CYAN}"
figlet "$TITRE"
echo -e "${RESET}"

# Récupération du nombre total d'entrées dans IPSet
nb_ip=$(ipset list "$LISTE_CIBLE" 2>/dev/null | grep "Number of entries" | awk '{print $4}')

# Sécurité : arrêt du script si la liste n'existe pas ou est inaccessible
if [ -z "$nb_ip" ]; then
    echo -e "${OR}[!] Erreur : Impossible de lire la liste '$LISTE_CIBLE'.${RESET}"
    echo -e "${OR}[?] Vérifiez que la liste existe avec la commande : ipset list${RESET}"
    exit 1
fi

echo -e "${OR}==========================================${RESET}"
echo -e "${BLANC}   ANALYSE DE LA LISTE : ${LISTE_CIBLE}${RESET}"
echo -e "${OR}==========================================${RESET}"
echo -e "${CYAN}Total d'adresses détectées : ${BLANC}$nb_ip${RESET}\n"

# En-tête du tableau de résultats
printf "${BLANC}%-20s | %-20s${RESET}\n" "ADRESSE IP" "PAYS D'ORIGINE"
echo "------------------------------------------"

liste_pays_brute=""

# Extraction des IPs : on cible les lignes après le mot "Members:"
ips_extraites=$(ipset list "$LISTE_CIBLE" | tail -n $nb_ip)

for adresse in $ips_extraites; do
    # Localisation via la base de données locale geoip-bin
    # On utilise awk pour extraire uniquement le nom complet du pays
    pays_detecte=$(geoiplookup "$adresse" | awk -F', ' '{print $2}')

    # Gestion des adresses inconnues ou privées (ex: 192.168.x.x)
    if [ -z "$pays_detecte" ] || [[ "$pays_detecte" == *"not found"* ]]; then
        pays_detecte="Inconnu / Privé"
    fi

    # Affichage de la ligne courante
    printf "${CYAN}%-20s${RESET} | ${BLANC}%-20s${RESET}\n" "$adresse" "$pays_detecte"
    
    # Stockage pour le calcul des statistiques
    liste_pays_brute+="$pays_detecte\n"
done

echo -e "${OR}------------------------------------------${RESET}"

# --- SECTION STATISTIQUES GLOBALES ---
echo -e "\n${OR}=== RÉSUMÉ PAR PAYS ===${RESET}"

# Traitement : suppression des lignes vides, tri, comptage et tri décroissant
echo -e "$liste_pays_brute" | sed '/^$/d' | sort | uniq -c | sort -rn | while read total nom_pays; do
    echo -e "${BLANC}$nom_pays : ${CYAN}$total${RESET}"
done

echo -e "${OR}==========================================${RESET}"

# Pause avant de quitter et nettoyage de l'écran
read -p "    [Appuyer sur Entrée pour quitter]"
clear
