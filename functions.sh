#! /usr/bin/bash

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
configurator_parent_dir="$(dirname "$configurator_dir")"

print_log() {
    log_message=$1
    log="$task_number/${#chosen_tasks[@]}: $task - $log_message"
    echo -e "$log"
    qdbus $dbusRef setLabelText "$log"
    echo "$log" >> "$configurator_parent_dir/logs.log"
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
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks" flathub org.mozilla.firefox
}

import_corekeyboard() {
    print_log "Importing CoreKeyboard"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks" flathub org.cubocore.CoreKeyboard
}

import_barrier() {
    print_log "Importing Barrier"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks flathub com.github.debauchee.barrier"
}

import_heroic_games() {
    print_log "Importing Heroic Games"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks flathub com.heroicgameslauncher.hgl"
}

import_protonup_qt() {
    print_log "Importing ProtonUP QT"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks flathub net.davidotek.pupgui2"
}

import_boilr() {
    print_log "Importing BoilR"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks flathub io.github.philipk.boilr"
}

import_flatseal() {
    print_log "Importing Flatseal"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks flathub com.github.tchx84.Flatseal"
}

import_steam_rom_manager() {
    print_log "Importing Steam ROM Manager"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks flathub com.steamgriddb.steam-rom-manager"
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
    if [ -f "$configurator_parent_dir/applications/bauh-0.10.5-x86_64.AppImage" ]; then
    cp -v "$configurator_parent_dir/applications/bauh-0.10.5-x86_64.AppImage" "$HOME/Applications/"
    chmod -v +x "$HOME/Applications/bauh-0.10.5-x86_64.AppImage"
    cat <<- EOF > "$HOME/.local/share/applications/bauh.desktop"
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
    cp -v "$configurator_parent_dir/steam-deck-configurator/desktop_icons/bauh.svg" "$HOME/.local/share/icons/"
    else
    print_log "bauh appimage doesn't exist in this folder, download it first, skipping..."
    sleep 3
    fi
}

run_cryo_utilities_recommended() {
    print_log "Running Cryoutilities with recommended settings, please enter your sudo password in the terminal"
    sudo "$HOME/.cryo_utilities/cryo_utilities" recommended
}

export_flatpaks() {
    print_log "exporting flatpaks"
    mkdir -p "$configurator_parent_dir/flatpaks"

    readarray -t flatpak_names < <(flatpak list --app --columns=name)
    readarray -t flatpak_ids < <(flatpak list --app --columns=application)

    for name in "${flatpak_names[@]}"
    do
    if [ -z "$number" ]; then
    number=0
    else
    ((number ++))
    fi
    export_flatpaks_menu+=("$number" "$name" off)
    done
    
    readarray -t chosen_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${export_flatpaks_menu[@]}")
    for flatpak in "${chosen_flatpaks[@]}"
    do
    print_log "adding ${flatpak_names[$flatpak]} to usb"
    flatpak --verbose create-usb "$configurator_parent_dir/flatpaks" "${flatpak_ids[$flatpak]}"
    if [ -z "$flatpak_index" ]; then
    flatpak_index=0
    else
    ((flatpak_index ++))
    fi
    echo "${flatpak_names[$flatpak]}"="${flatpak_ids[$flatpak]}" >> "$configurator_parent_dir/flatpaks_list"
    done
}

import_flatpaks() {
    local -A flatpaks_array
    readarray -t lines < "$configurator_parent_dir/flatpaks_list"

    for line in "${lines[@]}"; do
    key=${line%%=*}
    value=${line#*=}
    flatpaks_array[$key]=$value
    done

    for key in "${!flatpaks_array[@]}"
    do
    import_flatpaks_menu+=("${flatpaks_array[$key]}" "$key" off)
    done

    readarray -t chosen_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${import_flatpaks_menu[@]}")

    for flatpak in "${chosen_flatpaks[@]}"
    do
    print_log "installing $flatpak"
    flatpak install --sideload-repo="$configurator_parent_dir/flatpaks" flathub $flatpak
    done
}

install_deckyloader() {
    if [ -f "$configurator_parent_dir/deckyloader_installed_version" ]
    then
        print_log "Checking if latest version of DeckyLoader is installed"
        RELEASE=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
        VERSION=$(jq -r '.tag_name' <<< ${RELEASE} )
        DECKYLOADER_INSTALLED_VERSION=$(cat "$configurator_parent_dir/deckyloader_installed_version")
        print_log "DeckyLoader Latest Version is $VERSION"
        print_log "DeckyLoader Installed Version is $VERSION"
            if [ "$VERSION" != "$DECKYLOADER_INSTALLED_VERSION" ];
            then
                print_log "Installing Latest Version"
                curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$configurator_parent_dir/deckyloader_install_release.sh"
                chmod -v +x "$configurator_parent_dir/deckyloader_install_release.sh"
                "$configurator_parent_dir/deckyloader_install_release.sh"
                echo "$VERSION" > "$configurator_parent_dir/deckyloader_installed_version"
            else
               print_log "Latest Version of DeckyLoader is already installed"
            fi
    else
        print_log "Installing DeckyLoader"
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$configurator_parent_dir/deckyloader_install_release.sh"
        chmod -v +x "$configurator_parent_dir/deckyloader_install_release.sh"
        "$configurator_parent_dir/deckyloader_install_release.sh"
        echo "$VERSION" > "$configurator_parent_dir/deckyloader_installed_version"
   fi
}

uninstall_deckyloader() {
    print_log "Uninstalling DeckyLoader"
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh  --output "$configurator_parent_dir/deckyloader_uninstaller.sh"
    chmod -v +x "$configurator_parent_dir/deckyloader_uninstaller.sh"
    "$configurator_parent_dir/deckyloader_uninstaller.sh"
    rm -f "$configurator_parent_dir/deckyloader_installed_version"
}

install_cryoutilities() {
    print_log "checking if cryoutilities is installed"
    if [ ! -d "$HOME/.cryo_utilities" ]
    then
        print_log "cryoutilities is not installed, installing"
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh --output "$configurator_parent_dir/cryoutilities_install.sh"
        chmod -v +x "$configurator_parent_dir/cryoutilities_install.sh"
        "$configurator_parent_dir/cryoutilities_install.sh"
    else
        print_log "cryoutilities is already installed"
    fi
}

install_emudeck() {
    print_log "checking if emudeck is installed"
    if [ ! -d "$HOME/emudeck" ]
    then
    print_log "emudeck is not installed, installing"
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh --output "$configurator_parent_dir/emudeck_install.sh"
    chmod -v +x "$configurator_parent_dir/emudeck_install.sh"
    "$configurator_parent_dir/emudeck_install.sh"
    else
    print_log "emudeck is already installed"
    fi
}

update_submodules() {
    git submodule update --remote --merge
}

install_refind_GUI() {
    print_log "installing rEFInd GUI"
    chmod -v +x "$configurator_parent_dir/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh"
    "$configurator_parent_dir/steam-deck-configurator/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

install_refind_bootloader() {
    print_log "Installing rEFInd bootloader"
    "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
}

apply_refind_config() {
    print_log "applying rEFInd config"
    if [ ! -d "$configurator_parent_dir/rEFInd_configs" ]
    then
    cp -vr "$configurator_parent_dir/steam-deck-configurator/rEFInd_configs" "$configurator_parent_dir/rEFInd_configs"
    fi
    num_of_dirs=$(find "$configurator_parent_dir/rEFInd_configs" -mindepth 1 -maxdepth 1 -type d | wc -l) #get amount of folders (configs) in the .deck_setup/refind_configs folder
    if [ "$num_of_dirs" -gt 1 ]; then
    refind_config=$(zenity --file-selection --title="select a file" --filename="$configurator_parent_dir/rEFInd_configs/" --directory)
    else
    refind_config=$(find "$configurator_parent_dir/rEFInd_configs" -mindepth 1 -maxdepth 1 -type d) # else, find the one folder and set the refind config dir to that
    fi

    print_log "applying config at: $refind_config"

    cp -v "$refind_config"/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$HOME/.SteamDeck_rEFInd/GUI" #copy the refind files from the user directory to where rEFInd expects it to install the config
    if [ $? == 0 ];
    then
    "$HOME/.SteamDeck_rEFInd/install_config_from_GUI.sh"
    print_log "config applied"
    else
    cp_error=$?
    print_log "error $cp_error, config not applied"
    echo "error: $cp_error, config not saved"
    kdialog --error "error: $cp_error, config not saved"
    fi
}

save_refind_config() {
    print_log "saving rEFInd config"
    if [ ! -d "$configurator_parent_dir/rEFInd_configs" ]
    then
    cp -vr "$configurator_parent_dir/steam-deck-configurator/rEFInd_configs" "$configurator_parent_dir/rEFInd_configs"
    fi
    kdialog --msgbox "A config must be created using the rEFInd GUI first, by editing the config and clicking on \"Create Config\", continue?"
    if [ $? == 0 ];
    then
    config_save_path=$(zenity --file-selection --save --title="Save config" --filename="$configurator_parent_dir/rEFInd_configs")
        if [ $? == 0 ]; then
        mkdir -p "$config_save_path"
        cp -v "$HOME/.SteamDeck_rEFInd/GUI/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png}" "$config_save_path" #copy files saved by rEFInd GUI to a chosen directory
            if [ $? == 0 ];
            then
            echo "config saved to $config_save_path"
            kdialog --msgbox "config saved to $config_save_path"
            else
            cp_error=$?
            print_log "error $cp_error, config not applied"
            echo "error: $cp_error, config not saved"
            kdialog --error "error: $cp_error, config not saved"
            fi
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
    if compgen -G "$configurator_parent_dir/GE-Proton*.tar.gz" > /dev/null; then
    proton_ge_downloaded_version="$(basename $configurator_parent_dir/GE-Proton*.tar.gz)"
    if [ ! "$proton_ge_downloaded_version" == "$VERSION.tar.gz" ]; then 
    print_log "ProtonGE not up to date, \n Latest Version: $VERSION.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
    else
    print_log "ProtonGE is up to date"
    fi
    else
    print_log "ProtonGE is not downloaded, please download and place it in the $configurator_parent_dir folder first, skipping..."
    sleep 3
    fi
}

install_proton_ge_in_steam() {
    if compgen -G "$configurator_parent_dir/GE-Proton*.tar.gz" > /dev/null; then
    mkdir -p ~/.steam/root/compatibilitytools.d
    tar -xf "$configurator_parent_dir/GE-Proton*.tar.gz" -C ~/.steam/root/compatibilitytools.d/
    print_log "Proton GE installed, please restart Steam"
    else
    print_log "Proton GE doesn't exist in this folder, please download and place it in the $configurator_parent_dir first, skipping..."
    sleep 3
    fi
}

install_non_steam_launchers() {
    print_log "running non steam launchers installer"
    curl https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh --output "$configurator_parent_dir/NonSteamLaunchers.sh"
    chmod -v +x "$configurator_parent_dir/NonSteamLaunchers.sh"
    "$configurator_parent_dir/NonSteamLaunchers.sh"
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

create_menu() {
    unset menu
    for key in "${tasks_array_order[@]}"; do
        if [[ " ${preselected[*]} " =~ " ${tasks_array["$key"]} " ]]; then
        menu+="\"${tasks_array[$key]}\" \"$key\" on "
        else
        menu+="\"${tasks_array[$key]}\" \"$key\" off "
        fi
    done
    readarray -t chosen_tasks < <(echo $menu | xargs kdialog --separate-output --geometry 1280x800 --checklist "Select tasks, click and drag to multiselect")
    run_tasks
}

create_config() {
    config=$(zenity --file-selection --save --title="select a file" --filename="$configurator_parent_dir/configs/")
    for selection in "${chosen_tasks[@]}"
    do
    if [ ! "$selection" == "create_config" ]; then
        if [ ! "$create_config_ran" == 1 ]; then
        create_config_ran=1
        echo "$selection" > "$config"
        else
        echo "$selection" >> "$config"
        fi
    fi
    done
    print_log "created config"
    create_menu
}


load_config() {
    config=$(zenity --file-selection --title="select a file" --filename="$configurator_parent_dir/configs/")
    readarray -t preselected < "$config"
    echo "${preselected[@]}"
    create_menu
}

run_tasks() {
    unset task_number
    if [ -z ${dbusRef+x} ]; then
    dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
    qdbus $dbusRef setLabelText "Initializing..."
    fi

    for task in "${chosen_tasks[@]}"
    do
    ((task_number ++))
    if [ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ] && [[ " ${chosen_tasks[*]} " =~ " ${task} " ]];
    then
    echo $task
    $task #run task
    qdbus $dbusRef Set "" value $task_number
    else
    echo "Task $task not executed, exiting..."
    exit 0
    fi
    done
    qdbus $dbusRef setLabelText "$task_number/${#chosen_tasks[@]}: Tasks completed"
}

declare -A tasks_array
tasks_array["Load Config"]="load_config"
tasks_array_order+=("Load Config")
tasks_array["Create Config"]="create_config"
tasks_array_order+=("Create Config")
tasks_array["Update from pacman"]="update_from_pacman"
tasks_array_order+=("Update from pacman")
tasks_array["Add Flathub if it does not exist"]="add_flathub"
tasks_array_order+=("Add Flathub if it does not exist")
tasks_array["Update Flatpaks"]="update_flatpaks"
tasks_array_order+=("Update Flatpaks")
tasks_array["Set up import and export Flatpaks"]="set_up_import_and_export_flatpaks"
tasks_array_order+=("Set up import and export Flatpaks")
tasks_array["Import Firefox"]="import_firefox"
tasks_array_order+=("Import Firefox")
tasks_array["Import Corekeyboard"]="import_corekeyboard"
tasks_array_order+=("Import Corekeyboard")
tasks_array["Import Barrier"]="import_barrier"
tasks_array_order+=("Import Barrier")
tasks_array["Import Heroic_games"]="import_heroic_games"
tasks_array_order+=("Import Heroic_games")
tasks_array["Import ProtonUp_QT"]="import_protonup_qt"
tasks_array_order+=("Import ProtonUp_QT")
tasks_array["Install Proton GE in Steam"]="install_proton_ge_in_steam"
tasks_array_order+=("Install Proton GE in Steam")
tasks_array["Import BoilR"]="import_boilr"
tasks_array_order+=("Import BoilR")
tasks_array["Import Flatseal"]="import_flatseal"
tasks_array_order+=("Import Flatseal")
tasks_array["Import Steam ROM Manager"]="import_steam_rom_manager"
tasks_array_order+=("Import Steam ROM Manager")
tasks_array["Install Bauh"]="install_bauh"
tasks_array_order+=("Install Bauh")
tasks_array["Install Firefox"]="install_firefox"
tasks_array_order+=("Install Firefox")
tasks_array["Install Corekeyboard"]="install_corekeyboard"
tasks_array_order+=("Install Corekeyboard")
tasks_array["Install Barrier"]="install_barrier"
tasks_array_order+=("Install Barrier")
tasks_array["Install Heroic Games"]="install_heroic_games"
tasks_array_order+=("Install Heroic Games")
tasks_array["Install ProtonUp_QT"]="install_protonUp_qt"
tasks_array_order+=("Install ProtonUp_QT")
tasks_array["Install BoilR"]="install_boilr"
tasks_array_order+=("Install BoilR")
tasks_array["Install Flatseal"]="install_flatseal"
tasks_array_order+=("Install Flatseal")
tasks_array["Install Steam Rom Manager"]="install_steam_rom_manager"
tasks_array_order+=("Install Steam Rom Manager")
tasks_array["Install DeckyLoader"]="install_deckyloader"
tasks_array_order+=("Install DeckyLoader")
tasks_array["Uninstall DeckyLoader"]="uninstall_deckyloader"
tasks_array_order+=("Uninstall DeckyLoader")
tasks_array["Install rEFInd All"]="install_refind_all"
tasks_array_order+=("Install rEFInd All")
tasks_array["Uninstall rEFInd GUI"]="refind_uninstall_gui"
tasks_array_order+=("Uninstall rEFInd GUI")
tasks_array["Check for Proton GE Updates"]="check_for_updates_proton_ge"
tasks_array_order+=("Check for Proton GE Updates")
tasks_array["Install Cryoutilities"]="install_cryoutilities"
tasks_array_order+=("Install Cryoutilities")
tasks_array["Run CryoUtilities with recommended settings"]="run_cryo_utilities_recommended"
tasks_array_order+=("Run CryoUtilities with recommended settings")
tasks_array["Install Emudeck"]="install_emudeck"
tasks_array_order+=("Install Emudeck")
tasks_array["Install RetroDeck"]="install_retrodeck"
tasks_array_order+=("Install RetroDeck")
tasks_array["Update Submodules"]="update_submodules"
tasks_array_order+=("Update Submodules")
tasks_array["Install rEFInd GUI"]="install_refind_GUI"
tasks_array_order+=("Install rEFInd GUI")
tasks_array["Install rEFInd bootloader"]="install_refind_bootloader"
tasks_array_order+=("Install rEFInd bootloader")
tasks_array["Apply rEFInd config"]="apply_refind_config"
tasks_array_order+=("Apply rEFInd config")
tasks_array["Save rEFInd config"]="save_refind_config"
tasks_array_order+=("Save rEFInd config")
tasks_array["Install Non Steam Launchers"]="install_non_steam_launchers"
tasks_array_order+=("Install Non Steam Launchers")
tasks_array["Uninstall Deckyloader"]="uninstall_deckyloader"
tasks_array_order+=("Uninstall Deckyloader")
tasks_array["Export Flatpaks"]="export_flatpaks"
tasks_array_order+=("Export Flatpaks")
tasks_array["Import Flatpaks"]="import_flatpaks"
tasks_array_order+=("Import Flatpaks")
tasks_array["Fix Barrier"]="fix_barrier"
tasks_array_order+=("Fix Barrier")