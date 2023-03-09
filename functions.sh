#! /usr/bin/bash

install_deckyloader() {
    #install deckyloader if latest version isn't installed
    RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
    VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )

    if [ -f "$HOME/.deck_setup/deckyloader_installed_version" ]
    then
        DECKYLOADER_INSTALLED_VERSION=$(cat "$HOME/.deck_setup/deckyloader_installed_version")
        echo "DeckyLoader Latest Version is $VERSION"
        echo "DeckyLoader Installed Version is $VERSION"
            if [ "$VERSION" != "$DECKYLOADER_INSTALLED_VERSION" ];
            then
                echo "Installing Latest Version"
                curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh | sh
                echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
            else
               echo "Latest Version of DeckyLoader is already installed"
            fi
    else
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh | sh
        echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
    fi
}

install_cryoutilities() {
    if [ ! -d "$HOME/.cryo_utilities" ]
    then
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh | bash -s --
    else
        echo "cryoutilities is already installed"
    fi
}

install_emudeck() {
    if [ ! -d "$HOME/emudeck" ]
    then
    sh -c 'curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash'
    else
    echo "emudeck is already installed"
    fi
}

install_refind_GUI() {
    chmod +x "$HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh"
    "$HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

install_refind_bootloader() {
    "$HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd/SteamDeck_rEFInd_install.sh" "$PWD/SteamDeck_rEFInd" #install rEFInd bootloader
}

apply_refind_config() {
    cat "$HOME/.deck_setup/build/steam-deck-configurator/rEFInd_config/refind.conf" # display the config file and ask the user to confirm
    echo "This config will be applied, confirm? (y/n)"
    read confirm
    if [ "$confirm" == y ]
    then
    cp "$HOME/.deck_setup/build/steam-deck-configurator/rEFInd_config/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png}" "$HOME/.SteamDeck_rEFInd/GUI" #copy the refind files from the user directory to where rEFInd expects it to install the config
    "$HOME/.deck_setup/build/steam-deck-configurator/SteamDeck_rEFInd/install_config_from_GUI.sh"
    else
    echo "config not applied"
    fi
}

refind_uninstall_gui() {
    rm -rf ~/SteamDeck_rEFInd
    rm -rf ~/.SteamDeck_rEFInd
    rm -f ~/Desktop/refind_GUI.desktop
}

fix_barrier() {
echo "Are you using auto config for the ip address? (y/n)"
read barrier_auto_config
if [ "$barrier_auto_config" != y ] && [ "$barrier_auto_config" != n ]
then
echo "error, invalid input"
elif [ "$barrier_auto_config" == n ]
then
ip_address=$(read -p "input server ip address from the barrier app")
fi

touch "$HOME/.config/systemd/user/barrier.service"
cat > "$HOME/.config/systemd/user/barrier.service" << EOL
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
systemctl --user status barrier

echo "Applied fix, turn off SSL on both the server and host, if Barrier still doesn't work, chck if you are connected on the same wifi network, and set windows resolution to 100%"
}

#apps
install_firefox="flatpak install flathub org.mozilla.firefox"
install_corekeyboard="flatpak install org.cubocore.CoreKeyboard"
install_barrier="flatpak install flathub com.github.debauchee.barrier"
install_heroic_games="flatpak install flathub com.heroicgameslauncher.hgl"
install_ProtonUp_QT="flatpak install flathub net.davidotek.pupgui2"
install_BoilR="flatpak install flathub io.github.philipk.boilr"
install_Flatseal="flatpak install flathub com.github.tchx84.Flatseal"