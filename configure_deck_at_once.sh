#! /usr/bin/bash

source ./functions.sh

echo ""

read -p "Please make sure a sudo password is already set before continuing. If you have not set the user\
 or sudo password, please exit this installer with 'Ctrl+c' and then create a password either using 'passwd'\
 from a command line or by using the KDE Plasma User settings GUI. Otherwise, press Enter/Return to continue with the install."
 

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
#variables
$install_firefox -y
$install_corekeyboard -y
$install_barrier -y
$install_heroic_games -y
$install_ProtonUp_QT -y
$install_BoilR -y
$install_Flatseal -y
#$add_flathub

#functions
install_deckyloader
install_cryoutilities
install_emudeck
install_refind_all # disable other refind functions if this is enabled
#install_refind_GUI
#install_refind_bootloader
#apply_refind_config
#install_refind
#install_steam_rom_manager"
#uninstall_deckyloader
#fix_barrier
