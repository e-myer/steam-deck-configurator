#! /usr/bin/bash

mkdir -p $HOME/.deck_setup/applications $HOME/.deck_setup/steam-deck-configurator
cp -vr functions.sh configure_deck_multiple_choice.sh SteamDeck_rEFInd $HOME/.deck_setup/steam-deck-configurator
cp -v ../Steam-ROM-Manager-2.3.40.AppImage $HOME/.deck_setup/applications
chmod +x $HOME/.deck_setup/functions.sh $HOME/.deck_setup/configure_deck_multiple_choice.sh $HOME/.deck_setup/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/SteamDeck_rEFInd/install-GUI.sh
