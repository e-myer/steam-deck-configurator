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

## Installation Instrictions

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

## Run instructions
Go into the steam-deck-configurator directory and run
`./configure_deck.sh`

## Configuration

To edit the default tasks, edit the configure_deck.sh and change the "on" and "off" texts in the "options" array

## General Steam Deck Notes

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- After reimaging steam deck, don't press reboot. Instead press cancel, shutdown, remove the usb stick, then boot.
- Flash your USB with the file "steamdeck-recovery-4.img.bz2", not the IMG file inside it.
- If flashing with a usb is slow, try flashing with a high speed micro sd card.
- Clonezilla can be used to clone a configured steam deck and easily replicate the setup in another steam deck.
- SHA256 Checksum - steamdeck-recovery-4.img.bz2 = ac9c58fdd319d46120444875172eb56382098634f2075729f51426ba5cb788c6
- You can use Steam Link for remote desktop


## Post install scripts and tools for Windows on Steam Deck
- [SteamDeckPostInstallScript by ryanrudolfoba](https://github.com/ryanrudolfoba/SteamDeckPostInstallScript)
- [SteamDeckAutomatedInstall by CelesteHeartsong](https://github.com/CelesteHeartsong/SteamDeckAutomatedInstall)
- [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil)
