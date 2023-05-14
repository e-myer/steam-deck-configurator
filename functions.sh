#! /usr/bin/bash

print_log() {
    log_message=$1
    log="$task_number/${#chosen_tasks[@]}: ${tasks[$i]}: $log_message"
    echo -e "$log"
    qdbus $dbusRef setLabelText "$log"
    echo "$log" >> $HOME/.deck_setup/logs.log
}

update_from_pacman() {
    print_log "Updating apps from Pacman"
    sudo pacman -Syu
}

add_flathub() {
    print_log "Adding Flathub"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

update_flatpaks() {
    print_log "Updating Flatpaks"
    flatpak update -y
}

set_up_import_and_export_flatpaks() {
    flatpak remote-modify --collection-id=org.flathub.Stable flathub
}

import_firefox() {
    print_log "Importing Firefox"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub org.mozilla.firefox
}

import_corekeyboard() {
    print_log "Importing CoreKeyboard"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub org.cubocore.CoreKeyboard
}

import_barrier() {
    print_log "Importing Barrier"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub com.github.debauchee.barrier
}

import_heroic_games() {
    print_log "Importing Heroic Games"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub com.heroicgameslauncher.hgl
}

import_protonup_qt() {
    print_log "Importing ProtonUP QT"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub net.davidotek.pupgui2
}

import_boilr() {
    print_log "Importing BoilR"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub io.github.philipk.boilr
}

import_flatseal() {
    print_log "Importing Flatseal"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub com.github.tchx84.Flatseal
}

import_steam_rom_manager() {
    print_log "Importing Steam ROM Manager"
    flatpak install --sideload-repo=$HOME/.deck_setup/flatpaks flathub com.steamgriddb.steam-rom-manager
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

install_bauh() {
    print_log "Installing Bauh"
    if [ -f $HOME/.deck_setup/applications/bauh-0.10.5-x86_64.AppImage ]; then
    cp -v $HOME/.deck_setup/applications/bauh-0.10.5-x86_64.AppImage $HOME/Applications/
    chmod -v +x $HOME/Applications/bauh-0.10.5-x86_64.AppImage
    cat <<- EOF > $HOME/.local/share/applications/bauh.desktop
	[Desktop Entry]
	Type=Application
	Name=Applications (bauh)
	Name[pt]=Aplicativos (bauh)
	Name[es]=Aplicaciones (bauh)
	Name[ca]=Aplicacions (bauh)
	Name[it]=Applicazioni (bauh)
	Name[de]=Anwendungen (bauh)
	Name[ru]=Приложения (bauh)
	Name[tr]=Paket Yönetici (bauh)
	Categories=System;
	Comment=Install and remove applications (AppImage, Arch, Flatpak, Snap, Web)
	Comment[pt]=Instale e remova aplicativos (AppImage, Arch, Flatpak, Snap, Web)
	Comment[es]=Instalar y eliminar aplicaciones (AppImage, Arch, Flatpak, Snap, Web)
	Comment[it]=Installa e rimuovi applicazioni (AppImage, Arch, Flatpak, Snap, Web)
	Comment[de]=Anwendungen installieren und entfernen (AppImage, Arch, Flatpak, Snap, Web)
	Comment[ca]=Instal·lar i eliminar aplicacions (AppImage, Arch, Flatpak, Snap, Web)
	Comment[ru]=Установка и удаление приложений (AppImage, Arch, Flatpak, Snap, Web)
	Comment[tr]=Uygulama yükle/kaldır (AppImage, Arch, Flatpak, Snap, Web)
	Exec=$HOME/Applications/bauh-0.10.5-x86_64.AppImage
	Icon=bauh
	EOF
    cp -v $HOME/.deck_setup/steam-deck-configurator/desktop_icons/bauh.svg $HOME/.local/share/icons/
    else
    print_log "bauh appimage doesn't exist in this folder, download it first, skipping..."
    sleep 3
    fi
}

run_cryo_utilities_recommended() {
    print_log "Running Cryoutilities with recommended settings, please enter your sudo password in the terminal"
    sudo $HOME/.cryo_utilities/cryo_utilities recommended
}

export_flatpaks() {
    print_log "exporting flatpaks"
    mkdir -p $HOME/.deck_setup/flatpaks

    readarray -t flatpak_names < <(flatpak list --app --columns=name)
    readarray -t flatpak_ids < <(flatpak list --app --columns=application)

    for name in "${flatpak_names[@]}"
    do
    if [ -z "$number" ]; then
    number=0
    else
    ((number ++))
    fi
    menu+=("$number" "$name" off)
    done

    readarray -t chosen_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${menu[@]}")
    echo ${chosen_flatpaks[@]}

    for flatpak in "${chosen_flatpaks[@]}"
    do
    echo "${flatpak_ids[$flatpak]}"
    print_log "adding $flatpak to usb"
    flatpak --verbose create-usb $HOME/.deck_setup/flatpaks "${flatpak_ids[$flatpak]}"
    done
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
                chmod -v +x "$HOME/.deck_setup/deckyloader_install_release.sh"
                $HOME/.deck_setup/deckyloader_install_release.sh
                echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
            else
               print_log "Latest Version of DeckyLoader is already installed"
            fi
    else
        print_log "Installing DeckyLoader"
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$HOME/.deck_setup/deckyloader_install_release.sh"
        chmod -v +x "$HOME/.deck_setup/deckyloader_install_release.sh"
        $HOME/.deck_setup/deckyloader_install_release.sh
        echo "$VERSION" > "$HOME/.deck_setup/deckyloader_installed_version"
   fi
}

uninstall_deckyloader() {
    print_log "Uninstalling DeckyLoader"
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh  --output "$HOME/.deck_setup/deckyloader_uninstaller.sh"
    chmod -v +x "$HOME/.deck_setup/deckyloader_uninstaller.sh"
    $HOME/.deck_setup/deckyloader_uninstaller.sh
    rm -f "$HOME/.deck_setup/deckyloader_installed_version"
}

install_cryoutilities() {
    print_log "checking if cryoutilities is installed"
    if [ ! -d "$HOME/.cryo_utilities" ]
    then
        print_log "cryoutilities is not installed, installing"
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh --output "$HOME/.deck_setup/cryoutilities_install.sh"
        chmod -v +x "$HOME/.deck_setup/cryoutilities_install.sh"
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
    chmod -v +x "$HOME/.deck_setup/emudeck_install.sh"
    $HOME/.deck_setup/emudeck_install.sh
    else
    print_log "emudeck is already installed"
    fi
}

update_submodules() {
    git submodule update --remote --merge
}

install_refind_GUI() {
    print_log "installing rEFInd GUI"
    chmod -v +x "$HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh"
    "$HOME/.deck_setup/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

install_refind_bootloader() {
    print_log "Installing rEFInd bootloader"
    "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
}

apply_refind_config() {
    print_log "applying rEFInd config"
    if [ ! -d $HOME/.deck_setup/rEFInd_configs ]
    then
    cp -vr $HOME/.deck_setup/steam-deck-configurator/rEFInd_configs $HOME/.deck_setup/rEFInd_configs
    fi
    num_of_dirs=$(find $HOME/.deck_setup/rEFInd_configs -mindepth 1 -maxdepth 1 -type d | wc -l) #get amount of folders (configs) in the .deck_setup/refind_configs folder
    if [ "$num_of_dirs" -gt 1 ]; then
    refind_config=$(zenity --file-selection --title="select a file" --filename=$HOME/.deck_setup/rEFInd_configs/ --directory)
    else
    refind_config=$(find $HOME/.deck_setup/rEFInd_configs -mindepth 1 -maxdepth 1 -type d) # else, find the one folder and set the refind config dir to that
    fi

    print_log "applying config: $refind_config"

    cp -v "$refind_config"/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$HOME/.SteamDeck_rEFInd/GUI" #copy the refind files from the user directory to where rEFInd expects it to install the config
    if [ $? == 1 ];
    then
    print_log "error, config not applied"
    else
    "$HOME/.SteamDeck_rEFInd/install_config_from_GUI.sh"
    print_log "config applied"
    fi
}

save_refind_config() {
    print_log "saving rEFInd config"
    kdialog --msgbox "A config must be created using the rEFInd GUI first, by editing the config and clicking on \"Create Config\", continue?"
    if [ $? == 0 ];
    then
    config_save_path=$(zenity --file-selection --save --title="Save config (whitespace is not allowed)" --filename=$HOME/.deck_setup/)
    mkdir -p "$config_save_path"
    cp -v $HOME/.SteamDeck_rEFInd/GUI/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$config_save_path" #copy files saved by rEFInd GUI to a chosen directory
        if [ $? == 0 ];
        then
        echo "config saved to $config_save_path"
        kdialog --msgbox "config saved to $config_save_path"
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
    rm -vrf ~/SteamDeck_rEFInd
    rm -vrf ~/.SteamDeck_rEFInd
    rm -vf ~/Desktop/refind_GUI.desktop
}

check_for_updates_proton_ge() {
    RELEASE=$(curl -s 'https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
    VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )
    proton_ge_downloaded_version="$(basename $HOME/.deck_setup/GE-Proton*.tar.gz)"
    if [ ! "$proton_ge_downloaded_version" == "$VERSION.tar.gz" ]; then 
    print_log "ProtonGE not up to date, \n Latest Version: $VERSION.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
    else
    print_log "ProtonGE is up to date"
    fi
}

install_proton_ge_in_steam() {
    if compgen -G "$HOME/.deck_setup/GE-Proton*.tar.gz" > /dev/null; then
    mkdir -p ~/.steam/root/compatibilitytools.d
    tar -xf $HOME/.deck_setup/GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
    print_log "Proton GE installed, please restart Steam"
    else
    print_log "Proton GE doesn't exist in this folder, please download it first, skipping..."
    sleep 3
    fi
}

install_non_steam_launchers() {
    print_log "running non steam launchers installer"
    curl https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh --output "$HOME/.deck_setup/NonSteamLaunchers.sh"
    chmod -v +x $HOME/.deck_setup/NonSteamLaunchers.sh
    "$HOME/.deck_setup/NonSteamLaunchers.sh"
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
	cat <<- EOF > $HOME/.config/systemd/user/barrier.service
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
	EOF

    systemctl --user enable barrier
    systemctl --user start barrier
    systemctl --user status barrier

    print_log "Applied fix, turn off SSL on both the server and host, if Barrier still doesn't work, check if you are connected on the same wifi network, and set windows resolution to 100%"
}

declare -A tasks_array
tasks_array["Update from pacman"]="update_from_pacman"
tasks_array["Add Flathub if it does not exist"]="add_flathub"
tasks_array["Update Flatpaks"]="update_flatpaks"
tasks_array["Set up import and export Flatpaks"]="set_up_import_and_export_flatpaks"
tasks_array["Import Firefox"]="import_firefox"
tasks_array["Import Corekeyboard"]="import_corekeyboard"
tasks_array["Import Barrier"]="import_barrier"
tasks_array["Import Heroic_games"]="import_heroic_games"
tasks_array["Import ProtonUp_QT"]="import_protonup_qt"
tasks_array["Install Proton GE in Steam"]="install_proton_ge_in_steam"
tasks_array["Import BoilR"]="import_boilr"
tasks_array["Import Flatseal"]="import_flatseal"
tasks_array["Import Steam ROM Manager"]="import_steam_rom_manager"
tasks_array["Install Bauh"]="install_bauh"
tasks_array["Install Firefox"]="install_firefox"
tasks_array["Install Corekeyboard"]="install_corekeyboard"
tasks_array["Install Barrier"]="install_barrier"
tasks_array["Install Heroic Games"]="install_heroic_games"
tasks_array["Install ProtonUp_QT"]="install_protonUp_qt"
tasks_array["Install BoilR"]="install_boilr"
tasks_array["Install Flatseal"]="install_flatseal"
tasks_array["Install Steam Rom Manager"]="install_steam_rom_manager"
tasks_array["Install DeckyLoader"]="install_deckyloader"
tasks_array["Uninstall DeckyLoader"]="uninstall_deckyloader"
tasks_array["Install rEFInd All"]="install_refind_all"
tasks_array["Uninstall rEFInd GUI"]="refind_uninstall_gui"
tasks_array["Check for Proton GE Updates"]="check_for_updates_proton_ge"
tasks_array["Install Cryoutilities"]="install_cryoutilities"
tasks_array["Run CryoUtilities with recommended settings"]="run_cryo_utilities_recommended"
tasks_array["Install Emudeck"]="install_emudeck"
tasks_array["Install RetroDeck"]="install_retrodeck"
tasks_array["Update Submodules"]="update_submodules"
tasks_array["Install rEFInd GUI"]="install_refind_GUI"
tasks_array["Install rEFInd bootloader"]="install_refind_bootloader"
tasks_array["Apply rEFInd config"]="apply_refind_config"
tasks_array["Save rEFInd config"]="save_refind_config"
tasks_array["Install Non Steam Launchers"]="install_non_steam_launchers"
tasks_array["Uninstall Deckyloader"]="uninstall_deckyloader"
tasks_array["Fix Barrier"]="fix_barrier"

