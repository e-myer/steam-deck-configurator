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
cd $HOME/.deck_setup
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git
cd steam-deck-configurator
chmod +x ./configure_deck.sh
```

Alternatively, you can clone the repo to a USB, and mount it to the folder at $HOME/.deck_setup.

To do so, first create the folder with `mkdir $HOME/.deck_setup`, identify the USB drive by running `lsblk`, then mount it to $HOME/.deck_setup. For example if the usb is mounted at /dev/sdc1, then run the command `sudo mount /dev/sdc1 /home/deck/.deck_setup` in a terminal

And make the nessecary files executable using
```
chmod -v +x $HOME/.deck_setup/steam-deck-configurator/functions.sh $HOME/.deck_setup/steam-deck-configurator/configure_deck.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh $HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh
```
Proton GE and the Bauh AppImage needs to be downloaded separatley and placed in the steam-deck-configurator folder for the Proton GE and Bauh tasks to work.

## Run instructions
Go into the steam-deck-configurator directory and run `./configure_deck.sh` in a terminal

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
- If you run the reccomended settings on CryoByte33's steam-deck-utilities tool, you might want to increase the UMA Frame Buffer Size. To do so, first shut the Steam Deck down, then hold the power button and the volume up button until you hear a sound, then let it go. In the screen that appears, go to Setup Utility on the lower right. Go to Advanced and change the UMA Frame Buffer size from 1G to 4G. Then press the Steam Deck's select button and then press Yes to save and exit. The Steam Deck will reboot. To configrm the change, you can go to Settings, System and scrolling down to VRAM Size. There is more information on this tweak in [CryoByte33's video](https://www.youtube.com/watch?v=C9EjXYZUqUs) on his tool. Note: Red Dead Redemption 2 doesn't work with tweak set


## Post install scripts and tools for Windows on Steam Deck
- [SteamDeckPostInstallScript by ryanrudolfoba](https://github.com/ryanrudolfoba/SteamDeckPostInstallScript)
- [SteamDeckAutomatedInstall by CelesteHeartsong](https://github.com/CelesteHeartsong/SteamDeckAutomatedInstall)
- [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil)

## Credits
- This project includes code from [CryoByte33's steam-deck-utilities](https://github.com/CryoByte33/steam-deck-utilities/blob/main/LICENSE). The line to install CryoUtilities has been copied and modified from the desktop file in his repo.
- This project includes the Bauh desktop file and the Bauh icon, copied from the [Bauh repo](https://github.com/vinifmor/bauh)
- This project includes a dualboot config file created by [jlobue10's SteamDeck_rEFInd tool](https://github.com/jlobue10/SteamDeck_rEFInd), and OS Icons, taken from his [repo](https://github.com/jlobue10/SteamDeck_rEFInd)
