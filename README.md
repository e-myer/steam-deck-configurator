# steam-deck-configurator

This is a project to assist in installing and configuring various programs in the Steam Deck.

This project auto configures

- DeckyLoader
- CryoUtilities
- Emudeck
- rEFInd Bootloader
- Barrier
- Flathub
- Proton GE

And installs

- Firefox
- CoreKeyboard
- Heroic Games
- ProtonUp-QT
- BoilR
- Flatseal
- Steam ROM Manager
- RetroDeck
- Bauh

## Installation Instrictions

Create a directory in the home folder called .deck_setup or run`mkdir $HOME/.deck_setup`

Clone this repository to the folder inside it


```
mkdir -p $HOME/.deck_setup
cd $HOME/.deck_setup
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git
cd steam-deck-configurator
chmod +x ./configure_deck.sh
```

Alternatively, you can clone the repo to a USB, and mount it to the folder at $HOME/.deck_setup.

To do so, first create the folder with `mkdir $HOME/.deck_setup`, identify the drive by running `lsblk`, then mount it to $HOME/.deck_setup. For example if the usb is mounted at /dev/sdc1, then run the command `sudo mount /dev/sdc1 /home/deck/.deck_setup` in a terminal

And make the nessecary files executable using
```
chmod -v +x $HOME/.deck_setup/steam-deck-configurator/functions.sh $HOME/.deck_setup/steam-deck-configurator/configure_deck.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh
```
Proton GE and the Bauh AppImage needs to be downloaded separatley and placed in the steam-deck-configurator folder for the Proton GE and Bauh tasks to work.

## Run instructions
Go into the steam-deck-configurator directory and run
`./configure_deck.sh`

## Configuration

To edit the default tasks, edit the configure_deck.sh file and change the "on" and "off" texts in the "options" array

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
