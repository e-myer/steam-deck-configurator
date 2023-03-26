# steam-deck-configurator

This is a project to assist in installing and configuring various programs in the Steam Deck.

This project auto configures

- DeckyLoader
- CryoUtilities
- Emudeck
- rEFInd Bootloader
- Barrier
- Flathub

And installs

- Firefox
- CoreKeyboard
- Heroic Games
- ProtonUp-QT
- BoilR
- Flatseal
- Steam ROM Manager

# Installation Instrictions

### If installing from USB

Open a terminal in the directory of the USB

```
cd steam-deck-configurator
chmod +x ./copy_to_steamos.sh
./copy_to_steamos.sh
cd $HOME/.deck_setup
```
To clone the repo to the usb, for contributers, run

```
git clone --recurse-submodules git@github.com:e-myer/steam-deck-configurator.git
```

Alternatively, you can copy this one liner and paste it into your terminal, and run it

```
cd steam-deck-configurator && chmod +x ./copy_to_steamos.sh && ./copy_to_steamos.sh && cd $HOME/.deck_setup
```

### If cloning from GitHub

```
mkdir -p $HOME/.deck_setup
cd $HOME/.deck_setup
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git
cd steam-deck-configurator
chmod +x ./configure_deck.sh
```

# Run instructions
Go into the steam-deck-configurator directory and run
`./configure_deck.sh`

If you are dualbooting, run the windows.ps1 file in Windows.

# Configuration

To edit the default tasks, edit the configure_deck.sh and change the "on" and "off" texts in the "options" array

# General Steam Deck Notes

## Installing SteamOS

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- After reimaging steam deck, don't press reboot. Instead press cancel, shutdown, remove the usb stick, then boot.
- Flash your USB with the file "steamdeck-recovery-4.img.bz2", not the IMG file inside it.
- If flashing with a usb is slow, try flashing with a high speed micro sd card.
- Clonezilla can be used to clone a configured steam deck and easily replicate the setup in another steam deck.
