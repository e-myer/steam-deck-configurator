#! /usr/bin/bash

mkdir -p $HOME/.deck_setup/applications $HOME/.deck_setup/steam-deck-configurator
cp -vr functions.sh configure_deck_gui.sh SteamDeck_rEFInd rEFInd_configs $HOME/.deck_setup/steam-deck-configurator/
cp -v ../applications/Steam-ROM-Manager-2.3.40.AppImage $HOME/.deck_setup/applications/
chmod +x $HOME/.deck_setup/steam-deck-configurator/functions.sh $HOME/.deck_setup/steam-deck-configurator/configure_deck_gui.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh
