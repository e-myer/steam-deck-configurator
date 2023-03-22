#! /usr/bin/bash

mkdir -p $HOME/.deck_setup/applications $HOME/.deck_setup/steam-deck-configurator
cp -vr functions.sh configure_deck.sh SteamDeck_rEFInd rEFInd_configs desktop_icons ../GE-Proton7-51.tar.gz ../flatpaks $HOME/.deck_setup/steam-deck-configurator/
cp -v ../applications/bauh-0.10.5-x86_64.AppImage $HOME/.deck_setup/Applications/
chmod +x $HOME/.deck_setup/steam-deck-configurator/functions.sh $HOME/.deck_setup/steam-deck-configurator/configure_deck.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh
