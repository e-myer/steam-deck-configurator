#! /usr/bin/bash

source ./functions.sh

#update all apps
sudo pacman -Syu

#update flatpaks
flatpak update -y

#install apps
install_corekeyboard
install_barrier
install_heroic_games
install_ProtonUp
install_BoilR
install_Flatseal

install_deckyloader
install_cryoutilities
install_emudeck
install_refind
#fix_barrier