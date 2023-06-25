#! /usr/bin/bash

# Configures various functions in a Steam Deck

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echoes_hi() {
    echo hi
}

echoes_ho() {
    echo ho
}

echoes_he() {
    echo he
}

#set_menu() {
#menu='FALSE "echoes_hi" "echo hi" \
#FALSE "echoes_ho" "echo ho" \
#FALSE "echoes_he" "echo he"'
#}


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

print_log() {
    log_message=$1
    log="$task_number/$number_of_tasks: $task - $log_message"
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
        #echo "${chosen_tasks[@]}"
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
    fi
}

create_config() {
    print_log "Create config"
    if [[ ${#chosen_tasks[@]} == 1 ]]; then
        #kdialog --title "Create Config - Steam Deck Configurator" --error "Please choose the tasks to save as a config."
        zenity --title="Create Config - Steam Deck Configurator" --error --text="Please choose the tasks to save as a config."
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



run_tasks() {
    #echo "${chosen_tasks[@]}"
    #echo "${#chosen_tasks[@]}"

    for chosen_task in "${chosen_tasks[@]}"; do
        $chosen_task
    done
}


set_menu
create_dialog

