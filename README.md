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
chmod +x ./script.sh
```

# Run instructions
Go to the repo and run
`./script.sh`

# General Steam Deck Notes

## Installing SteamOS

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- After reimmaging steam deck, don't press reboot. Instead press cancel, shutdown, remove the usb stick, then boot.
