if [ ! -d $HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd/.git ]
then
git submodule init
git submodule update
fi
chmod +x "$HOME/.deck_setup/build/steam-deck-configurator/script.sh"