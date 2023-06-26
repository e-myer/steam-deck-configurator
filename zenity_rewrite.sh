#! /usr/bin/bash

# Configures various functions in a Steam Deck

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

add_flathub() {
    echo adding flathub
    print_log "Adding Flathub"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

list_flatpaks() {
    echo listing flatpaks
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
    echo updating flatpaks
    print_log "Updating Flatpaks"
    echo "listing flatpaks"
    list_flatpaks

    if [[ ${#flatpak_names[@]} == 0 ]]; then
        print_log "Error, no Flatpaks installed" "error"
        sleep 3
        return
    fi
    echo "updATING NOW"
    flatpak update -y
}

check_for_updates_proton_ge() {
    print_log "Checking for ProtonGE Updates"
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
        zenity --error --title="Check For ProtonGE Updates - Steam Deck Configurator" --text="ProtonGE not up to date, \n Latest Version: $version.tar.gz \n Downloaded Version: $proton_ge_downloaded_version \n please download the latest version, and remove the currently downloaded version"
    else
        print_log "ProtonGE is up to date"
        zenity --error --title="Check For ProtonGE Updates - Steam Deck Configurator" --text="ProtonGE is up to date"

    fi
}

install_bauh() {
    print_log "Installing Bauh"
    if [[ ! -f "$configurator_dir/applications/bauh-0.10.5-x86_64.AppImage" ]]; then
        print_log "Bauh appimage doesn't exist in this folder, download it first, skipping..." "error"
        zenity --notification --window-icon="info" --text="bauh appimage doesn't exist in this folder, download it first, skipping..."
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

print_log() {
    log_message=$1
    log="$task_number/$number_of_tasks: $task - $log_message"
    echo "log is $log"
    echo "# $log" >> zenity_progress_2
    percent=$(bc -l <<< "scale=2; $task_number/$number_of_tasks")
    progress_amount="$(bc -l <<< "$percent*100")"
    echo "$progress_amount" >> zenity_progress_2
    echo "$log" >> "$configurator_dir/logs.log"
    if [[ "$2" == "error" ]]; then
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >&2
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >> "$configurator_dir/notices"
    elif [[ "$2" == "error" ]]; then
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $1" >> "$configurator_dir/notices"
    else
        echo -e "$log"
    fi
}

create_dialog() {
    while true; do
        readarray -t chosen_tasks < <(echo "$menu" | xargs zenity --list --checklist --separator=$'\n' --column=status --column=task --column=label --print-column=2 --hide-column=2)
        echo "${chosen_tasks[@]}"
        run_tasks
    done
}

load_config() {
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
        #    return
        fi

        for config_file in "${config_files[@]}"; do
            readarray -t config_line < "$config_file"
            for option in "${config_line[@]}"; do
                menu=$(sed -r "s/FALSE (\"$option\" ".+?")/TRUE \1/" <<< $menu)
            done
        done
    else
        print_log "No configs found, please create one first" "error"
    fi
}

create_config() {
    print_log "Create config"
    if [[ ${#chosen_tasks[@]} == 1 ]]; then
        zenity --error --title="Create Config - Steam Deck Configurator" --text="Please choose the tasks to save as a config."
        return
    fi

    if [[ ! -d "$configurator_dir/configs" ]]; then
        mkdir "$configurator_dir/configs"
    fi
    
    local config
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
    zenity --info --title "Create Config - Steam Deck Configurator" --text="created config"
    
    for chosen_task in "${chosen_tasks[@]}"; do
        if [[ "$chosen_task" != "create_config" ]]; then
            menu=$(sed -r "s/FALSE (\"$chosen_task\" ".+?")/TRUE \1/" <<< $menu)
        fi
    done
    chosen_tasks=()
}

set_interactive_tasks() {
    interactive_tasks=(import_flatpaks export_flatpaks install_refind_bootloader install_flatpaks save_flatpaks_install install_proton_ge_in_steam)
}

run_interactive_tasks() {
    sorted_chosen_tasks=($(echo "${chosen_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    interactive_tasks=($(echo "${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq))
    chosen_interactive_tasks=($(echo "${sorted_chosen_tasks[@]} ${interactive_tasks[@]}" | sed 's/ /\n/g' | sort | uniq -d))

    number_of_tasks=$((${#chosen_interactive_tasks[@]}+${#chosen_tasks[@]}))

    touch zenity_progress_2

    if [[ $tailing_progress != 1 ]]; then
        (tail -f zenity_progress_2) | zenity --progress &
        tailing_progress=1
    fi

    #if ! qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled &> /dev/null; then
    #    dbusRef=$(kdialog --title "Steam Deck Configurator" --progressbar "Steam Deck Configurator" "$number_of_tasks")
    #else
    #    qdbus $dbusRef org.kde.kdialog.ProgressDialog.maximum "$number_of_tasks"
    #    qdbus $dbusRef /ProgressDialog org.kde.kdialog.ProgressDialog.value 0
    #fi

    echo "${chosen_interactive_tasks[@]}"
    for chosen_interactive_task in "${chosen_interactive_tasks[@]}"; do
        if [[ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ]]; then
            ((task_number ++))
            echo interaction_$chosen_interactive_task
            interaction_$chosen_interactive_task
            #qdbus $dbusRef Set "" value $task_number
        fi
    done
    ran_interactive_tasks=yes
}

run_tasks() {
    echo "KJSHDFKAJSFHLAKFJH"
    if [[ ${#chosen_tasks[@]} -eq 0 ]]; then
        echo "No tasks chosen, exiting..."
        exit 0
    fi
    unset task_number
    echo chosen_tasks is "${chosen_tasks[@]}"
    touch zenity_progress_2
    echo "abc"
    if [[  " ${chosen_tasks[*]} " =~ " load_config " ]]; then
        number_of_tasks=1
        chosen_tasks=(load_config)
    elif [[ " ${chosen_tasks[*]} " =~ " create config " ]]; then
        number_of_tasks=1
    #elif [[ "$ran_interactive_tasks" != "yes" ]]; then
    #    run_interactive_tasks
    fi

    echo "echoing 0 to progress file"
    echo "0" >> zenity_progress_2
    echo "echoed 0 to progress file"
    
    if [[ $tailing_progress != 1 ]]; then
        echo "tailing_progress is not 1"
        (tail -f zenity_progress_2) | zenity --progress &
        echo "after progress"
        tailing_progress=1
    fi

    number_of_tasks=${#chosen_tasks[@]}
    echo "number_of_tasks is $number_of_tasks"
    for chosen_task in "${chosen_tasks[@]}"; do
        echo "chosen task is $chosen_task"
        ((task_number ++))
        echo $chosen_task
        $chosen_task
    done
}


set_menu() {
    echo setting menu...
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

set_menu
create_dialog
echo "deleting zenity_progress_2"
rm zenity_progress_2

