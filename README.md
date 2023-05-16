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

Run the below code in a terminal

```
mkdir deck_setup # create a folder for the project, it could be named anything
cd deck_setup # go into that folder
git clone --recurse-submodules https://github.com/e-myer/steam-deck-configurator.git # clone this repository
cd steam-deck-configurator # go into the repository
chmod +x ./configure_deck.sh # make the configure_deck.sh file executable
```

For the Proton GE task to work, the Proton GE TAR needs to be downloaded placed in the parent folder of the steam-deck-configurator folder.  
For the Bauh task to work, the Bauh AppImage needs to be downloaded and placed in a folder called "applications" in the parent folder of the steam-deck-configurator folder.

## Run instructions
Go into the steam-deck-configurator directory and run `./configure_deck.sh` in a terminal.

## Configuration

- To edit the preselected tasks, edit the configure_deck.sh file and change the "on" and "off" texts in the "options" array
- To add a task
  - Create a function in the function.sh file
  - Add the function to the end of the file, like this `tasks_array["Function title"]="function_name"`, replacing "function title" and "function name" with the function's title and name.
  - Add the entry to the configure_deck.sh file, in the tasks_array list, like this `"${tasks_array[Function title]}" "Function title" off \`, to have the entry preselected in the checklist dialog, replace "off" with "on", like this `"${tasks_array[Function title]}" "Function title" on \`
  - If the task is at the very end of the list in the configure_deck.sh file, then don't put a backslash and instead add a closing bracket, like this `"${tasks_array[Function title]}" "Function title" off)`

## General Steam Deck Notes

- Ensure you have the [latest steam deck recovery image](https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3).
- SHA256 Checksum - steamdeck-recovery-4.img.bz2 = ac9c58fdd319d46120444875172eb56382098634f2075729f51426ba5cb788c6
- Flash your USB with the file "steamdeck-recovery-4.img.bz2", not the IMG file inside it.
- If flashing with a usb is slow, try flashing with a high speed micro sd card.
- It is recommended to install the rEFInd bootloader after installing Windows
- Clonezilla can be used to clone a configured steam deck and easily replicate the setup in another steam deck.
- You can use Steam Link for remote desktop.
- If you run the reccomended settings on CryoByte33's steam-deck-utilities tool, you might want to increase the UMA Frame Buffer Size. To do so, first shut the Steam Deck down, then hold the power button and the volume up button until you hear a sound, then let it go. In the screen that appears, go to Setup Utility on the lower right. Go to Advanced and change the UMA Frame Buffer size from 1G to 4G. Then press the Steam Deck's select button and then press Yes to save and exit. The Steam Deck will reboot. To configrm the change, you can go to Settings, System and scrolling down to VRAM Size. There is more information on this tweak in [CryoByte33's video](https://www.youtube.com/watch?v=C9EjXYZUqUs) on his tool. Note: Red Dead Redemption 2 doesn't work with the tweak set.


## Post install scripts and tools for Windows on Steam Deck
- [SteamDeckAutomatedInstall by CelesteHeartsong](https://github.com/CelesteHeartsong/SteamDeckAutomatedInstall)
- [Chris Titus Tech's Windows Utility](https://github.com/ChrisTitusTech/winutil)

## Credits
- This project includes code from [CryoByte33's steam-deck-utilities](https://github.com/CryoByte33/steam-deck-utilities/blob/main/LICENSE). The line to install CryoUtilities has been copied and modified from the desktop file in his repo.
- This project includes the Bauh desktop file and the Bauh icon, copied from the [Bauh repo](https://github.com/vinifmor/bauh)
- This project includes a dualboot config file created by [jlobue10's SteamDeck_rEFInd tool](https://github.com/jlobue10/SteamDeck_rEFInd), and OS Icons, taken from his [repo](https://github.com/jlobue10/SteamDeck_rEFInd)
- Credit to jlobue10 for creating the rEFInd installer script. This project uses my fork, which only contains some minor edits to make it compatible with this repo.
