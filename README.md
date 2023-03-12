# steam-deck-configurator

This is a project to assist in installing and configuring various programs in the Steam Deck.

This project auto configures

- DeckyLoader
- CryoUtilities
- Emudeck
- rEFInd Bootloader
- Barrier

And installs

- Firefox
- CoreKeyboard
- Heroic Games
- ProtonUp-QT
- BoilR
- Flatseal

# Installation Instrictions
```
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git
cd steam-deck-configurator
chmod +x ./configure_deck.sh
```

# Run instructions
Go to the repo and edit the configure_deck.sh file, with something like `nano ./configure_deck.sh`, add a hashtag before the tasks that you don't want to run, and remove the hashtag, if it exists, before the tasks that you do want to run. Also edit the `echo` lines to reflect the changes

then run `./configure_deck.sh` in a terminal

# General Steam Deck Notes

## Installing SteamOS

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- After reimmaging steam deck, don't press reboot. Instead press cancel, shutdown, remove the usb stick, then boot.
