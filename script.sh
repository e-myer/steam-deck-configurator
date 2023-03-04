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
#flatpaks
flatpak install org.cubocore.CoreKeyboard -y # CoreKeyboard
flatpak install flathub com.github.debauchee.barrier -y # Barrier
flatpak install flathub com.heroicgameslauncher.hgl -y #Heroic Launcher
flatpak install flathub net.davidotek.pupgui2 -y #Proton GE
flatpak install flathub io.github.philipk.boilr -y #BoilR
flatpak install flathub com.github.tchx84.Flatseal -y #Flatseal

install_deckyloader
install_cryoutilities
install_emudeck
install_refind
#fix_barrier