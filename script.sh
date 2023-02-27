#! /usr/bin/bash

#update all apps
sudo pacman -Syu

#update flatpaks
flatpak update -y

#install apps
flatpak install org.cubocore.CoreKeyboard # CoreKeyboard
flatpak install flathub com.github.debauchee.barrier # Barrier
flatpak install flathub com.heroicgameslauncher.hgl #Heroic Launcher