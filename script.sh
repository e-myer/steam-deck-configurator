#! /usr/bin/bash

#update all apps
sudo pacman -Syu

#update flatpaks
flatpak update -y

#install apps
#flatpaks
flatpak install org.cubocore.CoreKeyboard -y # CoreKeyboard
flatpak install flathub com.github.debauchee.barrier -y # Barrier
flatpak install flathub com.heroicgameslauncher.hgl -y #Heroic Launcher
flatpak install flathub net.davidotek.pupgui2 -y #Proton GE
flatpak install flathub io.github.philipk.boilr -y #BoilR
flatpak install flathub com.github.tchx84.Flatseal -y #Flatseal

#scripts

#install deckyloader if latest version isn't installed
RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )

if [ -f $HOME/deckyloader_installed_version ]

then
  DECKYLOADER_INSTALLED_VERSION=$(cat $HOME/deckyloader_installed_version)
  echo "DeckyLoader Latest Version is $VERSION"
  echo "DeckyLoader Installed Version is $VERSION"
    if [ $VERSION != $DECKYLOADER_INSTALLED_VERSION ];
    then
      echo "Installing Latest Version"
      curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh | sh
      echo $VERSION > ~/deckyloader_installed_version
    else
      echo "Latest Version of DeckyLoader is already installed"
    fi
else
  curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh | sh
  echo $VERSION > ~/deckyloader_installed_version
fi

#install cryoutilities if not installed
if [ ! -d $HOME/.cryo_utilities ]
then
curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh | bash -s --
else
echo "cryoutilities is already installed"
fi

#Install Emudeck if not installed
if [ ! -d $HOME/emudeck ]
then
sh -c 'curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash'
else
echo "emudeck is already installed"
fi