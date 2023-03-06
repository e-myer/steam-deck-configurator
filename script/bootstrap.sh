git -C "$HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd" git init
git -C "$HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd" git submodule update
chmod +x "$HOME/.deck_setup/build/steam-deck-configurator/script.sh"
mkdir -p "$HOME/.deck_setup/"