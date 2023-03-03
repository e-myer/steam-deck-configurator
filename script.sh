#! /usr/bin/bash

source ./functions.sh

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