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
chmod +x ./script.sh
```

# Run instructions
Go to the repo and edit the script.sh file, with something like `nano ./script.sh`, add a hashtag before the tasks that you don't want to run, and remove the hashtag, if it exists, before the tasks that you do want to run. Also edit the `echo` lines to reflect the changes

then run `./script.sh` in a terminal

# General Steam Deck Notes

## Installing SteamOS

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- After reimmaging steam deck, don't press reboot. Instead press cancel, shutdown, remove the usb stick, then boot.
