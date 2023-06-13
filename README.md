# steam-deck-configurator

This is a project to assist in installing and configuring various programs in the Steam Deck.


This project performs tasks such as
- Updating Flatpaks
- Exporting and importing Flatpaks
- Adding the Flathub Repo
- Installing Bauh *
- Installing and running CryoUtilities
- Installing DeckyLoader
- Intalling EmuDeck
- Installing ProtonGE in Steam *
- Installing the rEFInd Bootloader
- Installing Flatpaks from a configurable list, by default, the list includes
    - Firefox
    - Steam Rom Manager
    - Heroic Games Launcher
    - Lutris
    - Flatseal
    - RetroDeck
    - Steam Rom Manger
    - Barrier
    - BoilR
    - CoreKeyboard
    - ProtonUp-QT

\* This requires the appropriate file to be downloaded and placed in the appropriate folder first

## Installation Instrictions

Run the code below in a terminal

```
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git # clone this repository
cd steam-deck-configurator # go into the repository
chmod +x ./configure_deck.sh # make the configure_deck.sh file executable
```

For the Proton GE task to work, the Proton GE TAR needs to be downloaded placed in the steam-deck-configurator folder.  
For the Bauh task to work, the Bauh AppImage needs to be downloaded and placed in a folder called "applications" in the steam-deck-configurator folder.

## Update Instructions

To update the project, open the steam-deck-configurator folder in a terminal and run the code below.

```
git pull
git submodule update --remote --merge
```

## Run instructions
Go into the steam-deck-configurator directory and run `./configure_deck.sh` in a terminal.

## Configuration

- To add a task
  - Create a function in the functions.sh file
  - Add the name of the function to the "set_menu" function in the "menu" variable. Like this `"function_name" "Function Title" off`, replacing "function title" and "function name" with the function's title and name.
  - If the task is at the very end of the list, then move the single apostrophe to the end.

- To remove a task from the dialog
  - Remove the line with the task from the "menu" variable in the "set menu" function.
  - If the removed task was at the very and of the list, add a single apostrophe to the end of the list.
 
## General Steam Deck Notes

- Ensure you have the [latest Steam Deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- SHA256 Checksum - steamdeck-recovery-4.img.bz2 = ac9c58fdd319d46120444875172eb56382098634f2075729f51426ba5cb788c6
- Flash your USB with the file "steamdeck-recovery-4.img.bz2", not the IMG file inside it.
- If flashing with a usb is slow, try flashing with a high speed micro sd card.
- It is recommended to install the rEFInd bootloader after installing other operating systems on the Steam Deck - https://github.com/jlobue10/SteamDeck_rEFInd/issues/61#issuecomment-1534707831.
- Clonezilla can be used to clone a configured Steam Deck and easily replicate the setup in another Steam Deck.
- You can use Steam Link for remote desktop.
- If you run the reccomended settings on CryoByte33's steam-deck-utilities tool, you might want to increase the UMA Frame Buffer Size. To do so, first shut the Steam Deck down, then hold the power button and the volume up button until you hear a sound, then let it go. In the screen that appears, go to Setup Utility on the lower right. Go to Advanced and change the UMA Frame Buffer size from 1G to 4G. Then press the Steam Deck's select button and then press Yes to save and exit. The Steam Deck will reboot. To configrm the change, you can go to Settings, System and scrolling down to VRAM Size. There is more information on this tweak in [CryoByte33's video](https://www.youtube.com/watch?v=C9EjXYZUqUs) on his tool. Note: Red Dead Redemption 2 doesn't work with the tweak set.

## Other useful projects for the Steam Deck
- [NonSteamLaunchers-On-Steam-Deck](https://github.com/moraroy/NonSteamLaunchers-On-Steam-Deck) - Automatic installation of the most popular launchers in your Steam Deck.

## Post install scripts and tools for Windows on the Steam Deck
- [SteamDeckAutomatedInstall by CelesteHeartsong](https://github.com/CelesteHeartsong/SteamDeckAutomatedInstall)
- [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil)

## Credits
- This project includes code from [CryoByte33's steam-deck-utilities](https://github.com/CryoByte33/steam-deck-utilities/blob/main/LICENSE). The line to install CryoUtilities has been copied and modified from the desktop file in his repo.
- This project includes the Bauh desktop file and the Bauh icon, copied from the [Bauh repo](https://github.com/vinifmor/bauh)
- This project includes a dualboot config file created by [jlobue10's SteamDeck_rEFInd tool](https://github.com/jlobue10/SteamDeck_rEFInd), and OS Icons, taken from his [repo](https://github.com/jlobue10/SteamDeck_rEFInd)
- Credit to jlobue10 for creating the [SteamDeck_rEFInd script](https://github.com/jlobue10/SteamDeck_rEFInd). This project uses my fork, which only contains some minor edits to make it compatible with this repo.
