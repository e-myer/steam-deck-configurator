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
1 "Update Flatpaks" on \
2 "Install Firefox" on \
3 "Install Corekeyboard" on \
4 "Install Barrier" on \
5 "Install Heroic Games" on \
6 "Install ProtonUp_QT" on \
7 "Install BoilR" on \
8 "Install Flatseal" on \
9 "Add Flathub" on \
10 "Install DeckyLoader" on \
11 "Install Cryoutilities" on \
12 "Install Emudeck" on \
13 "Install rEFInd all" on \
14 "Install rEFInd GUI" off \
15 "Install rEFInd bootloader" off \
16 "Apply rEFInd config" off \
17 "Save rEFInd config" off \
18 "Install rEFInd" off \
19 "Uninstall Deckyloader" off \
20 "Fix Barrier" off)

options="${options//\"}"

IFS=' ' read -r -a chosen_tasks <<< "$options" # split the input to an array
dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
#qdbus $dbusRef org.kde.kdialog.ProgressDialog.autoClose true

for i in "${chosen_tasks[@]}"
do
    qdbus $dbusRef Set "" value $i
    qdbus $dbusRef setLabelText "$i/${#chosen_tasks[@]}: ${tasks[$i]}"
    sleep 0.5
#    ${tasks[$i]} # run the tasks 
done
qdbus $dbusRef close
echo $dbusRef closed