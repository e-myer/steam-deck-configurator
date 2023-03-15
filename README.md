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
Set a password if you haven't done so with `passwd`, then run the commands below

```
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git
cd steam-deck-configurator
chmod +x ./configure_deck_multiple_choice.sh
```

# Run instructions
Go into the steam-deck-configurator directory and run
`./configure_deck_multiple_choice.sh`

then run `./configure_deck.sh` in a terminal

If you are dualbooting, run the windows.ps1 file in Windows.

# General Steam Deck Notes

## Installing SteamOS

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- After reimmaging steam deck, don't press reboot. Instead press cancel, shutdown, remove the usb stick, then boot.
