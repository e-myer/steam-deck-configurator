#! /usr/bin/bash -v

#try flatpak install --sideload=$flatpak_directory flathub org.mozilla.firefox if this doesn't work

print_log() {
    log_message=$1
    log="$task_number/${#chosen_tasks[@]}: ${tasks[$i]}: $log_message"
    echo "$log"
    qdbus $dbusRef setLabelText "$log"
    echo "$log" >> $HOME/.deck_setup/steam-deck-configurator/logs.log
}

update_from_pacman() {
    print_log "Updating apps from Pacman"
    sudo pacman -Syu
}

import_firefox() {
    print_log "Importing Firefoc"
    flatpak install --sideload-repo=$flatpak_directory flathub org.mozilla.firefox
}

import_corekeyboard() {
    print_log "Importing CoreKeyboard"
    flatpak install --sideload-repo=$flatpak_directory flathub org.cubocore.CoreKeyboard
}

import_barrier() {
    print_log "Importing Barrier"
    flatpak install --sideload-repo=$flatpak_directory flathub com.github.debauchee.barrier
}

import_heroic_games() {
    print_log "Importing Heroic Games"
    flatpak install --sideload-repo=$flatpak_directory flathub com.heroicgameslauncher.hgl
}

import_protonup_qt() {
    print_log "Importing ProtonUP QT"
    flatpak install --sideload-repo=$flatpak_directory flathub net.davidotek.pupgui2
}

import_boilr() {
    print_log "Importing BoilR"
    flatpak install --sideload-repo=$flatpak_directory flathub io.github.philipk.boilr
}

import_flatseal() {
    print_log "Importing Flatseal"
    flatpak install --sideload-repo=$flatpak_directory flathub com.github.tchx84.Flatseal
}

import_steam_rom_manager() {
    print_log "Importing Steam ROM Manager"
    flatpak install --sideload-repo=$flatpak_directory flathub com.steamgriddb.steam-rom-manager
}

install_firefox() {
    print_log "Installing Firefox"
    flatpak install flathub org.mozilla.firefox -y
}

install_corekeyboard() {
    print_log "Installing CoreKeyboard"
    flatpak install flathub org.cubocore.CoreKeyboard -y
}

install_barrier() {
    print_log "Installing Barrier"
    flatpak install flathub com.github.debauchee.barrier -y
}

install_heroic_games() {
    print_log "Installing Heroic Games"
    flatpak install flathub com.heroicgameslauncher.hgl -y
}

install_protonUp_qt() {
    print_log "Installing ProtonUP QT"
    flatpak install flathub net.davidotek.pupgui2 -y
}

install_boilr() {
    print_log "Installing BoilR"
    flatpak install flathub io.github.philipk.boilr -y
}

install_flatseal() {
    print_log "Installing Flatseal"
    flatpak install flathub com.github.tchx84.Flatseal -y
}

install_steam_rom_manager() {
    print_log "Installing Steam ROM Manager"
    flatpak install flathub com.steamgriddb.steam-rom-manager -y
}

install_retrodeck() {
    print_log "Installing RetroDeck"
    flatpak install flathub net.retrodeck.retrodeck -y
}

add_flathub() {
    print_log "Adding Flathub"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

run_cryo_utilities_reccommended() {
    print_log "Running Cryoutilities with reccommended settings"
    sudo $HOME/.cryo_utilities/cryo_utilities recommended
}

update_flatpaks() {
    print_log "Updating Flatpaks"
    flatpak update -y
}

set_up_import_flatpaks() {
flatpak update
flatpak remote-modify --collection-id=org.flathub.Stable flathub
flatpak update
}

export_flatpaks() {
print_log "exporting flatpaks"
kdialog --msgbox "Select the root of your usb"
flatpaks_export_usb=$(kdialog --getexistingdirectory /)
print_log "updating flatpaks"
flatpak update
flatpak remote-modify --collection-id=org.flathub.Stable flathub
flatpak update
print_log "adding Firefox to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks org.mozilla.firefox
print_log "adding CoreKeyboard to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks org.cubocore.CoreKeyboard
print_log "adding barrier to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks com.github.debauchee.barrier
print_log "adding heroic games to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks com.heroicgameslauncher.hgl
print_log "adding proton up qt to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks net.davidotek.pupgui2
print_log "adding boilr to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks io.github.philipk.boilr
print_log "adding flatseal to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks com.github.tchx84.Flatseal
print_log "adding steam rom manager to usb"
flatpak --verbose create-usb $flatpaks_export_usb/flatpaks com.steamgriddb.steam-rom-manager
}

install_deckyloader() {
    if [ -f "$HOME/.deck_setup/deckyloader_installed_version" ]
    then
        print_log "Checking if latest version of DeckyLoader is installed"
        RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
        VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )
        DECKYLOADER_INSTALLED_VERSION=$(cat "$HOME/.deck_setup/deckyloader_installed_version")
        print_log "DeckyLoader Latest Version is $VERSION"
        print_log "DeckyLoader Installed Version is $VERSION"
            if [ "$VERSION" != "$DECKYLOADER_INSTALLED_VERSION" ];
            then
                print_log "Installing Latest Version"
                curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$HOME/.deck_setup/deckyloader_install_release.sh"
                chmod +x "$HOME/.deck_setup/deckyloader_install_release.sh"
                $HOME/.deck_setup/deckyloader_install_release.sh
                echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
            else
               print_log "Latest Version of DeckyLoader is already installed"
            fi
    else
        print_log "Installing DeckyLoader"
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$HOME/.deck_setup/deckyloader_install_release.sh"
        chmod +x "$HOME/.deck_setup/deckyloader_install_release.sh"
        $HOME/.deck_setup/deckyloader_install_release.sh
        echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
   fi
}

uninstall_deckyloader() {
    print_log "Uninstalling DeckyLoader"
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh  --output "$HOME/.deck_setup/deckyloader_uninstaller.sh"
    chmod +x "$HOME/.deck_setup/deckyloader_uninstaller.sh"
    $HOME/.deck_setup/deckyloader_uninstaller.sh
    rm -f "$HOME/.deck_setup/deckyloader_installed_version"
}

install_cryoutilities() {
    print_log "checking if cryoutilities is installed"
    if [ ! -d "$HOME/.cryo_utilities" ]
    then
        print_log "cryoutilities is not installed, installing"
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh --output "$HOME/.deck_setup/cryoutilities_install.sh"
        chmod +x "$HOME/.deck_setup/cryoutilities_install.sh"
        $HOME/.deck_setup/cryoutilities_install.sh
    else
        print_log "cryoutilities is already installed"
    fi
}

install_emudeck() {
    print_log "checking if emudeck is installed"
    if [ ! -d "$HOME/emudeck" ]
    then
    print_log "emudeck is not installed, installing"
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh --output "$HOME/.deck_setup/emudeck_install.sh"
    chmod +x "$HOME/.deck_setup/emudeck_install.sh"
    $HOME/.deck_setup/emudeck_install.sh
    else
    print_log "emudeck is already installed"
    fi
}

install_refind_GUI() {
    print_log "installing rEFInd GUI"
    chmod +x "$HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh"
    "$HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

install_refind_bootloader() {
    print_log "Installing rEFInd bootloader"
    "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
}

choose_refind_config() {
    configs=$(find $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs/ -mindepth 1 -maxdepth 1 -type d -printf :%f)
    IFS=':' read -r -a configs_array <<< "$configs" # split the input to an array
    for i in ${configs_array[@]}
    do
    (( index ++ ))
#    echo $index \""$i"\" off
    config_list="$config_list $index \""$i"\" off"
    done
    refind_config_choice=$(kdialog --radiolist "Select a config to apply:" $config_list)
    refind_config_apply_dir=$HOME/.deck_setup/steam-deck-configurator/rEFInd_configs/${configs_array[$refind_config_choice]}
}

apply_refind_config() {
    print_log "applying rEFInd config"
    num_of_dirs=$(find $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs -mindepth 1 -maxdepth 1 -type d | wc -l) #get amount of folders (configs) in the .deck_setup/refind_configs folder
    if [ "$num_of_dirs" -gt 1 ]; then #if there is more than 1 folder (or more than one config)
    choose_refind_config
    else
    refind_config_apply_dir=$(find $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs -mindepth 1 -maxdepth 1 -type d) # else, find the one folder and set the refind config apply dir to that
    fi

    cp -v "$refind_config_apply_dir"/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$HOME/.SteamDeck_rEFInd/GUI" #copy the refind files from the user directory to where rEFInd expects it to install the config
    if [ $? == 1 ];
    then
    print_log "error, config not applied"
    else
    "$HOME/.SteamDeck_rEFInd/install_config_from_GUI.sh"
    print_log "config applied"
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
    cp -v $HOME/.SteamDeck_rEFInd/GUI/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$refind_configs_path/$config_name" #copy files saved by rEFInd GUI to a custom directory
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
    print_log "running all install rEFInd tasks"
    install_refind_GUI
    install_refind_bootloader
    apply_refind_config
}

refind_uninstall_gui() {
    print_log "uninstalling rEFInd GUI"
    rm -rf ~/SteamDeck_rEFInd
    rm -rf ~/.SteamDeck_rEFInd
    rm -f ~/Desktop/refind_GUI.desktop
}

install_proton_ge_in_steam() {
    #this assumes the native steam is installed, not the flatpak
    mkdir -p ~/.steam/root/compatibilitytools.d
    tar -xf $HOME/.deck_setup/steam-deck-configurator/GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
    print_log "Proton GE installed, please restart Steam"
}

fix_barrier() {
print_log "Fixing Barrier"
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

echo "Applied fix, turn off SSL on both the server and host, if Barrier still doesn't work, check if you are connected on the same wifi network, and set windows resolution to 100%"
}

declare -A tasks_array
tasks_array["Update from pacman"]="update_from_pacman"
tasks_array["Add Flathub if it does not exist"]="add_flathub"
tasks_array["Update Flatpaks"]="update_flatpaks"
tasks_array["Set up import Flatpaks"]="set_up_import_flatpaks"
tasks_array["Import Firefox"]="import_firefox"
tasks_array["Import Corekeyboard"]="import_corekeyboard"
tasks_array["Import Barrier"]="import_barrier"
tasks_array["Import Heroic_games"]="import_heroic_games"
tasks_array["Import ProtonUp_QT"]="import_protonup_qt"
tasks_array["Install Proton GE in Steam"]="install_proton_ge_in_steam"
tasks_array["Import BoilR"]="import_boilr"
tasks_array["Import Flatseal"]="import_flatseal"
tasks_array["Import Steam ROM Manager"]="import_steam_rom_manager"
tasks_array["Install Firefox"]="install_firefox"
tasks_array["Install Corekeyboard"]="install_corekeyboard"
tasks_array["Install Barrier"]="install_barrier"
tasks_array["Install Heroic Games"]="install_heroic_games"
tasks_array["Install ProtonUp_QT"]="install_protonUp_qt"
tasks_array["Install BoilR"]="install_boilr"
tasks_array["Install Flatseal"]="install_flatseal"
tasks_array["Install Steam Rom Manager"]="install_steam_rom_manager"
tasks_array["Install DeckyLoader"]="install_deckyloader"
tasks_array["Install Cryoutilities"]="install_cryoutilities"
tasks_array["Run CryoUtilities with reccommended settings"]="run_cryo_utilities_reccommended"
tasks_array["Install Emudeck"]="install_emudeck"
tasks_array["Install RetroDeck"]="install_retrodeck"
tasks_array["Install rEFInd GUI"]="install_refind_GUI"
tasks_array["Install rEFInd bootloader"]="install_refind_bootloader"
tasks_array["Apply rEFInd config"]="apply_refind_config"
tasks_array["Save rEFInd config"]="save_refind_config"
tasks_array["Uninstall Deckyloader"]="uninstall_deckyloader"
tasks_array["Fix Barrier"]="fix_barrier"

