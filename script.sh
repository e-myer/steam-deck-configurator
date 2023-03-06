#! /usr/bin/bash

source ./functions.sh

cat ./script.sh
echo -e "\n\n These are the commands that will be run, continue (y/n)?"
read continue

if [[ "$continue" == "n" || ! "$continue" == "y" ]];
then
    echo "exiting..."
    exit 0
fi

#update all apps
sudo pacman -Syu

#update flatpaks
flatpak update -y

#install apps
install_corekeyboard -y
install_barrier -y
install_heroic_games -y
install_ProtonUp_QT -y
install_BoilR -y
install_Flatseal -y

install_deckyloader
install_cryoutilities
install_emudeck
install_refind
#fix_barrier