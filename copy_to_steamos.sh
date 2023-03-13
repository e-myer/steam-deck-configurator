#! /usr/bin/bash

cp -r ./{functions.sh,configure_deck.sh,SteamDeck_rEFInd} $HOME/

mkdir $HOME/.deck_setup
mkdir $HOME/.deck_setup/applications
cp -vr functions.sh configure_deck.sh SteamDeck_rEFInd $HOME/.deck_setup/
cp -v ../Steam-ROM-Manager-2.3.40.AppImage $HOME/.deck_setup/applications
chmod +x $HOME/.deck_setup/functions.sh $HOME/.deck_setup/configure_deck.sh $HOME/.deck_setup/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/SteamDeck_rEFInd/install-GUI.sh