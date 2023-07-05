#! /usr/bin/bash

# Configures various functions in a Steam Deck.

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

print_log() {
    log_message=$1
    log="$task_number/$number_of_tasks: $task - $log_message"
    echo "# $log"
    echo "$log" >> "$configurator_dir/logs.log"
    if [[ "$2" == "error" ]]; then
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >&2
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >> "$configurator_dir/notices"
    elif [[ "$2" == "notice" ]]; then
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >> "$configurator_dir/notices"
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
    readarray -t flatpak_names_unsorted < <(flatpak list --app --columns=name)
    readarray -t flatpak_ids_unsorted < <(flatpak list --app --columns=application)

    for flatpak_index in "${!flatpak_names_unsorted[@]}"; do
        flatpaks+=("${flatpak_names_unsorted[$flatpak_index]}=${flatpak_ids_unsorted[$flatpak_index]}")
    done
    pre_ifs=$IFS
    IFS=$'\n'
    sorted_flatpaks=($(sort <<<"${flatpaks[*]}"))
    IFS=$pre_ifs

    for sorted_flatpak in "${sorted_flatpaks[@]}"; do
        flatpak_names+=("${sorted_flatpak%%=*}")
        flatpak_ids+=("${sorted_flatpak#*=}")
    done
}

update_flatpaks() {
    print_log "Updating Flatpaks"
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "Error, no Flatpaks installed" "error"
        sleep 3
        return
    fi

    flatpak update -y
}

interaction_export_flatpaks() {
    print_log "Listing Flatpaks for Exporting"
    export_flatpaks_menu=()
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "Error, no Flatpaks installed" "error"
        export_flatpaks_run=no
        return
    fi

    if ! flatpaks_export_dir=$(zenity --file-selection --title="Select a folder to export flatpaks to" --filename="$HOME/" --directory); then
        print_log "Cancelled"
        export_flatpaks_run=no
        return
    fi

    for flatpak_name in "${flatpak_names[@]}"; do
        if [[ -z "$number" ]]; then
            local number=0
        else
            ((number ++))
        fi
        #export_flatpaks_menu+=("$number" "$flatpak_name" off)
        export_flatpaks_menu+=(FALSE \""$number"\" \""$flatpak_name"\")
    done
    echo "${export_flatpaks_menu[@]}"
    #readarray -t chosen_export_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks to export" "${export_flatpaks_menu[@]}")
    #readarray -t chosen_export_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks to export" "${export_flatpaks_menu[@]}")
    readarray -t chosen_export_flatpaks < <(echo "${export_flatpaks_menu[@]}" | xargs zenity --height=800 --width=1280 --list --checklist --column="status" --column="number" --column="name" --hide-column=2 --print-column=2 --separator=$'\n' --title="Select Flatpaks to export")
    #later make it like the flatpak link is in the dialog, but hidden, that is what is printed.
    #readarray -t chosen_export_flatpaks < <(zenity --height=800 --width=1280 --list --checklist --column="name" --separator=$'\n' --title="Select Flatpaks to export" "${export_flatpaks_menu[@]}")
}

export_flatpaks() {
    if [[ "$export_flatpaks_run" == "no" ]]; then
        return
    fi

    if ! flatpak remotes --columns=collection | grep -q org.flathub.Stable; then
        flatpak remote-modify --collection-id=org.flathub.Stable flathub
    fi

    print_log "Exporting Flatpaks"
    for chosen_export_flatpak in "${chosen_export_flatpaks[@]}"; do
        print_log "Exporting ${flatpak_names[$chosen_export_flatpak]}"
        if flatpak --verbose create-usb "$flatpaks_export_dir" "${flatpak_ids[$chosen_export_flatpak]}"; then
            if [[ -s "$flatpaks_export_dir/flatpaks_exported_list" ]] && ! grep -Fxq "${flatpak_names[$chosen_export_flatpak]}=${flatpak_ids[$chosen_export_flatpak]}" "$flatpaks_export_dir/flatpaks_exported_list"; then
                    echo "${flatpak_names[$chosen_export_flatpak]}=${flatpak_ids[$chosen_export_flatpak]}" >> "$flatpaks_export_dir/flatpaks_exported_list"
            else
                    echo "${flatpak_names[$chosen_export_flatpak]}=${flatpak_ids[$chosen_export_flatpak]}" > "$flatpaks_export_dir/flatpaks_exported_list"
            fi
        else
            notify-send "export flatpaks error: $?"
            print_log "export_flatpaks error $?" "error"
        fi
    done
}

interaction_import_flatpaks() {
    print_log "Listing Flatpaks for importing"

    if ! flatpaks_import_dir=$(zenity --file-selection --title="select a folder to import flatpaks from" --filename="$HOME/" --directory); then
        print_log "Cancelled"
        import_flatpaks_run=no
        return
    fi

    import_flatpaks_menu=()
    unset order
    local -A flatpaks_import_array
    if [[ ! -f "$flatpaks_import_dir/flatpaks_exported_list" ]]; then
        print_log "No exported Flatpak found" "error"
        import_flatpaks_run=no
        return
    fi

    readarray -t lines < "$flatpaks_import_dir/flatpaks_exported_list"

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
    if [[ $import_flatpaks_run == "no" ]]; then
        return
    fi

    if ! flatpak remotes --columns=collection | grep -q org.flathub.Stable; then
        flatpak remote-modify --collection-id=org.flathub.Stable flathub
    fi

    print_log "Importing flatpaks"
    if [[ ${#chosen_import_flatpaks[@]} -eq 0 ]]; then
        print_log "No flatpaks chosen"
        return
    fi

    for chosen_import_flatpak in "${chosen_import_flatpaks[@]}"; do
        print_log "Installing $chosen_import_flatpak"
        flatpak install --sideload-repo="$flatpaks_import_dir" flathub $chosen_import_flatpak -y
    done
}

interaction_save_flatpaks_install() {
    print_log "Choose flatpaks to save"
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "Error, no Flatpaks installed" "error"
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
    print_log "Saving flatpaks list"
    if [[ "$save_flatpaks_install_run" == "no" ]]; then
        return
    fi

    print_log "Saving Flatpaks list"
    for chosen_save_flatpak in "${chosen_save_flatpaks[@]}"; do
        print_log "Saving ${flatpak_names[$chosen_save_flatpak]}"
        if ! grep -Fxq "${flatpak_names[$chosen_save_flatpak]}=${flatpak_ids[$chosen_save_flatpak]}" "$configurator_dir/flatpaks_install_list"; then
            if [[ ! -s "$configurator_dir/flatpaks_install_list" ]]; then
                echo Clear List=clear_list > "$configurator_dir/flatpaks_install_list"
            fi
            echo "${flatpak_names[$chosen_save_flatpak]}=${flatpak_ids[$chosen_save_flatpak]}" >> "$configurator_dir/flatpaks_install_list"
        fi
    done
}

interaction_install_flatpaks() {
    print_log "Choose Flatpaks to install"
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
    print_log "Installing flatpaks"
    if [[ ${#chosen_install_flatpaks[@]} -eq 0 ]]; then
        print_log "No flatpaks chosen"
        return
    elif [[ " ${chosen_install_flatpaks[*]} " =~ " clear_list " ]]; then
        rm "$configurator_dir/flatpaks_install_list"
    else
        for chosen_install_flatpak in "${chosen_install_flatpaks[@]}"; do
            print_log "Installing $chosen_install_flatpak"
            flatpak install flathub $chosen_install_flatpak -y
        done
    fi
}

interaction_install_bauh() {
    if [[ ! -f "$configurator_dir/applications/bauh-0.10.5-x86_64.AppImage" ]]; then
        print_log "Bauh appimage doesn't exist in this folder, download it first, skipping..." "error"
        notify-send "bauh appimage doesn't exist in this folder, download it first, skipping..."
        sleep 3
        install_bauh_run=no
        return
    fi
}

install_bauh() {
    if [[ $install_bauh_run == "no" ]]; then
        return
    fi
    print_log "Installing Bauh"
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
    local release
    release=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
    local version
    version=$(jq -r '.tag_name' <<< ${release} )
    if [[ -f "$HOME/.steam_deck_configurator/deckyloader_installed_version" ]]; then
        print_log "Checking if latest version of DeckyLoader is installed"
        local deckyloader_installed_version
        deckyloader_installed_version=$(cat "$HOME/.steam_deck_configurator/deckyloader_installed_version")
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
            mkdir -p "$HOME/.steam_deck_configurator"
            echo "$version" > "$HOME/.steam_deck_configurator/deckyloader_installed_version"
        fi

    else
        print_log "Installing DeckyLoader"
        curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$configurator_dir/deckyloader_install_release.sh"
        chmod -v +x "$configurator_dir/deckyloader_install_release.sh"
        "$configurator_dir/deckyloader_install_release.sh"
        mkdir -p "$HOME/.steam_deck_configurator"
        echo "$version" > "$HOME/.steam_deck_configurator/deckyloader_installed_version"
    fi
}

uninstall_deckyloader() {
    print_log "Uninstalling DeckyLoader"
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh  --output "$configurator_dir/deckyloader_uninstaller.sh"
    chmod -v +x "$configurator_dir/deckyloader_uninstaller.sh"
    "$configurator_dir/deckyloader_uninstaller.sh"
    rm -f "$HOME/.steam_deck_configurator/deckyloader_installed_version"
}

install_cryoutilities() {
    print_log "Checking if CryoUtilities is installed"
    if [[ -d "$HOME/.cryo_utilities" ]]; then
        print_log "CryoUtilities is already installed"
        return
    fi

    print_log "Installing CryoUtilities... Please click on the \"ok\" button after it installs to continue"
    notify-send "Installing CryoUtilities. Please click on the \"ok\" button after it installs to continue"
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
    notify-send "Running Cryoutilities with recommended settings, please enter your sudo password in the terminal"
    sudo "$HOME/.cryo_utilities/cryo_utilities" recommended
}

install_emudeck() {
    print_log "Checking if emudeck is installed"
    if [[ -d "$HOME/emudeck" ]]; then
        print_log "EmuDeck is already installed"
        return
    fi

    print_log "EmuDeck is not installed, installing"
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh --output "$configurator_dir/emudeck_install.sh"
    chmod -v +x "$configurator_dir/emudeck_install.sh"
    "$configurator_dir/emudeck_install.sh"
}

install_refind_GUI() {
    print_log "Installing rEFInd GUI"
    chmod -v +x "$configurator_dir/SteamDeck_rEFInd/install-GUI.sh"
    "$configurator_dir/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

interaction_install_refind_bootloader() {
    print_log "Install reifnd bootlader confirmation"
    if zenity --title "Install rEFInd Bootloader - Steam Deck Configurator" --question --text="It is recommended to install the rEFInd bootloader after installing other operating systems, install the refind bootloader?"; then
        install_refind=yes
    else
        install_refind=no
    fi
}

install_refind_bootloader() {
    if [[ "$install_refind" != "yes" ]]; then
        print_log "Didn't install refind" "error"
        return
    fi

    if [[ ! -d "$HOME/.SteamDeck_rEFInd" ]]; then
        print_log "rEFInd isn't installed, install the GUI first" "error"
        return
    fi

    print_log "Installing rEFInd bootloader, please input the sudo password when prompted"
    notify-send "Installing rEFInd bootloader, please input the sudo password when prompted"
    "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
}

install_refind_all() {
    print_log "Running all install rEFInd tasks"
    install_refind_GUI
    install_refind_bootloader
}

uninstall_refind_gui() {
    print_log "Uninstalling rEFInd GUI"
    rm -vrf "$HOME/SteamDeck_rEFInd"
    rm -vrf "$HOME/.SteamDeck_rEFInd"
    rm -vf "$HOME/Desktop/refind_GUI.desktop"
}

check_for_updates_proton_ge() {
    print_log "Checking for ProtonGE Updates"
    if ! compgen -G "$configurator_dir/GE-Proton*.tar.gz" > /dev/null; then
        print_log "ProtonGE is not downloaded, please download and place it in the $configurator_dir folder first, skipping..." "error"
        notify-send "ProtonGE is not downloaded, please download and place it in the $configurator_dir folder first, skipping..."
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
        notify-send "Check For ProtonGE Updates - Steam Deck Configurator" --text="ProtonGE not up to date, \n Latest Version: $version.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
    else
        print_log "ProtonGE is up to date"
        notify-send "Check For ProtonGE Updates - Steam Deck Configurator" --text="ProtonGE is up to date"
    fi
}

interaction_install_proton_ge_in_steam() {
    print_log "Installing protonGE in steam"
    number_of_proton_ge=$(find "$configurator_dir" -name "GE-Proton*.tar.gz" | wc -l)
    if [[ $number_of_proton_ge == 1 ]]; then
        proton_ge_file=$(basename "$configurator_dir"/GE-Proton*.tar.gz)
    elif [[ $number_of_proton_ge -gt 1 ]]; then
        proton_ge_file_path=$( --zenityfile-selection --title="Select a ProtonGE version - Steam Deck Configurator" --filename="$configurator_dir/")
        proton_ge_file=$(basename "$proton_ge_file_path")
    elif [[ $number_of_proton_ge == 0 ]]; then
        print_log "Proton GE doesn't exist in this folder, please download and place it in the $configurator_dir first, skipping..." "error"
        zenity --notification --text="Proton GE doesn't exist in this folder, please download and place it in the $configurator_dir first, skipping..."
        install_proton_ge_in_steam_run=no
        sleep 3
        return
    fi
}

install_proton_ge_in_steam() {
    if [[ $install_proton_ge_in_steam_run == "no" ]]; then
        return
    fi

    print_log "Installing protonGE in steam"
    proton_ge_filename=$(basename "$proton_ge_file_path" .tar.gz)

    if [[ -d "$HOME/.steam/root/compatibilitytools.d/$proton_ge_filename" ]]; then
        print_log "$proton_ge_filename is already installed" "error"
        return
    fi
    
    mkdir -p $HOME/.steam/root/compatibilitytools.d
    tar -xf "$configurator_dir/$proton_ge_file" -C $HOME/.steam/root/compatibilitytools.d/
    print_log "Proton GE installed, please restart Steam" "notice"
}

interaction_fix_barrier() {
    if ! zenity --title "Barrier Auto Config" --question --text="Are you using auto config for the ip address?"; then
        ip_address=$(zenity --entry --title "Fix Barrier - Steam Deck Configurator" --text="input server ip address from the barrier app")
    fi
}

fix_barrier() {
    print_log "Fixing Barrier"
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

    notify-send "Applied fix, turn off SSL on both the server and host, if Barrier still doesn't work, check if you are connected on the same wifi network, and set windows resolution to 100%"
}

interaction_load_config() {
    print_log "Load config"
    if [[ -d "$configurator_dir/configs" ]]; then
        set_menu
        if chosen_files_var=$(zenity --file-selection --multiple --separator=$'\n' --title="Select a File - Load Config - Steam Deck Configurator" --filename="$configurator_dir/configs/"); then
            pre_ifs=$IFS
            IFS=$'\n'
            readarray -t config_files <<< "$chosen_files_var"
            IFS=$pre_ifs
        else
            print_log "Cancelled"
            return
        fi

        for config_file in "${config_files[@]}"; do
            readarray -t config_line < "$config_file"
            for option in "${config_line[@]}"; do
                menu=$(sed -r "s/FALSE (\"$option\" ".+?")/TRUE \1/" <<< $menu)
            done
        done
    else
        print_log "No configs found, please create one first" "error"
        sleep 3
    fi
}

load_config() {
echo "load config"
}

interaction_create_config() {
    print_log "Create config"
    if [[ ${#chosen_tasks[@]} == 1 ]]; then
        zenity --error --title="Create Config - Steam Deck Configurator" --text="Please choose the tasks to save as a config."
        return
    fi

    if [[ ! -d "$configurator_dir/configs" ]]; then
        mkdir "$configurator_dir/configs"
    fi
    
    if ! config=$(zenity --file-selection --save --title="Select a File - Create Config - Steam Deck Configurator" --filename="$configurator_dir/configs/"); then
        print_log "Cancelled"
        for chosen_task in "${chosen_tasks[@]}"; do
            if [[ "$chosen_task" != "create_config" ]]; then
                menu=$(sed -r "s/FALSE (\"$chosen_task\" ".+?")/TRUE \1/" <<< $menu)
            fi
        done
        chosen_tasks=()
        return
    fi
}

create_config() {
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
    print_log "Created config"
    notify-send "Create Config - Steam Deck Configurator" --text="created config"
    
    for chosen_task in "${chosen_tasks[@]}"; do
        if [[ "$chosen_task" != "create_config" ]]; then
            menu=$(sed -r "s/FALSE (\"$chosen_task\" ".+?")/TRUE \1/" <<< $menu)
        fi
    done
    chosen_tasks=()
}

create_dialog() {
    while true; do
        readarray -t chosen_tasks < <(echo $menu | xargs zenity --height=800 --width=1280 --list --checklist --column="command" --column="task" --column="description" --hide-column=2 --print-column=2 --separator=$'\n')
        run_tasks
    done
}

set_interactive_tasks() {
    interactive_tasks=(import_flatpaks export_flatpaks install_refind_bootloader install_flatpaks save_flatpaks_install install_proton_ge_in_steam install_bauh create_config load_config fix_barrier)
}

run_interactive_tasks() {
    sorted_chosen_tasks=($(echo "${chosen_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    interactive_tasks=($(echo "${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    chosen_interactive_tasks=($(echo "${sorted_chosen_tasks[@]} ${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq -d))

    number_of_tasks=$((${#chosen_interactive_tasks[@]}+${#chosen_tasks[@]}))

    echo "${chosen_interactive_tasks[@]}"
    for chosen_interactive_task in "${chosen_interactive_tasks[@]}"; do
        set_tasks_to_run_interactive
    done
    ran_interactive_tasks=yes
}

set_tasks_to_run_interactive() {
#    if [[ -z "$task_number" ]]; then
#        task_number=1
#    else
#        ((task_number ++))
#    fi
#    percent=$(bc -l <<< "scale=2; $task_number/$number_of_tasks")
#    progress_amount="$(bc -l <<< "$percent*100")"
#    tasks_to_run+="
#echo \"$progress_amount\""
#    tasks_to_run+="
#echo \"# interaction_$chosen_interactive_task\""
    tasks_to_run+="
interaction_$chosen_interactive_task"
#export -f "interaction_$chosen_interactive_task"
}

set_tasks_to_run() {
    if [[ -z "$task_number" ]]; then
        task_number=1
    else
        ((task_number ++))
    fi

    percent=$(bc -l <<< "scale=2; $task_number/$number_of_tasks")
    progress_amount="$(bc -l <<< "$percent*100")"

    tasks_to_run+="
echo \"$progress_amount\""
    
    tasks_to_run+="
echo \"# $chosen_task\""
    
    tasks_to_run+="
$chosen_task"
## shellcheck disable=SC2163
#export -f "$chosen_task"
#export -f "$chosen_task"
#chosen_task
}



run_tasks() {
    if [[ ${#chosen_tasks[@]} -eq 0 ]]; then
        echo "No tasks chosen, exiting..."
      #  exit 0
    fi
    unset task_number

    if [[ ! " ${chosen_tasks[*]} " =~ " load_config " ]] || [[ ! " ${chosen_tasks[*]} " =~ " create_config " ]]; then
        set_menu
    fi
    
    
    if [[ " ${chosen_tasks[*]} " =~ " load_config " ]]; then
        load_config
    elif [[ " ${chosen_tasks[*]} " =~ " create_config " ]]; then
        number_of_tasks=1
        create_config
    else
        if [[ "$ran_interactive_tasks" != "yes" ]]; then
            run_interactive_tasks
        fi
    tasks_to_run+="
("
        for chosen_task in "${chosen_tasks[@]}"; do
            set_tasks_to_run
        done
        tasks_to_run+="
) |
zenity --progress --text=text --percentage=0"
        echo "#! /usr/bin/bash" > run_zenity
        #echo "source ./functions.sh" >> run_zenity
        echo "$tasks_to_run" >> run_zenity
        #chmod +x run_zenity
        #./run_zenity
        source run_zenity
    fi

    ran_interactive_tasks=no

    if [[ -s "$configurator_dir/notices" ]]; then
        zenity --text-info --title="Notices - Steam Deck Configurator" --filename="$configurator_dir/notices"
        truncate -s 0 "$configurator_dir/notices"
    fi
}

set_menu() {
    menu='FALSE "load_config" "Load Config"
    FALSE "create_config" "Create Config"
    FALSE "add_flathub" "Add Flathub if it does not exist"
    FALSE "update_flatpaks" "Update Flatpaks"
    FALSE "import_flatpaks" "Import Flatpaks"
    FALSE "export_flatpaks" "Export Flatpaks"
    FALSE "install_flatpaks" "Install Flatpaks"
    FALSE "save_flatpaks_install" "Save Flatpaks List"
    FALSE "install_proton_ge_in_steam" "Install Proton GE in Steam"
    FALSE "install_bauh" "Install Bauh"
    FALSE "install_deckyloader" "Install DeckyLoader"
    FALSE "check_for_updates_proton_ge" "Check for Proton GE Updates"
    FALSE "install_cryoutilities" "Install CryoUtilities"
    FALSE "run_cryo_utilities_recommended" "Run CryoUtilities with recommended settings"
    FALSE "install_emudeck" "Install Emudeck"
    FALSE "update_submodules" "Update Submodules"
    FALSE "install_refind_GUI" "Install rEFInd GUI"
    FALSE "install_refind_bootloader" "Install rEFInd bootloader"
    FALSE "fix_barrier" "Fix Barrier"
    FALSE "uninstall_deckyloader" "Uninstall DeckyLoader"
    FALSE "uninstall_refind_gui" "Uninstall rEFInd GUI"'
}

main() {
    if ! zenity --title "Password - Steam Deck Configurator" --question --text="Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"; then
        exit 0
    fi

    set_interactive_tasks
    set_menu
    create_dialog
}