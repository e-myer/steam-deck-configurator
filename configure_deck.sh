#! /usr/bin/bash

source ./functions.sh

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"
#exit code of yes is 0 and no is 1

if [ $? == 1 ];
then
exit 0
fi

options=$(kdialog --checklist "Select tasks, click and drag to multiselect" \
0 "Update from pacman" on \
1 "Add Flathub if it doesn't exist" on \
2 "Update Flatpaks" on \
3 "Set up import Flatpaks" on \
4 "Import Firefox" on \
5 "Import Corekeyboard" on \
6 "Import Barrier" on \
7 "Import Heroic_games" on \
8 "Import ProtonUp_QT" on \
9 "Install Proton GE in Steam" on \
10 "Import BoilR" on \
11 "Import Flatseal" on \
12 "Import Steam ROM Manager" on \
13 "Install Firefox" off \
14 "Install Corekeyboard" off \
15 "Install Barrier" off \
16 "Install Heroic Games" off \
17 "Install ProtonUp_QT" off \
18 "Install BoilR" off \
19 "Install Flatseal" off \
20 "Install Steam Rom Manager" off \
21 "Install DeckyLoader" on \
22 "Install Cryoutilities" on \
23 "Run CryoUtilities with reccommended settings" off \
24 "Install Emudeck" on \
25 "Install RetroDeck" off \
26 "Install rEFInd all" on \
27 "Install rEFInd GUI" off \
28 "Install rEFInd bootloader" off \
29 "Apply rEFInd config" off \
30 "Save rEFInd config" off \
31 "Uninstall Deckyloader" off \
32 "Fix Barrier" off)

options="${options//\"}"

IFS=' ' read -r -a chosen_tasks <<< "$options" # split the input to an array
dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
qdbus $dbusRef org.kde.kdialog.ProgressDialog.autoClose true

for i in "${chosen_tasks[@]}"
do
    ((task_number ++))
    qdbus $dbusRef Set "" value $i
    qdbus $dbusRef setLabelText "$task_number/${#chosen_tasks[@]}: ${tasks[$i]}"
#    sleep 0.5
#    sleep 2
    if [ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ];
    then
    echo ${tasks[$i]}
#    ${tasks[$i]} # run the tasks 
    else
    echo "Task \"${tasks[$i]}\" not executed, exiting..."
    exit 0
    fi
done
qdbus $dbusRef close
echo $dbusRef closed