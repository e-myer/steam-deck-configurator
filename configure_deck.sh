#! /usr/bin/bash

# Configures various functions in a steam deck.

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

print_log() {
    log_message=$1
    log="$task_number/$number_of_tasks: $task - $log_message"
    qdbus $dbusRef setLabelText "$log"
    echo "$log" >> "$configurator_dir/logs.log"
    if [[ "$2" == "error" ]]; then
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >&2
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >> "$configurator_dir/errors"
    else
        echo -e "$log"
    fi
}

update_submodules() {
    git submodule update --remote --merge
}

add_flathub() {
    print_log "Adding Flathub"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

list_flatpaks() {
    readarray -t flatpak_names < <(flatpak list --app --columns=name)
    readarray -t flatpak_ids < <(flatpak list --app --columns=application)
}

update_flatpaks() {
    print_log "Updating Flatpaks"
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "error, no Flatpaks installed" "error"
        return
    fi

    flatpak update -y
}

interaction_export_flatpaks() {
    print_log "Listing Flatpaks for Exporting"
    export_flatpaks_menu=()
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "error, no Flatpaks installed" "error"
        export_flatpaks_run=no
        return
    fi

    mkdir -p "$configurator_dir/flatpaks"

    for flatpak_name in "${flatpak_names[@]}"; do
        if [[ -z "$number" ]]; then
            local number=0
        else
            ((number ++))
        fi
        export_flatpaks_menu+=("$number" "$flatpak_name" off)
    done
    
    readarray -t chosen_export_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks to export" "${export_flatpaks_menu[@]}")
}

export_flatpaks() {
    if [[ "$export_flatpaks_run" == "no" ]]; then
        return
    fi

    if ! flatpak remotes --columns=collection | grep -q org.flathub.Stable; then
        flatpak remote-modify --collection-id=org.flathub.Stable flathub
    fi

    print_log "exporting flatpaks"
    for chosen_export_flatpak in "${chosen_export_flatpaks[@]}"; do
        print_log "exporting ${flatpak_names[$chosen_export_flatpak]}"
        if flatpak --verbose create-usb "$configurator_dir/flatpaks" "${flatpak_ids[$chosen_export_flatpak]}"; then
            if [[ -s "$configurator_dir/flatpaks_exported_list" ]] && ! grep -Fxq "${flatpak_names[$chosen_export_flatpak]}=${flatpak_ids[$chosen_export_flatpak]}" "$configurator_dir/flatpaks_exported_list"; then
                    echo "${flatpak_names[$chosen_export_flatpak]}=${flatpak_ids[$chosen_export_flatpak]}" >> "$configurator_dir/flatpaks_exported_list"
            else
                    echo "${flatpak_names[$chosen_export_flatpak]}=${flatpak_ids[$chosen_export_flatpak]}" > "$configurator_dir/flatpaks_exported_list"
            fi
        else
            kdialog --title "Export Flatpaks - Steam Deck Configurator" --passivepopup "export flatpaks error: $?"
            print_log "export_flatpaks error $?" "error"
        fi
    done
}

interaction_import_flatpaks() {
    print_log "listing flatpaks for importing"
    import_flatpaks_menu=()
    unset order
    local -A flatpaks_import_array
    if [[ ! -f "$configurator_dir/flatpaks_exported_list" ]]; then
        print_log "no exported flatpak found" "error"
        import_flatpaks_run=no
        return
    fi

    readarray -t lines < "$configurator_dir/flatpaks_exported_list"

    for line in "${lines[@]}"; do
        key=${line%%=*}
        value=${line#*=}
        flatpaks_import_array[$key]=$value
        order+=("$key")
    done

    for key in "${order[@]}"; do
        import_flatpaks_menu+=("${flatpaks_import_array[$key]}" "$key" off)
    done

    readarray -t chosen_import_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks to import" "${import_flatpaks_menu[@]}")
}

import_flatpaks() {
    if [[ import_flatpaks_run == "no" ]]; then
        return
    fi

    if ! flatpak remotes --columns=collection | grep -q org.flathub.Stable; then
    flatpak remote-modify --collection-id=org.flathub.Stable flathub
    fi

    print_log "importing flatpaks"
    if [[ ${#chosen_import_flatpaks[@]} -eq 0 ]]; then
        print_log "No flatpaks chosen"
        return
    fi

    for chosen_import_flatpak in "${chosen_import_flatpaks[@]}"; do
        print_log "installing $flatpak"
        flatpak install --sideload-repo="$configurator_dir/flatpaks" flathub $chosen_import_flatpak -y
    done
}

interaction_save_flatpaks_install() {
    print_log "choose flatpaks to save"
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "error, no Flatpaks installed" "error"
        save_flatpaks_install_run=no
        return
    fi

    for flatpak_name in "${flatpak_names[@]}"; do
        if [[ -z "$number" ]]; then
            local number=0
        else
            ((number ++))
        fi
        save_flatpaks_menu+=("$number" "$flatpak_name" off)
    done
    
    readarray -t chosen_save_flatpaks < <(kdialog --title "Choose Flatpaks to Save - Steam Deck Configurator" --separate-output --checklist "Select Flatpaks to save" "${save_flatpaks_menu[@]}")
}

save_flatpaks_install() {
    print_log "saving flatpaks list"
    if [[ "$save_flatpaks_install_run" == "no" ]]; then
        return
    fi

    print_log "saving flatpaks list"
    for chosen_save_flatpak in "${chosen_save_flatpaks[@]}"; do
        print_log "saving ${flatpak_names[$chosen_save_flatpak]}"
            if ! grep -Fxq "${flatpak_names[$chosen_save_flatpak]}=${flatpak_ids[$chosen_save_flatpak]}" "$configurator_dir/flatpaks_install_list"; then
                if [[ ! -s "$configurator_dir/flatpaks_install_list" ]]; then
                    echo Clear List=clear_list > "$configurator_dir/flatpaks_install_list"
                fi
                echo "${flatpak_names[$chosen_save_flatpak]}=${flatpak_ids[$chosen_save_flatpak]}" >> "$configurator_dir/flatpaks_install_list"
            fi
    done
}

interaction_install_flatpaks() {
    print_log "choose flatpaks to install"
    if [[ -s "$configurator_dir/flatpaks_install_list" ]]; then
        flatpak_install_list_file=$configurator_dir/flatpaks_install_list
    else
        flatpak_install_list_file=$configurator_dir/flatpaks_install_list_default
    fi

    install_flatpaks_menu=()
    unset order
    local -A flatpaks_install_array
    readarray -t lines < "$flatpak_install_list_file"

    for line in "${lines[@]}"; do
        key=${line%%=*}
        value=${line#*=}
        flatpaks_install_array[$key]=$value
        order+=("$key")
    done

    for key in "${order[@]}"; do
        install_flatpaks_menu+=("${flatpaks_install_array[$key]}" "$key" off)
    done

    readarray -t chosen_install_flatpaks < <(kdialog --title "Choose Flatpaks to Install - Steam Deck Configurator" --separate-output --checklist "Select Flatpaks to install" "${install_flatpaks_menu[@]}")
}

install_flatpaks() {
    print_log "installing flatpaks"
    if [[ ${#chosen_install_flatpaks[@]} -eq 0 ]]; then
        print_log "No flatpaks chosen"
        return
    elif [[ " ${chosen_install_flatpaks[*]} " =~ " clear_list " ]]; then
        rm "$configurator_dir/flatpaks_install_list"
    else
        for chosen_install_flatpak in "${chosen_install_flatpaks[@]}"; do
            print_log "installing $chosen_install_flatpak"
            flatpak install flathub $chosen_install_flatpak -y
        done
    fi
}

install_bauh() {
    print_log "Installing Bauh"
    if [[ ! -f "$configurator_dir/applications/bauh-0.10.5-x86_64.AppImage" ]]; then
        print_log "bauh appimage doesn't exist in this folder, download it first, skipping..." "error"
        kdialog --title "Steam Deck Configurator" --passivepopup "bauh appimage doesn't exist in this folder, download it first, skipping..."
        sleep 3
        return
    fi

    cp -v "$configurator_dir/applications/bauh-0.10.5-x86_64.AppImage" "$HOME/Applications/"
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
    cp -v "$configurator_dir/desktop_icons/bauh.svg" "$HOME/.local/share/icons/"
}

install_deckyloader() {
    if [[ -f "$configurator_dir/deckyloader_installed_version" ]]; then
        print_log "Checking if latest version of DeckyLoader is installed"
        local release
        release=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
        local version
        version=$(jq -r '.tag_name' <<< ${release} )
        local deckyloader_installed_version
        deckyloader_installed_version=$(cat "$configurator_dir/deckyloader_installed_version")
        print_log "DeckyLoader Latest Version is $version"
        print_log "DeckyLoader Installed Version is $deckyloader_installed_version"

        if [[ "$version" == "$deckyloader_installed_version" ]]; then
            print_log "Latest Version of DeckyLoader is already installed"
            return
        else
            print_log "Installing Latest Version"
            curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$configurator_dir/deckyloader_install_release.sh"
            chmod -v +x "$configurator_dir/deckyloader_install_release.sh"
            "$configurator_dir/deckyloader_install_release.sh"
            echo "$version" > "$configurator_dir/deckyloader_installed_version"
        fi

    else
        print_log "Installing DeckyLoader"
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$configurator_dir/deckyloader_install_release.sh"
        chmod -v +x "$configurator_dir/deckyloader_install_release.sh"
        "$configurator_dir/deckyloader_install_release.sh"
        echo "$version" > "$configurator_dir/deckyloader_installed_version"
    fi
}

uninstall_deckyloader() {
    print_log "Uninstalling DeckyLoader"
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh  --output "$configurator_dir/deckyloader_uninstaller.sh"
    chmod -v +x "$configurator_dir/deckyloader_uninstaller.sh"
    "$configurator_dir/deckyloader_uninstaller.sh"
    rm -f "$configurator_dir/deckyloader_installed_version"
}

install_cryoutilities() {
    print_log "checking if CryoUtilities is installed"
    if [[ -d "$HOME/.cryo_utilities" ]]; then
        print_log "CryoUtilities is already installed"
        return
    fi

    print_log "Installing CryoUtilities... Please click on the \"ok\" button after it installs to continue"
    kdialog --title "Steam Deck Configurator" --passivepopup "Installing CryoUtilities. Please select click the \"ok\" button after it installs to continue"
    curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh --output "$configurator_dir/cryoutilities_install.sh"
    chmod -v +x "$configurator_dir/cryoutilities_install.sh"
    "$configurator_dir/cryoutilities_install.sh"
}

run_cryo_utilities_recommended() {
    if [[ ! -d "$HOME/.cryo_utilities" ]]; then
        print_log "CryoUtilities is not installed, didn't run cryo_utilites" "error"
        return
    fi

    print_log "Running Cryoutilities with recommended settings, please enter your sudo password in the terminal"
    kdialog --title "Run CryoUtilities Recommended - Steam Deck Configurator" --msgbox "Running Cryoutilities with recommended settings, please enter your sudo password in the terminal"
    sudo "$HOME/.cryo_utilities/cryo_utilities" recommended
}

install_emudeck() {
    print_log "checking if emudeck is installed"
    if [[ -d "$HOME/emudeck" ]]; then
        print_log "emudeck is already installed"
        return
    fi

    print_log "emudeck is not installed, installing"
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh --output "$configurator_dir/emudeck_install.sh"
    chmod -v +x "$configurator_dir/emudeck_install.sh"
    "$configurator_dir/emudeck_install.sh"
}

install_refind_GUI() {
    print_log "installing rEFInd GUI"
    chmod -v +x "$configurator_dir/SteamDeck_rEFInd/install-GUI.sh"
    "$configurator_dir/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

interaction_install_refind_bootloader() {
    print_log "install reifnd bootlader confirmation"
    if kdialog --title "Install rEFInd Bootloader - Steam Deck Configurator" --yesno "It is recommended to install the rEFInd bootloader after installing other operating systems, install the refind bootloader?"; then
        install_refind=yes
    else
        install_refind=no
    fi
}

install_refind_bootloader() {
    if [[ "$install_refind" != "yes" ]]; then
        print_log "didn't install refind" "error"
        return
    fi

    if [[ ! -d "$HOME/.SteamDeck_rEFInd" ]]; then
        print_log "rEFInd isn't installed, install the GUI first" "error"
        return
    fi

    print_log "Installing rEFInd bootloader, please input the sudo password when prompted"
    kdialog --title "Steam Deck Configurator" --passivepopup "Installing rEFInd bootloader, please input the sudo password when prompted"
    "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
}

install_refind_all() {
    print_log "running all install rEFInd tasks"
    install_refind_GUI
    install_refind_bootloader
    apply_refind_config
}

uninstall_refind_gui() {
    print_log "uninstalling rEFInd GUI"
    rm -vrf ~/SteamDeck_rEFInd
    rm -vrf ~/.SteamDeck_rEFInd
    rm -vf ~/Desktop/refind_GUI.desktop
}

interaction_apply_refind_config() {
    print_log "applying rEFInd config"
    if [[ ! -d "$configurator_dir/rEFInd_configs" ]]; then
        print_log "No rEFInd configs found, please create one first, skipping..." "error"
        kdialog --title "Steam Deck Configurator" --passivepopup "No rEFInd configs found, please create one first, skipping..."
        sleep 3
        return
    fi

    if ! refind_config=$(zenity --file-selection --title="select a file" --filename="$configurator_dir/rEFInd_configs/" --directory); then
        print_log "cancelled"
        apply_refind_config_run=no
        return
    fi
    
    apply_refind_config_run=yes
}

apply_refind_config() {
    if ! efibootmgr | grep -q rEFInd; then
        print_log "rEFInd bootloader isn't installed" "error"
        return
    elif [[ ! -d "$HOME/.SteamDeck_rEFInd" ]]; then
        print_log "rEFInd GUI isn't installed" "error"
        return
    elif [[ "$apply_refind_config_run" != "yes" ]]; then
        print_log "didn't apply refind config"
        return
    fi

    print_log "applying config at: $refind_config, please input the sudo password when prompted"
    kdialog --title "Steam Deck Configurator" --passivepopup "applying config at: $refind_config, please input the sudo password when prompted"
    if cp -v "$refind_config"/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$HOME/.SteamDeck_rEFInd/GUI"; then #copy the refind files from the user directory to where rEFInd expects it to install the config
        "$HOME/.SteamDeck_rEFInd/install_config_from_GUI.sh"
        print_log "config applied"
    else
        cp_error=$?
        print_log "error $cp_error, config not applied" "error"
    fi
}

interaction_save_refind_config() {
    print_log "save rEFInd config"
    if [[ ! -d "$HOME/.SteamDeck_rEFInd" ]]; then
        print_log "rEFInd isn't installed, install the GUI first" "error"
        return
    fi

    if ! kdialog --title "Save rEFInd Config - Steam Deck Configurator" --msgbox "A config must be created using the rEFInd GUI first, by editing the config and clicking on \"Create Config\", continue?"; then
        save_refind_config_run=no
        print_log "cancelled"
        return
    fi
    
    save_refind_config_run=yes
    if [[ ! -d "$configurator_dir/configs" ]]; then
        mkdir "$configurator_dir/configs"
    fi
    if ! config_save_path=$(zenity --file-selection --save --title="Save config" --filename="$configurator_dir/rEFInd_configs/"); then
        print_log "cancelled"
        return
    fi
}

save_refind_config() {
    if [[ "$save_refind_config_run" != "yes" ]]; then
        print_log "didn't save refind config"
        return
    fi

    if [[ ! -d "$HOME/.SteamDeck_rEFInd" ]]; then
        print_log "rEFInd isn't installed, install the GUI first" "error"
        return
    fi

    print_log "saving rEFInd config"
    mkdir -p "$config_save_path"
    if cp -v "$HOME/.SteamDeck_rEFInd/GUI/"{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$config_save_path"; then
        print_log "config saved to $config_save_path"
        kdialog --title "Save rEFInd Config - Steam Deck Configurator" --msgbox "config saved to $config_save_path"
    else
        cp_error=$?
        print_log "error $cp_error, config not saved" "error"
    fi


}

check_for_updates_proton_ge() {
    print_log "checking for ProtonGE Updates"
    if ! compgen -G "$configurator_dir/GE-Proton*.tar.gz" > /dev/null; then
        print_log "ProtonGE is not downloaded, please download and place it in the $configurator_dir folder first, skipping..." "error"
        kdialog --title "Steam Deck Configurator" --passivepopup "ProtonGE is not downloaded, please download and place it in the $configurator_dir folder first, skipping..."
        sleep 3
        return
    fi

    local version
    version=$(curl -s 'https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
    version=$(jq -r '.tag_name' <<< ${release} )
    local proton_ge_downloaded_version
    proton_ge_downloaded_version="$(basename $configurator_dir/GE-Proton*.tar.gz)"
    if [[ ! "$proton_ge_downloaded_version" == "$version.tar.gz" ]]; then
        print_log "ProtonGE not up to date, \n Latest Version: $version.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
        kdialog --title "Check For ProtonGE Updates - Steam Deck Configurator" --msgbox "ProtonGE not up to date, \n Latest Version: $version.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
    else
        print_log "ProtonGE is up to date"
        kdialog --title "Check For ProtonGE Updates - Steam Deck Configurator" --msgbox "ProtonGE is up to date"
    fi
}

install_proton_ge_in_steam() {
    print_log "install protonGE in steam"
    if ! compgen -G "$configurator_dir/GE-Proton*.tar.gz" > /dev/null; then
        print_log "Proton GE doesn't exist in this folder, please download and place it in the $configurator_dir first, skipping..." "error"
        kdialog --title "Steam Deck Configurator" --passivepopup "Proton GE doesn't exist in this folder, please download and place it in the $configurator_dir first, skipping..."
        sleep 3
        return
    fi

    mkdir -p ~/.steam/root/compatibilitytools.d
    tar -xf "$configurator_dir/GE-Proton*.tar.gz" -C ~/.steam/root/compatibilitytools.d/
    print_log "Proton GE installed, please restart Steam"
    kdialog --title "Steam Deck Configurator" --passivepopup "Proton GE installed, please restart Steam"
}

fix_barrier() {
    print_log "Fixing Barrier"
    if ! kdialog --title "Barrier Auto Config" --yesno "Are you using auto config for the ip address?"; then
        ip_address=$(kdialog --title "Fix Barrier - Steam Deck Configurator" --inputbox "input server ip address from the barrier app")
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

    kdialog --msgbox "Applied fix, turn off SSL on both the server and host, if Barrier still doesn't work, check if you are connected on the same wifi network, and set windows resolution to 100%"
}

load_config() {
    print_log "load config"
    if [[ -d "$configurator_dir/configs" ]]; then
        set_menu
        if chosen_files_var=$(zenity --file-selection --multiple --separator=$'\n' --title="Select a File - Load Config - Steam Deck Configurator" --filename="$configurator_dir/configs/"); then
            pre_ifs=$IFS
            IFS=$'\n'
            readarray -t config_files <<< "$chosen_files_var"
            IFS=$pre_ifs
        else
            print_log "cancelled"
            return
        fi

        for config_file in "${config_files[@]}"; do
            readarray -t config_line < "$config_file"
            for option in "${config_line[@]}"; do
                menu=$(sed -r "s/(\"$option\" ".+?") off/\1 on/" <<< $menu)
            done
        done
    else
        print_log "No configs found, please create one first" "error"
    fi
}

create_config() {
    print_log "create config"
    if [[ ${#chosen_tasks[@]} == 1 ]]; then
        kdialog --title "Create Config - Steam Deck Configurator" --error "Please choose the tasks to save as a config."
        return
    fi

    if [[ ! -d "$configurator_dir/configs" ]]; then
        mkdir "$configurator_dir/configs"
    fi
    
    local config
    if ! config=$(zenity --file-selection --save --title="Select a File - Create Config - Steam Deck Configurator" --filename="$configurator_dir/configs/"); then
        print_log "cancelled"
        for chosen_task in "${chosen_tasks[@]}"; do
            if [[ "$chosen_task" != "create_config" ]]; then
                menu=$(sed -r "s/(\"$chosen_task\" ".+?") off/\1 on/" <<< $menu)
            fi
        done
        chosen_tasks=()
        return
    fi

    for chosen_task in "${chosen_tasks[@]}"; do
        if [[ ! "$chosen_task" == "create_config" ]]; then
            if [[ ! "$create_config_ran" == 1 ]]; then
                create_config_ran=1
                echo "$chosen_task" > "$config"
            else
                echo "$chosen_task" >> "$config"
            fi
        fi
    done
    print_log "created config"
    kdialog --title "Create Config - Steam Deck Configurator" --msgbox "created config"
    
    for chosen_task in "${chosen_tasks[@]}"; do
        if [[ "$chosen_task" != "create_config" ]]; then
            menu=$(sed -r "s/(\"$chosen_task\" ".+?") off/\1 on/" <<< $menu)
        fi
    done
    chosen_tasks=()
}

create_dialog() {
    while true; do
    readarray -t chosen_tasks < <(echo $menu | xargs kdialog --title "Steam Deck Configurator" --separate-output --geometry 1280x800 --checklist "Select tasks, click and drag to multiselect")
    run_tasks
    done
}

set_interactive_tasks() {
    interactive_tasks=(save_refind_config apply_refind_config import_flatpaks export_flatpaks install_refind_bootloader install_flatpaks save_flatpaks_install)
}

run_interactive_tasks() {
    sorted_chosen_tasks=($(echo "${chosen_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    interactive_tasks=($(echo "${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    chosen_interactive_tasks=($(echo "${sorted_chosen_tasks[@]} ${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq -d))

    number_of_tasks=$((${#chosen_interactive_tasks[@]}+${#chosen_tasks[@]}))
    qdbus $dbusRef close
    dbusRef=$(kdialog --title "Steam Deck Configurator" --progressbar "Steam Deck Configurator" "$number_of_tasks")

    echo "${chosen_interactive_tasks[@]}"
    for chosen_interactive_task in "${chosen_interactive_tasks[@]}"; do
        if [[ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ]]; then
            ((task_number ++))
            echo interaction_$chosen_interactive_task
            interaction_$chosen_interactive_task
            qdbus $dbusRef Set "" value $task_number
        fi
    done
    ran_interactive_tasks=yes
}

run_tasks() {
    if [[ ${#chosen_tasks[@]} -eq 0 ]]; then
        echo No tasks chosen, exiting...
        exit 0
    fi
    unset task_number

    if [[ ! " ${chosen_tasks[*]} " =~ " load_config " ]] || [[ ! " ${chosen_tasks[*]} " =~ " create_config " ]]; then
        set_menu
    fi

    if [[ " ${chosen_tasks[*]} " =~ " load_config " ]]; then
        number_of_tasks=1
        chosen_tasks=(load_config)
    elif [[ " ${chosen_tasks[*]} " =~ " create_config " ]]; then
        number_of_tasks=1
    elif [[ "$ran_interactive_tasks" != "yes" ]]; then
        run_interactive_tasks
    else
        number_of_tasks=${#chosen_tasks[@]}
    fi

    qdbus $dbusRef close
    dbusRef=$(kdialog --title "Steam Deck Configurator" --progressbar "Steam Deck Configurator" "$number_of_tasks")
    qdbus $dbusRef setLabelText "Steam Deck Configurator"

    for chosen_task in "${chosen_tasks[@]}"; do
        if [[ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ]] && [[ " ${chosen_tasks[*]} " =~ " ${chosen_task} " ]]; then
            ((task_number ++))
            echo $chosen_task
            $chosen_task
            qdbus $dbusRef Set "" value $task_number
        fi
    done
    ran_interactive_tasks=no

    if [[ -s "$configurator_dir/errors" ]]; then
        kdialog --title "Run Tasks - Steam Deck Configurator" --textbox "$configurator_dir/errors"
        truncate -s 0 "$configurator_dir/errors"
    fi

    qdbus $dbusRef setLabelText "$task_number/$number_of_tasks: Tasks completed"
}

set_menu() {
    menu='"load_config" "Load Config" off
    "create_config" "Create Config" off
    "add_flathub" "Add Flathub if it does not exist" off
    "update_flatpaks" "Update Flatpaks" off
    "import_flatpaks" "Import Flatpaks" off
    "export_flatpaks" "Export Flatpaks" off
    "install_flatpaks" "Install Flatpaks" off
    "save_flatpaks_install" "Save Flatpaks List" off
    "install_proton_ge_in_steam" "Install Proton GE in Steam" off
    "install_bauh" "Install Bauh" off
    "install_deckyloader" "Install DeckyLoader" off
    "check_for_updates_proton_ge" "Check for Proton GE Updates" off
    "install_cryoutilities" "Install CryoUtilities" off
    "run_cryo_utilities_recommended" "Run CryoUtilities with recommended settings" off
    "install_emudeck" "Install Emudeck" off
    "update_submodules" "Update Submodules" off
    "install_refind_GUI" "Install rEFInd GUI" off
    "install_refind_bootloader" "Install rEFInd bootloader" off
    "apply_refind_config" "Apply rEFInd config" off
    "save_refind_config" "Save rEFInd config" off
    "fix_barrier" "Fix Barrier" off
    "uninstall_deckyloader" "Uninstall DeckyLoader" off
    "uninstall_refind_gui" "Uninstall rEFInd GUI" off'
}

main() {
    if ! kdialog --title "Password - Steam Deck Configurator" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"; then
        exit 0
    fi

    set_interactive_tasks
    set_menu
    create_dialog
}

main