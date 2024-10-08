#!/bin/bash

# Couleurs pour un affichage visuel amélioré
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Pas de couleur

# Liste des commandes à tester
commands=(
    "./so_long maps/invalid/not_good_char.ber"
    "./so_long maps/invalid/empty_col_1.ber"
    "./so_long maps/invalid/empty_line_1.ber"
    "./so_long maps/invalid/empty_line_2.ber"
    "./so_long maps/invalid/empty_line_3.ber"
    "./so_long maps/invalid/mult_exit.ber"
    "./so_long maps/invalid/mult_play.ber"
    "./so_long maps/invalid/no_coin.ber"
    "./so_long maps/invalid/no_exit.ber"
    "./so_long maps/invalid/no_play.ber"
    "./so_long maps/invalid/no_wall.ber"
    "./so_long maps/invalid/no_access_exit.ber"
    "./so_long maps/invalid/not_access_coin.ber"
    "./so_long maps/invalid/not_rect_map.ber"
    "./so_long maps/invalid/coin_after_exit.ber"
    "./so_long maps/invalid/folder.ber"
    "./so_long maps/invalid/too_big.ber"
)

# Liste des outputs a avoir
right_out=(
    "\e[1;91mError\nThe map contain at least 1 wrong character.\e[0m"
    "\e[1;91mError\nThe map contain at least 1 wrong character.\e[0m"
    "\e[1;91mError\nThe map contain too much '\\n'.\e[0m"
    "\e[1;91mError\nThe map contain too much '\\n'.\e[0m"
    "\e[1;91mError\nThe map contain too much '\\n'.\e[0m"
    "\e[1;91mError\nToo much exit detected.\e[0m"
    "\e[1;91mError\nToo much player detected.\e[0m"
    "\e[1;91mError\nNo collectible detected.\e[0m"
    "\e[1;91mError\nNo exit detected.\e[0m"
    "\e[1;91mError\nNo player detected.\e[0m"
    "\e[1;91mError\nThe map isn't surounded by walls or column empty.\e[0m"
    "\e[1;91mError\nWe can't access exit.\e[0m"
    "\e[1;91mError\nWe can't access all collectibles.\e[0m"
    "\e[1;91mError\nThe map isn't rectangular or line empty.\e[0m"
    "\e[1;91mError\nWe can't access all collectibles.\e[0m"
    "\e[1;91mError\nThere is an issue while reading the map.\e[0m"
    "\e[1;91mError\nThe map will exceed the screen size.\e[0m"
)

# Comparaison des sorties pour une map invalide
echo -e "${BLUE}-------------- Comparaison des sorties pour une map invalide ----------------------${NC}"
echo -e
for i in "${!commands[@]}"; do
    cmd="${commands[$i]}"
    expected_output="${right_out[$i]}"

    echo -e "${BLUE}($i)${NC}${YELLOW} Output of :${NC} $cmd ${YELLOW}\n>>>>>>>>>>> should be :${NC} $expected_output"

    # Exécuter la commande et capturer sa sortie dans une variable et un fichier
    output=$(eval "$cmd")

    # Comparer les sorties nettoyées
    echo -e "${GREEN}Sortie obtenue :${NC} $output"
    echo -e
done

# Tests avec valgrind uniquement pour ton programme
echo -e "${BLUE}-------------- valgrind --leak-check=full --show-leak-kinds=all --trace-children=yes ----------------------${NC}"
echo -e

# Fichier temporaire pour stocker la sortie de Valgrind
temp_file=$(mktemp)

for i in "${!commands[@]}"; do
    cmd="${commands[$i]}"
    valgrind_cmd="valgrind --leak-check=full --show-leak-kinds=all --trace-children=yes $cmd"
    echo -e "${BLUE}($i)${NC}${YELLOW} Valgrind :${NC} $cmd"

    # Exécuter Valgrind et rediriger la sortie vers un fichier temporaire
    eval "$valgrind_cmd" &> "$temp_file"

    # Afficher la sortie complète de Valgrind
    # echo -e "${BLUE}------------ Sortie complète de Valgrind ------------${NC}"
    # cat "$temp_file"

    # Chercher la ligne "total heap usage"
    heap_usage=$(grep "total heap usage:" "$temp_file")

    echo -e "${GREEN}Total heap usage :${NC} $heap_usage"

    # Si aucune ligne n'est trouvée, afficher un message clair
    if [[ -z "$heap_usage" ]]; then
        echo -e "${RED}Erreur : Impossible de trouver 'total heap usage' dans la sortie de Valgrind.${NC}"
    fi
    echo -e
done
