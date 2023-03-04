#! /usr/bin/bash

source ./functions.sh

#update all apps
sudo pacman -Syu

#update flatpaks
flatpak update -y

#install apps
install_corekeyboard -y
install_barrier -y
install_heroic_games -y
install_ProtonUp -y
install_BoilR -y
install_Flatseal -y

install_deckyloader
install_cryoutilities
install_emudeck
install_refind
#fix_barrier