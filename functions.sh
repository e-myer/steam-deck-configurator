#! /usr/bin/bash

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

print_log() {
    log_message=$1
    log="$task_number/${#chosen_tasks[@]}: $task - $log_message"
    echo -e "$log"
    qdbus $dbusRef setLabelText "$log"
    echo "$log" >> "$configurator_dir/logs.log"
}

update_from_pacman() {
    print_log "Updating apps from Pacman"
    sudo pacman -Syu
}

add_flathub() {
    print_log "Adding Flathub, please enter your password in the prompt"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

update_flatpaks() {
    print_log "Updating Flatpaks"
    flatpak update -y
}

set_up_import_and_export_flatpaks() {
    print_log "Seting up import and export flatpaks"
    flatpak remote-modify --collection-id=org.flathub.Stable flathub
}

install_bauh() {
    print_log "Installing Bauh"
    if [ -f "$configurator_dir/applications/bauh-0.10.5-x86_64.AppImage" ]; then
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
    for flatpak in "${chosen_export_flatpaks[@]}"
    do
        print_log "exporting ${flatpak_names[$flatpak]}"
        flatpak --verbose create-usb "$configurator_dir/flatpaks" "${flatpak_ids[$flatpak]}"
        if [ $? == 0 ]; then
            if ! grep -Fxq "${flatpak_names[$flatpak]}=${flatpak_ids[$flatpak]}" "$configurator_dir/flatpaks_list"; then
                if [[ -s "$configurator_dir/flatpaks_list" ]]; then
                    echo "${flatpak_names[$flatpak]}=${flatpak_ids[$flatpak]}" >> "$configurator_dir/flatpaks_list"
                else
                    echo "${flatpak_names[$flatpak]}=${flatpak_ids[$flatpak]}" > "$configurator_dir/flatpaks_list"
                fi
            fi
        else
            print_log "error"
        fi
    done
}

interaction_export_flatpaks() {
    mkdir -p "$configurator_dir/flatpaks"
    readarray -t flatpak_names < <(flatpak list --app --columns=name)
    readarray -t flatpak_ids < <(flatpak list --app --columns=application)

    for name in "${flatpak_names[@]}"
    do
        if [ -z "$number" ]; then
            local number=0
        else
            ((number ++))
        fi
        export_flatpaks_menu+=("$number" "$name" off)
    done
    
    readarray -t chosen_export_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${export_flatpaks_menu[@]}")
}

import_flatpaks() {
    if [ ${#chosen_import_flatpaks[@]} -eq 0 ]; then
        echo No flatpaks chosen
        return
    else
        for flatpak in "${chosen_import_flatpaks[@]}"
        do
            print_log "installing $flatpak"
            flatpak install --sideload-repo="$configurator_dir/flatpaks" flathub $flatpak -y
        done
    fi
}

interaction_import_flatpaks() {
    local -A flatpaks_array
    readarray -t lines < "$configurator_dir/flatpaks_list"

    for line in "${lines[@]}"; do
        key=${line%%=*}
        value=${line#*=}
        flatpaks_array[$key]=$value
    done

    for key in "${!flatpaks_array[@]}"
    do
        import_flatpaks_menu+=("${flatpaks_array[$key]}" "$key" off)
    done

    readarray -t chosen_import_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${import_flatpaks_menu[@]}")
}

install_deckyloader() {
    if [ -f "$configurator_dir/deckyloader_installed_version" ]; then
        print_log "Checking if latest version of DeckyLoader is installed"
        local release
        release=$(curl -s 'https://api.github.com/repos/SteamDeckHomebrew/decky-loader/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
        local version
        version=$(jq -r '.tag_name' <<< ${release} )
        local deckyloader_installed_version
        deckyloader_installed_version=$(cat "$configurator_dir/deckyloader_installed_version")
        print_log "DeckyLoader Latest Version is $version"
        print_log "DeckyLoader Installed Version is $deckyloader_installed_version"
        if [ "$version" != "$deckyloader_installed_version" ]; then
            print_log "Installing Latest Version"
            curl -L https://github.com/SteamDeckHomebrew/decky-loader/raw/main/dist/install_release.sh --output "$configurator_dir/deckyloader_install_release.sh"
            chmod -v +x "$configurator_dir/deckyloader_install_release.sh"
            "$configurator_dir/deckyloader_install_release.sh"
            echo "$version" > "$configurator_dir/deckyloader_installed_version"
        else
            print_log "Latest Version of DeckyLoader is already installed"
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
    print_log "checking if cryoutilities is installed"
    if [ ! -d "$HOME/.cryo_utilities" ]; then
        print_log "cryoutilities is not installed, installing"
        curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh --output "$configurator_dir/cryoutilities_install.sh"
        chmod -v +x "$configurator_dir/cryoutilities_install.sh"
        "$configurator_dir/cryoutilities_install.sh"
    else
        print_log "cryoutilities is already installed"
    fi
}

install_emudeck() {
    print_log "checking if emudeck is installed"
    if [ ! -d "$HOME/emudeck" ]; then
        print_log "emudeck is not installed, installing"
        curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh --output "$configurator_dir/emudeck_install.sh"
        chmod -v +x "$configurator_dir/emudeck_install.sh"
        "$configurator_dir/emudeck_install.sh"
    else
        print_log "emudeck is already installed"
    fi
}

update_submodules() {
    git submodule update --remote --merge
}

install_refind_GUI() {
    print_log "installing rEFInd GUI"
    chmod -v +x "$configurator_dir/SteamDeck_rEFInd/install-GUI.sh"
    "$configurator_dir/SteamDeck_rEFInd/install-GUI.sh" "$PWD/SteamDeck_rEFInd" # install the GUI, run the script with the argument "path for SteamDeck_rEFInd folder is $PWD/SteamDeck_rEFInd"
}

interaction_install_refind_bootloader() {
    kdialog --msgbox "It is recommended to install the rEFInd bootloader after installing other operating systems, install the refind bootloader?"
    if [ $? == 0 ]; then
        install_refind=yes
    else
        install_refind=no
    fi
}

install_refind_bootloader() {
    if [ $install_refind == yes ]; then
        print_log "Installing rEFInd bootloader, please input the sudo password when prompted"
        "$HOME/.SteamDeck_rEFInd/refind_install_pacman_GUI.sh"
    else
        print_log "didn't install refind"
        return
    fi
}

apply_refind_config() {
    if [ $apply_refind_config_run == yes ]; then
        print_log "applying config at: $refind_config, please input the sudo password when prompted"
        cp -v "$refind_config"/{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$HOME/.SteamDeck_rEFInd/GUI" #copy the refind files from the user directory to where rEFInd expects it to install the config
        if [ $? == 0 ]; then
            "$HOME/.SteamDeck_rEFInd/install_config_from_GUI.sh"
            print_log "config applied"
        else
            cp_error=$?
            print_log "error $cp_error, config not applied"
            kdialog --error "error: $cp_error, config not saved"
        fi
    else
        print_log "didn't apply refind config"
        return
    fi
}

interaction_apply_refind_config() {
    print_log "applying rEFInd config"
    if [ ! -d "$configurator_dir/configs" ]; then
        kdialog --msgbox "No rEFInd configs found, please create one first, skipping..."
        apply_refind_config_run=no
        return
    else
        apply_refind_config_run=yes
    fi
    local num_of_dirs
    num_of_dirs=$(find "$configurator_dir/rEFInd_configs" -mindepth 1 -maxdepth 1 -type d | wc -l)
    if [ "$num_of_dirs" -gt 1 ]; then
        refind_config=$(zenity --file-selection --title="select a file" --filename="$configurator_dir/rEFInd_configs/" --directory)
        if [ $? != 0 ]; then
            print_log "cancelled"
            apply_refind_config_run=no
            return
        fi
    else
        refind_config=$(find "$configurator_dir/rEFInd_configs" -mindepth 1 -maxdepth 1 -type d)
        if [ $? != 0 ]; then
            print_log "cancelled"
            apply_refind_config_run=no
            return
        fi    
    fi
}

save_refind_config() {
    if [ $save_refind_config_run == yes ]; then
        print_log "saving rEFInd config"
            mkdir -p "$config_save_path"
            cp -v "$HOME/.SteamDeck_rEFInd/GUI/"{refind.conf,background.png,os_icon1.png,os_icon2.png,os_icon3.png,os_icon4.png} "$config_save_path"
            if [ $? == 0 ]; then
                print_log "config saved to $config_save_path"
                kdialog --msgbox "config saved to $config_save_path"
            else
                cp_error=$?
                print_log "error $cp_error, config not saved"
                kdialog --error "error: $cp_error, config not saved"
            fi
    else
        print_log "didn't save refind config"
        return
    fi
}

interaction_save_refind_config() {
    kdialog --msgbox "A config must be created using the rEFInd GUI first, by editing the config and clicking on \"Create Config\", continue?"
    if [ $? == 0 ]; then
        save_refind_config_run=yes
        if [ ! -d "$configurator_dir/configs" ]; then
            mkdir "$configurator_dir/configs"
        fi
        config_save_path=$(zenity --file-selection --save --title="Save config" --filename="$configurator_dir/rEFInd_configs/")
        if [ $? != 0 ]; then
            print_log "cancelled"
            return
        fi
    else
        save_refind_config_run=no
        print_log "cancelled"
        return
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
    if compgen -G "$configurator_dir/GE-Proton*.tar.gz" > /dev/null; then
        local version
        version=$(curl -s 'https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases' | jq -r "first(.[] | select(.prerelease == "false"))")
        version=$(jq -r '.tag_name' <<< ${release} )
        local proton_ge_downloaded_version
        proton_ge_downloaded_version="$(basename $configurator_dir/GE-Proton*.tar.gz)"
        if [ ! "$proton_ge_downloaded_version" == "$version.tar.gz" ]; then
            print_log "ProtonGE not up to date, \n Latest Version: $version.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
        else
            print_log "ProtonGE is up to date"
        fi
    else
        print_log "ProtonGE is not downloaded, please download and place it in the $configurator_dir folder first, skipping..."
        sleep 3
    fi
}

install_proton_ge_in_steam() {
    if compgen -G "$configurator_dir/GE-Proton*.tar.gz" > /dev/null; then
        mkdir -p ~/.steam/root/compatibilitytools.d
        tar -xf "$configurator_dir/GE-Proton*.tar.gz" -C ~/.steam/root/compatibilitytools.d/
        print_log "Proton GE installed, please restart Steam"
    else
        print_log "Proton GE doesn't exist in this folder, please download and place it in the $configurator_dir first, skipping..."
        sleep 3
    fi
}

fix_barrier() {
    print_log "Fixing Barrier"
    kdialog --title "Barrier Auto Config" --yesno "Are you using auto config for the ip address?"
    if [ $? == 1 ]; then
        ip_address=$(kdialog --title "Input dialog" --inputbox "input server ip address from the barrier app")
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

interaction_save_flatpaks_install() {
    readarray -t flatpak_names < <(flatpak list --app --columns=name)
    readarray -t flatpak_ids < <(flatpak list --app --columns=application)

    for name in "${flatpak_names[@]}"
    do
        if [ -z "$number" ]; then
            local number=0
        else
            ((number ++))
        fi
        save_flatpaks_menu+=("$number" "$name" off)
    done
    
    readarray -t chosen_save_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${save_flatpaks_menu[@]}")
}

save_flatpaks_install() {
    print_log "saving flatpaks list"
    for flatpak in "${chosen_save_flatpaks[@]}"
    do
        print_log "saving ${flatpak_names[$flatpak]}"
            if ! grep -Fxq "${flatpak_names[$flatpak]}=${flatpak_ids[$flatpak]}" "$configurator_dir/flatpaks_install_list"; then
                if [[ ! -s "$configurator_dir/flatpaks_list" ]]; then
                    echo Clear List=clear_list > "$flatpak_install_list_file"
                fi
                echo "${flatpak_names[$flatpak]}=${flatpak_ids[$flatpak]}" >> "$configurator_dir/flatpaks_install_list"
            fi
    done
}

install_flatpaks() {
    if [ ${#chosen_install_flatpaks[@]} -eq 0 ]; then
        echo No flatpaks chosen
        return
    elif [[ " ${chosen_install_flatpaks[*]} " =~ " clear_list " ]]; then
        echo Clear List=clear_list > "$flatpak_install_list_file"
        echo List cleared
    else
        for flatpak in "${chosen_install_flatpaks[@]}"
        do
        echo $flatpak
            print_log "installing $flatpak"
            flatpak install flathub $flatpak -y
        done
    fi
}

interaction_install_flatpaks() {
    if [ -f "$configurator_dir/flatpaks_install_list" ]; then
        flatpak_install_list_file=$configurator_dir/flatpaks_install_list
    else
        flatpak_install_list_file=$configurator_dir/flatpaks_install_list_default
    fi

    install_flatpaks_menu=()
    lines=()
    unset order
    local -A flatpaks_install_array
    readarray -t lines < "$flatpak_install_list_file"

    for line in "${lines[@]}"; do
        key=${line%%=*}
        value=${line#*=}
        flatpaks_install_array[$key]=$value
        order+=("$key")
    done

    for key in "${order[@]}"
    do
        install_flatpaks_menu+=("${flatpaks_install_array[$key]}" "$key" off)
    done

    readarray -t chosen_install_flatpaks < <(kdialog --separate-output --checklist "Select Flatpaks" "${install_flatpaks_menu[@]}")
}


load_config() {
    if [ -d "$configurator_dir/configs" ]; then
        set_menu
        readarray -t config_files < <(zenity --file-selection --multiple --separator=$'\n' --title="select a file" --filename="$configurator_dir/configs/")
        if [ $? != 0 ]; then
            print_log "cancelled"
            return
        fi
        for file in "${config_files[@]}"
        do
            readarray -t config_line < $file
            for option in "${config_line[@]}"
            do
                menu=$(sed -r "s/(\"$option\" ".+?") off/\1 on/" <<< $menu)
            done
        done
    else
        kdialog --msgbox "No configs found, please create one first"
    fi
}

create_dialog() {
    while true; do
    readarray -t chosen_tasks < <(echo $menu | xargs kdialog --separate-output --geometry 1280x800 --checklist "Select tasks, click and drag to multiselect")
    run_tasks
    done
}

create_config() {
    if [ ${#chosen_tasks[@]} == 1 ]; then
        kdialog --error "Please choose the tasks to save as a config."
        return
    fi

    if [ ! -d "$configurator_dir/configs" ]; then
        mkdir "$configurator_dir/configs"
    fi
    local config
    config=$(zenity --file-selection --save --title="select a file" --filename="$configurator_dir/configs/")
    if [ $? != 0 ]; then
        print_log "cancelled"
        chosen_tasks=()
        return
    fi

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
    chosen_tasks=()
    print_log "created config"
}

set_interactive_tasks() {
    interactive_tasks=(save_refind_config apply_refind_config import_flatpaks export_flatpaks install_refind_bootloader install_flatpaks save_flatpaks_install)
}

run_interactive_tasks() {
    sorted_chosen_tasks=($(echo "${chosen_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    interactive_tasks=($(echo "${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    chosen_interactive_tasks=($(echo "${sorted_chosen_tasks[@]} ${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq -d))

    echo "${chosen_interactive_tasks[@]}"
    for task in "${chosen_interactive_tasks[@]}"
    do
        interaction_$task
    done
    ran_interactive_tasks=yes
}

run_tasks() {
    if [ ${#chosen_tasks[@]} -eq 0 ]; then
        echo No tasks chosen, exiting...
        exit 0
    fi
    unset task_number
    qdbus $dbusRef close
    dbusRef=$(kdialog --progressbar "Steam Deck Configurator" ${#chosen_tasks[@]})
    qdbus $dbusRef setLabelText "Steam Deck Configurator"

    if [ "$ran_interactive_tasks" != "yes" ]; then
        run_interactive_tasks
    fi

    for task in "${chosen_tasks[@]}"
    do
        if [ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ] && [[ " ${chosen_tasks[*]} " =~ " ${task} " ]]; then
            ((task_number ++))
            echo $task
            $task
            qdbus $dbusRef Set "" value $task_number
        fi
    done
    ran_interactive_tasks=no
    qdbus $dbusRef setLabelText "$task_number/${#chosen_tasks[@]}: Tasks completed"
}

set_menu() {
    menu='"load_config" "Load Config" off 
    "create_config" "Create Config" off 
    "update_from_pacman" "Update from pacman" off 
    "add_flathub" "Add Flathub if it does not exist" off 
    "update_flatpaks" "Update Flatpaks" off 
    "set_up_import_and_export_flatpaks" "Set up import and export Flatpaks" off 
    "import_flatpaks" "Import Flatpaks" off 
    "export_flatpaks" "Export Flatpaks" off 
    "install_flatpaks" "Install Flatpaks" off
    "save_flatpaks_install" "Save Flatpaks List" off
    "install_proton_ge_in_steam" "Install Proton GE in Steam" off 
    "install_bauh" "Install Bauh" off 
    "install_deckyloader" "Install DeckyLoader" off 
    "uninstall_deckyloader" "Uninstall DeckyLoader" off 
    "refind_uninstall_gui" "Uninstall rEFInd GUI" off 
    "check_for_updates_proton_ge" "Check for Proton GE Updates" off 
    "install_cryoutilities" "Install Cryoutilities" off 
    "run_cryo_utilities_recommended" "Run CryoUtilities with recommended settings" off 
    "install_emudeck" "Install Emudeck" off 
    "install_retrodeck" "Install RetroDeck" off 
    "update_submodules" "Update Submodules" off 
    "install_refind_GUI" "Install rEFInd GUI" off 
    "install_refind_bootloader" "Install rEFInd bootloader" off 
    "apply_refind_config" "Apply rEFInd config" off 
    "save_refind_config" "Save rEFInd config" off 
    "fix_barrier" "Fix Barrier" off'
}