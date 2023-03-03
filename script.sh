#! /usr/bin/bash

source ./functions.sh

test_function
exit 0

CoreKeyboard=org.cubocore.CoreKeyboard
Barrier=com.github.debauchee.barrier
Heroic_Launcher=com.heroicgameslauncher.hgl
ProtonGE=net.davidotek.pupgui2
BoilR=io.github.philipk.boilr #BoilR
Flatseal=com.github.tchx84.Flatseal #Flatseal

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