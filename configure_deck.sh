#! /usr/bin/bash

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
configurator_parent_dir="$(dirname "$configurator_dir")"

source "$configurator_dir/functions.sh"

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"

if [ $? == 1 ];
then
exit 0
fi

if [ -d "$configurator_parent_dir/presets" ]
then
kdialog --title "presets" --yesno "Preset found, use a preset?"

    if [ $? == 0 ];
    then
    num_of_presets=$(find "$configurator_parent_dir/presets" -mindepth 1 -maxdepth 1 -type f | wc -l)
        if [ "$num_of_presets" -gt 1 ]; then
        preset=$(zenity --file-selection --title="select a file" --filename="$configurator_parent_dir/presets/")
        else
        preset=$(find "$configurator_parent_dir/presets" -mindepth 1 -maxdepth 1 -type f)
        fi
        source "$preset"
        print_log "sourced $preset"
    else
    readarray -t chosen_tasks < <(kdialog --separate-output --geometry 1280x800 --checklist "Select tasks, click and drag to multiselect" \
    "${tasks_array[Add Flathub if it does not exist]}" "Add Flathub if it doesn't exist" off \
    "${tasks_array[Update Flatpaks]}" "Update Flatpaks" off \
    "${tasks_array[Set up import and export Flatpaks]}" "Set up import and export Flatpaks" off \
    "${tasks_array[Import Firefox]}" "Import Firefox" off \
    "${tasks_array[Import Corekeyboard]}" "Import Corekeyboard" off \
    "${tasks_array[Import Barrier]}" "Import Barrier" off \
    "${tasks_array[Import Heroic_games]}" "Import Heroic_games" off \
    "${tasks_array[Import ProtonUp_QT]}" "Import ProtonUp_QT" off \
    "${tasks_array[Install Proton GE in Steam]}" "Install Proton GE in Steam" off \
    "${tasks_array[Import BoilR]}" "Import BoilR" off \
    "${tasks_array[Import Flatseal]}" "Import Flatseal" off \
    "${tasks_array[Import Steam ROM Manager]}" "Import Steam ROM Manager" off \
    "${tasks_array[Install Firefox]}" "Install Firefox" off \
    "${tasks_array[Install Corekeyboard]}" "Install Corekeyboard" off \
    "${tasks_array[Install Barrier]}" "Install Barrier" off \
    "${tasks_array[Install Heroic Games]}" "Install Heroic Games" off \
    "${tasks_array[Install ProtonUp_QT]}" "Install ProtonUp_QT" off \
    "${tasks_array[Install BoilR]}" "Install BoilR" off \
    "${tasks_array[Install Flatseal]}" "Install Flatseal" off \
    "${tasks_array[Install Bauh]}" "Install Bauh" off \
    "${tasks_array[Install Steam Rom Manager]}" "Install Steam Rom Manager" off \
    "${tasks_array[Install DeckyLoader]}" "Install DeckyLoader" off \
    "${tasks_array[Install Cryoutilities]}" "Install Cryoutilities" off \
    "${tasks_array[Install Emudeck]}" "Install Emudeck" off \
    "${tasks_array[Install RetroDeck]}" "Install RetroDeck" off \
    "${tasks_array[Update Submodules]}" "Update Submodules" off \
    "${tasks_array[Install rEFInd GUI]}" "Install rEFInd GUI" off \
    "${tasks_array[Install rEFInd bootloader]}" "Install rEFInd bootloader" off \
    "${tasks_array[Apply rEFInd config]}" "Apply rEFInd config" off \
    "${tasks_array[Save rEFInd config]}" "Save rEFInd config" off \
    "${tasks_array[Export Flatpaks]}" "Export Flatpaks" off \
    "${tasks_array[Import Flatpaks]}" "Import Flatpaks" off \
    "${tasks_array[Uninstall Deckyloader]}" "Uninstall Deckyloader" off \
    "${tasks_array[Install Non Steam Launchers]}" "Install Non Steam Launchers" off \
    "${tasks_array[Fix Barrier]}" "Fix Barrier" off \
    "${tasks_array[Uninstall rEFInd GUI]}" "Uninstall rEFInd GUI" off \
    "${tasks_array[Check for Proton GE Updates]}" "Check for Proton GE Updates" off \
    "${tasks_array[Update from pacman]}" "Update from pacman" off \
    "${tasks_array[Run CryoUtilities with recommended settings]}" "Run CryoUtilities with recommended settings" off)
    fi
fi

echo ${chosen_tasks[@]}
if [ ${#chosen_tasks[@]} -eq 0 ]
then
echo No tasks chosen, exiting...
exit 0
fi

dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
qdbus $dbusRef setLabelText "Initializing..."

for task in "${chosen_tasks[@]}"
do
    ((task_number ++))
    if [ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ];
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
