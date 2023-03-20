#! /usr/bin/bash

install_firefox="flatpak install flathub org.mozilla.firefox"
install_corekeyboard="flatpak install flathub org.cubocore.CoreKeyboard"
install_barrier="flatpak install flathub com.github.debauchee.barrier"
install_heroic_games="flatpak install flathub com.heroicgameslauncher.hgl"
install_ProtonUp_QT="flatpak install flathub net.davidotek.pupgui2"
install_BoilR="flatpak install flathub io.github.philipk.boilr"
install_Flatseal="flatpak install flathub com.github.tchx84.Flatseal"
install_steam_rom_manager="flatpak install flathub com.steamgriddb.steam-rom-manager"
add_flathub="flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

install_deckyloader() {
    if [ -f "$HOME/.deck_setup/deckyloader_installed_version" ]
    then
        echo "Checking if latest version of DeckyLoader is installed"
        RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
        VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )
        DECKYLOADER_INSTALLED_VERSION=$(cat "$HOME/.deck_setup/deckyloader_installed_version")
        echo "DeckyLoader Latest Version is $VERSION"
        echo "DeckyLoader Installed Version is $VERSION"
            if [ "$VERSION" != "$DECKYLOADER_INSTALLED_VERSION" ];
            then
                echo "Installing Latest Version"
                curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$HOME/.deck_setup/deckyloader_install_release.sh"
                chmod +x "$HOME/.deck_setup/deckyloader_install_release.sh"
                $HOME/.deck_setup/deckyloader_install_release.sh
                echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
            else
               echo "Latest Version of DeckyLoader is already installed"
            fi
    else
        echo "Installing DeckyLoader"
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$HOME/.deck_setup/deckyloader_install_release.sh"
        chmod +x "$HOME/.deck_setup/deckyloader_install_release.sh"
        $HOME/.deck_setup/deckyloader_install_release.sh
        echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
    fi
}

uninstall_deckyloader() {
    echo "Uninstalling DeckyLoader"
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh  --output "$HOME/.deck_setup/deckyloader_uninstaller.sh"
    chmod +x "$HOME/.deck_setup/deckyloader_uninstaller.sh"
    $HOME/.deck_setup/deckyloader_uninstaller.sh
    rm -f "$HOME/.deck_setup/deckyloader_installed_version"
}

install_cryoutilities() {
    echo "checking if cryoutilities is installed"
    if [ ! -d "$HOME/.cryo_utilities" ]
    then
        echo "cryoutilities is not installed, installing"
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh --output "$HOME/.deck_setup/cryoutilities_install.sh"
        chmod +x "$HOME/.deck_setup/cryoutilities_install.sh"
        $HOME/.deck_setup/cryoutilities_install.sh
    else
        echo "cryoutilities is already installed"
    fi
}

install_emudeck() {
    echo "checking if emudeck is installed"
    if [ ! -d "$HOME/emudeck" ]
    then
    echo "emudeck is not installed, installing"
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh --output "$HOME/.deck_setup/emudeck_install.sh"
    chmod +x "$HOME/.deck_setup/emudeck_install.sh"
    $HOME/.deck_setup/emudeck_install.sh
    else
    echo "emudeck is already installed"
    fi
}

install_refind_GUI() {
    echo "installing rEFInd GUI"
    chmod +x "$HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh"
    "$HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

install_refind_bootloader() {
    echo "Installing rEFInd bootloader"
    "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
}

apply_refind_config() {
    echo "applying rEFInd config"
    num_of_dirs=$(find $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs -mindepth 1 -maxdepth 1 -type d | wc -l) #get amount of folders (configs) in the .deck_setup/refind_configs folder
    if [ "$num_of_dirs" -gt 1 ]; then #if there is more than 1 folder (or more than one config)
    refind_config_apply_dir=$(kdialog --getexistingdirectory $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs) # show a dialog to choose the folder you want (the config you want)
    else
    refind_config_apply_dir=$(find $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs -mindepth 1 -maxdepth 1 -type d) # else, find the one folder and set the refind config apply dir to that
    fi

    cp "$refind_config_apply_dir"/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$HOME/.SteamDeck_rEFInd/GUI" #copy the refind files from the user directory to where rEFInd expects it to install the config
    if [ $? == 1 ];
    then
    echo "error, config not applied"
    else
    "$HOME/.SteamDeck_rEFInd/install_config_from_GUI.sh"
    echo "config applied"
    fi
}

save_refind_config() {
    kdialog --msgbox "A config must be created using the rEFInd GUI first, by editing the config and clicking on \"Create Config\", continue?"
    if [ $? == 0 ];
    then
    config_name=$(kdialog --title "Name of config" --inputbox "What would you like to name your config?")
    white_space=" |'"
        if [[ $config_name =~ $white_space ]]
        then
        echo "error, name cannot contain spaces"
        kdialog --error "error, name cannot contain spaces"
        exit 1
        fi
    kdialog --msgbox "Please select the rEFInd_configs folder in your USB"
    refind_configs_path=$(kdialog --getexistingdirectory /)
    mkdir -p "$refind_configs_path/$config_name"
    cp $HOME/.SteamDeck_rEFInd/GUI/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$refind_configs_path/$config_name" #copy files saved by rEFInd GUI to a custom directory
        if [ $? == 0 ];
        then
        echo "config saved to $refind_configs_path/$config_name"
        kdialog --msgbox "config saved to $refind_configs_path/$config_name"
        else
        cp_error=$?
        echo "error: $cp_error, config not saved"
        kdialog --error "error: $cp_error, config not saved"
        fi
    fi
}

install_refind_all() {
    echo "running all install rEFInd tasks"
    install_refind_GUI
    install_refind_bootloader
    apply_refind_config
}

refind_uninstall_gui() {
    echo "uninstalling rEFInd GUI"
    rm -rf ~/SteamDeck_rEFInd
    rm -rf ~/.SteamDeck_rEFInd
    rm -f ~/Desktop/refind_GUI.desktop
}

fix_barrier() {
echo "Fixing Barrier"
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

tasks=( "sudo pacman -Syu" \
"$add_flathub" \
"flatpak update -y" \
"$install_firefox -y" \
"$install_corekeyboard -y" \
"$install_barrier -y" \
"$install_heroic_games -y" \
"$install_ProtonUp_QT -y" \
"$install_BoilR -y" \
"$install_Flatseal -y" \
"$install_steam_rom_manager -y" \
"install_deckyloader" \
"install_cryoutilities" \
"install_emudeck" \
"install_refind_all" \
"install_refind_GUI" \
"install_refind_bootloader" \
"apply_refind_config" \
"save_refind_config" \
"uninstall_deckyloader" \
"fix_barrier" )