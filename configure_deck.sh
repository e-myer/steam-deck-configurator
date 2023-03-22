#! /usr/bin/bash

source ./functions.sh

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"

if [ $? == 1 ];
then
exit 0
fi

readarray -t chosen_tasks < <(kdialog --separate-output --checklist "Select tasks, click and drag to multiselect" \
"${tasks_array[Update from pacman]}" "Update from pacman" on \
"${tasks_array[Add Flathub if it does not exist]}" "Add Flathub if it doesn't exist" on \
"${tasks_array[Update Flatpaks]}" "Update Flatpaks" on \
"${tasks_array[Set up import Flatpaks]}" "Set up import Flatpaks" on \
"${tasks_array[Import Firefox]}" "Import Firefox" on \
"${tasks_array[Import Corekeyboard]}" "Import Corekeyboard" on \
"${tasks_array[Import Barrier]}" "Import Barrier" on \
"${tasks_array[Import Heroic_games]}" "Import Heroic_games" on \
"${tasks_array[Import ProtonUp_QT]}" "Import ProtonUp_QT" on \
"${tasks_array[Install Proton GE in Steam]}" "Install Proton GE in Steam" on \
"${tasks_array[Import BoilR]}" "Import BoilR" on \
"${tasks_array[Import Flatseal]}" "Import Flatseal" on \
"${tasks_array[Import Steam ROM Manager]}" "Import Steam ROM Manager" on \
"${tasks_array[Install Firefox]}" "Install Firefox" off \
"${tasks_array[Install Corekeyboard]}" "Install Corekeyboard" off \
"${tasks_array[Install Barrier]}" "Install Barrier" off \
"${tasks_array[Install Heroic Games]}" "Install Heroic Games" off \
"${tasks_array[Install ProtonUp_QT]}" "Install ProtonUp_QT" off \
"${tasks_array[Install BoilR]}" "Install BoilR" off \
"${tasks_array[Install Flatseal]}" "Install Flatseal" off \
"${tasks_array[Install Steam Rom Manager]}" "Install Steam Rom Manager" off \
"${tasks_array[Install DeckyLoader]}" "Install DeckyLoader" on \
"${tasks_array[Install Cryoutilities]}" "Install Cryoutilities" on \
"${tasks_array[Run CryoUtilities with reccommended settings]}" "Run CryoUtilities with reccommended settings" off \
"${tasks_array[Install Emudeck]}" "Install Emudeck" on \
"${tasks_array[Install RetroDeck]}" "Install RetroDeck" off \
"${tasks_array[Install rEFInd GUI]}" "Install rEFInd GUI" on \
"${tasks_array[Install rEFInd bootloader]}" "Install rEFInd bootloader" on \
"${tasks_array[Apply rEFInd config]}" "Apply rEFInd config" on \
"${tasks_array[Save rEFInd config]}" "Save rEFInd config" off \
"${tasks_array[Uninstall Deckyloader]}" "Uninstall Deckyloader" off \
"${tasks_array[Fix Barrier]}" "Fix Barrier" off)

echo ${chosen_tasks[@]}


dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
qdbus $dbusRef org.kde.kdialog.ProgressDialog.autoClose true

for i in "${chosen_tasks[@]}"
do
    ((task_number ++))
    qdbus $dbusRef Set "" value $task_number
    qdbus $dbusRef setLabelText "Initializing..."
#    sleep 0.5
#    sleep 2
    if [ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ];
    then
#    echo $i
    $i #run task
    else
    echo "Task \"${tasks[$i]}\" not executed, exiting..."
    exit 0
    fi
done
#qdbus $dbusRef close
#echo $dbusRef closed