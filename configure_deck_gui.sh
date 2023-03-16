#! /usr/bin/bash


trap \
 '{ qdbus $dbusRef close ; exit 255; }' \
 SIGINT SIGTERM ERR EXIT


source ./functions.sh

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"
#exit code of yes is 0 and no is 1

if [ $? == 1 ];
then
exit 0
fi

tasks=( "echo default" \
"sudo pacman -Syu" \
"flatpak update -y" \
"$install_firefox -y" \
"$install_corekeyboard -y" \
"$install_barrier -y" \
"$install_heroic_games -y" \
"$install_ProtonUp_QT -y" \
"$install_BoilR -y" \
"$install_Flatseal -y" \
"install_deckyloader" \
"install_cryoutilities" \
"install_emudeck" \
"install_refind_all" \
"install_refind_GUI" \
"install_refind_bootloader" \
"apply_refind_config" \
"install_refind" \
"uninstall_deckyloader" \
"fix_barrier" )

options=`kdialog --checklist "Select tasks, click and drag to multiselect" \
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
19 "Fix Barrier" off`

options="${options//\"}"

IFS=' ' read -r -a chosen_tasks <<< "$options" # split the input to an array
dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})

for i in "${chosen_tasks[@]}"
do
    echo "i in $i"
    echo "${tasks[$i]}" #echo the task for each
    qdbus $dbusRef Set "" value $i
    qdbus $dbusRef setLabelText "${tasks[$i]}"
#        "${tasks[$i]}" # run the tasks 
done
echo last line