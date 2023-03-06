#! /usr/bin/bash

source ./functions.sh

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
$install_BoilR -y
$install_Flatseal -y

#functions
install_deckyloader
install_cryoutilities
install_emudeck
install_refind
#fix_barrier