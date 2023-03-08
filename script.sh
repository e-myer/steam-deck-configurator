#! /usr/bin/bash

source ./functions.sh

echo ""

read -p "Please make sure a sudo password is already set before continuing. If you have not set the user\
 or sudo password, please exit this installer with 'Ctrl+c' and then create a password either using 'passwd'\
 from a command line or by using the KDE Plasma User settings GUI. Otherwise, press Enter/Return to continue with the install."
 

echo "
The following changes will be made with this script (hashtag means it is disabled)

Update all apps
Update all flatpaks

Install the following flatpaks:
CoreKeyboard
Barrier
Heroic Launcher
ProtonGE
BoilR
Flatseal

Install & set up the following apps:
deckyloader
cryoutilities
emudeck
refind
#barrier patch

continue? (y/n)"

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
#$install_BoilR -y # comment this out if install_steam_rom_manager is uncommented, install one or the other
$install_Flatseal -y

#functions
install_deckyloader
install_cryoutilities
install_emudeck
install_refind
install_steam_rom_manager # comment this out if $install_BoilR is uncommented, install one or the other
#fix_barrier