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
3 "Install Firefox" on \
4 "Install Corekeyboard" on \
5 "Install Barrier" on \
6 "Install Heroic Games" on \
7 "Install ProtonUp_QT" on \
9 "Install Proton GE" on \
10 "Install BoilR" on \
11 "Install Flatseal" on \
12 "Install Steam Rom Manager" off \
13 "Install DeckyLoader" on \
14 "Install Cryoutilities" on \
15 "Run CryoUtilities with reccommended settings" off \
16 "Install Emudeck" on \
17 "Install RetroDeck" off \
18 "Install rEFInd all" on \
19 "Install rEFInd GUI" off \
20 "Install rEFInd bootloader" off \
21 "Apply rEFInd config" off \
22 "Save rEFInd config" off \
23 "Uninstall Deckyloader" off \
24 "Fix Barrier" off)

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