#! /usr/bin/bash

#run from terminal, running from vscode gives errors

source ./functions.sh

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"
#exit code of yes is 0 and no is 1

if [ $? == 1 ];
then
exit 0
fi

options=$(kdialog --checklist "Select tasks, click and drag to multiselect" \
1 "Update from pacman" on \
2 "Update Flatpaks" on \
3 "Install Firefox" on \
4 "Install Corekeyboard" on \
5 "Install Barrier" on \
6 "Install Heroic Games" on \
7 "Install ProtonUp_QT" on \
8 "Install BoilR" on \
9 "Install Flatseal" on \
10 "Install DeckyLoader" on \
11 "Install Cryoutilities" on \
12 "Install Emudeck" on \
13 "Install rEFInd all" on \
14 "Install rEFInd GUI" off \
15 "Install rEFInd bootloader" off \
16 "Apply rEFInd config" off \
17 "Install rEFInd" off \
18 "Uninstall Deckyloader" off \
19 "Fix Barrier" off)

options="${options//\"}"

IFS=' ' read -r -a chosen_tasks <<< "$options" # split the input to an array
dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
qdbus $dbusRef org.kde.kdialog.ProgressDialog.autoClose true
indexes_of_chosen_tasks=${chosen_tasks[@]}
amount_of_chosen_tasks=${#chosen_tasks[@]}

for i in $indexes_of_chosen_tasks
do
    (( task_number++ ))
    ${tasks[$i]} >> terminal_output & # run the tasks 
    qdbus $dbusRef Set "" value $i & 
    qdbus $dbusRef setLabelText "$task_number/$amount_of_chosen_tasks: ${tasks[$i]}: $(tail --lines 1 ./terminal_output)" &
    wait
    sleep 0.5
done
qdbus $dbusRef close
echo $dbusRef closed