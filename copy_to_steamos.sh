#! /usr/bin/bash

mkdir -p $HOME/.deck_setup/applications $HOME/.deck_setup/steam-deck-configurator $HOME/.deck_setup/rEFInd_saved_configs
cp -vr functions.sh configure_deck_cli.sh configure_deck_at_once.sh configure_deck_gui.sh SteamDeck_rEFInd $HOME/.deck_setup/steam-deck-configurator
cp -v ../Steam-ROM-Manager-2.3.40.AppImage $HOME/.deck_setup/applications
cp -vr ../rEFInd_configs $HOME/.deck_setup/rEFInd_configs
chmod +x $HOME/.deck_setup/functions.sh $HOME/.deck_setup/configure_deck_gui.sh $HOME/.deck_setup/configure_deck_cli.sh $HOME/.deck_setup/configure_deck_at_once.sh $HOME/.deck_setup/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/SteamDeck_rEFInd/install-GUI.sh
