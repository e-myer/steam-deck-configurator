#! /usr/bin/bash

install_deckyloader() {
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
}

install_cryoutilities() {
    if [ ! -d $HOME/.cryo_utilities ]
    then
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh | bash -s --
    else
        echo "cryoutilities is already installed"
    fi
}

install_emudeck() {
    if [ ! -d $HOME/emudeck ]
    then
    sh -c 'curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash'
    else
    echo "emudeck is already installed"
    fi
}

install_refind() {
    #Install and set up rEFInd botloader
    mkdir -p $HOME/deck_setup/build
    cd $HOME/deck_setup/build

    #check for a folder called "SteamDeck_rEFInd"
    if [ -d "$HOME/deck_setup/build/SteamDeck_rEFInd"] #if the folder SteamDeck_rEFInd exists
    then
        git_status="$(git -C $HOME/deck_setup/build/SteamDeck_rEFInd pull)" #update refind git, the rEFInd readme reccomends doing git status  instead, but I think that that is wrong
    else
        git -C $HOME/deck_setup/build/SteamDeck_rEFInd clone https://github.com/jlobue10/SteamDeck_rEFInd/
    fi
    
    chmod +x $HOME/deck_setup/build/SteamDeck_rEFInd/install-GUI.sh
    $HOME/deck_setup/build/SteamDeck_rEFInd/install-GUI.sh
}

fix_barrier() {
echo "Are you using auto config for the ip address? (y/n)"
read barrier_auto_config
if [ $barrier_auto_config != y ] || [ $barrier_auto_config != n ]
then
echo "error, invalid input"
elif [ $barrier_auto_config == n ]
ip_address=$(read -p "input server ip address from the barrier app") #do these with kde dialogs later
fi

touch $HOME/.config/systemd/user/barrier.service
cat > $HOME/.config/systemd/user/barrier.service << EOL
[Unit]
Description=Barrier
After=graphical.target
StartLimitIntervalSec=400
StartLimitBurst=3

[Service]
Type=simple
ExecStart=/usr/bin/flatpak run -p --command="barrierc" com.github.debauchee.barrier --no-restart --no-tray --no-daemon --debug INFO --name steamdeck${ip_address}
Restart=always
RestartSec=20

[Install]
WantedBy=default.target
EOL

systemctl --user enable barrier
systemctl --user start barrier
barrier_status=$(systemctl --user status barrier)

echo "Applied fix, turn off SSL on both the server and host, if Barrier still doesn't work, chck if you are connected on the same wifi network, and set windows resolution to 100%"
}

#apps
install_corekeyboard="flatpak install org.cubocore.CoreKeyboard" # CoreKeyboard
install_barrier="flatpak install flathub com.github.debauchee.barrier" # Barrier
install_heroic_games="flatpak install flathub com.heroicgameslauncher.hgl" #Heroic Launcher
install_ProtonUp-QT="flatpak install flathub net.davidotek.pupgui2" #Proton GE
install_BoilR="flatpak install flathub io.github.philipk.boilr" #BoilR
install_Flatseal="flatpak install flathub com.github.tchx84.Flatseal" #Flatseal