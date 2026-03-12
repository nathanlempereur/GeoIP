#!/bin/bash

# ==============================================================================
# NOM DU SCRIPT : GeoIP.sh
# DESCRIPTION    : Analyse IPSet + Géolocalisation + Ports visés (Syslog)
# VERSION        : 1.3
# ==============================================================================

# --- CONFIGURATION ---
LISTE_CIBLE="Deny"
TITRE="GeoIP"
LOG_FILE="/var/log/syslog"

# COULEURS
CYAN='\033[0;36m'
OR='\033[0;33m'
BLANC='\033[1;37m'
RESET='\033[0m'

# --- VÉRIFICATION DES DÉPENDANCES ---
for outil in figlet geoiplookup; do
    if ! command -v $outil &> /dev/null; then
        echo -e "${OR}[!] Outil manquant : $outil. Installation...${RESET}"
        apt-get update && apt-get install geoip-bin figlet -y &> /dev/null
    fi
done

clear

# --- AFFICHAGE DU LOGO ---
echo -e "${CYAN}"
figlet "$TITRE"
echo -e "${RESET}"

nb_ip=$(ipset list "$LISTE_CIBLE" 2>/dev/null | grep "Number of entries" | awk '{print $4}')

if [ -z "$nb_ip" ] || [ "$nb_ip" -eq 0 ]; then
    echo -e "${OR}[!] Erreur : La liste '$LISTE_CIBLE' est vide ou inexistante.${RESET}"
    exit 1
fi

echo -e "${OR}============================================================${RESET}"
echo -e "${BLANC}   ANALYSE : ${LISTE_CIBLE} | SOURCE : ${LOG_FILE}${RESET}"
echo -e "${OR}============================================================${RESET}"
echo -e "${CYAN}Total d'adresses : ${BLANC}$nb_ip${RESET}\n"

# En-tête du tableau (3 colonnes maintenant)
printf "${BLANC}%-18s | %-18s | %-10s${RESET}\n" "ADRESSE IP" "PAYS" "PORT VISÉ"
echo "------------------------------------------------------------"

liste_pays_brute=""
liste_ports_brute=""

# Extraction des IPs
ips_extraites=$(ipset list "$LISTE_CIBLE" | tail -n "$nb_ip")

for adresse in $ips_extraites; do
    # 1. Géolocalisation
    pays_detecte=$(geoiplookup "$adresse" | awk -F', ' '{print $2}')
    [ -z "$pays_detecte" ] || [[ "$pays_detecte" == *"not found"* ]] && pays_detecte="Inconnu"

    # 2. Extraction du Port via Syslog
    # On cherche l'IP, on prend la dernière occurrence, et on isole le port après "port:"
    port_detecte=$(grep "$adresse" "$LOG_FILE" | grep "port:" | tail -n 1 | awk -F'port: ' '{print $2}')
    [ -z "$port_detecte" ] && port_detecte="?"

    # Affichage
    printf "${CYAN}%-18s${RESET} | ${BLANC}%-18s${RESET} | ${OR}%-10s${RESET}\n" "$adresse" "$pays_detecte" "$port_detecte"
    
    # Accumulation pour les stats
    liste_pays_brute+="$pays_detecte\n"
    [[ "$port_detecte" != "?" ]] && liste_ports_brute+="$port_detecte\n"
done

echo -e "${OR}------------------------------------------------------------${RESET}"

# --- SECTION STATISTIQUES ---

# Top des Pays
echo -e "\n${OR}=== RÉSUMÉ PAR PAYS ===${RESET}"
echo -e "$liste_pays_brute" | sed '/^$/d' | sort | uniq -c | sort -rn | while read total nom; do
    echo -e "${BLANC}$nom : ${CYAN}$total${RESET}"
done

# Top des Ports (Nouveau)
echo -e "\n${OR}=== TOP DES PORTS VISÉS ===${RESET}"
if [ -n "$liste_ports_brute" ]; then
    echo -e "$liste_ports_brute" | sed '/^$/d' | sort -n | uniq -c | sort -rn | while read total port; do
        echo -e "${BLANC}Port $port : ${CYAN}$total${RESET}"
    done
else
    echo -e "${BLANC}Aucune donnée de port trouvée dans les logs.${RESET}"
fi

echo -e "${OR}============================================================${RESET}"

read -p "    [Appuyer sur Entrée pour quitter]"
clear
