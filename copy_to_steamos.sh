#! /usr/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

mkdir -p $HERE/Applications $HERE/steam-deck-configurator
#cp -vr functions.sh configure_deck.sh SteamDeck_rEFInd rEFInd_configs desktop_icons ../GE-Proton7-51.tar.gz ../flatpaks $HOME/.deck_setup/steam-deck-configurator/
#cp -v ../applications/bauh-0.10.5-x86_64.AppImage $HOME/.deck_setup/Applications/
chmod +x $HERE/functions.sh $HERE/configure_deck.sh $HERE/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HERE/SteamDeck_rEFInd/install-GUI.sh
