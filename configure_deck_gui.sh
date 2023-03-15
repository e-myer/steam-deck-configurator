#! /usr/bin/bash
source ./functions.sh

echo ""

read -p "Please make sure a sudo password is already set before continuing. If you have not set the user\
 or sudo password, please exit this installer with 'Ctrl+c' and then create a password either using 'passwd'\
 from a command line or by using the KDE Plasma User settings GUI. Otherwise, press Enter/Return to continue with the install."

kdialog --title "YesNoCancel dialog" --yesnocancel "About to exit.\n \
Do you want to save the file first?"


string=`kdialog --checklist "Select languages:" \
1 "sudo pacman -Syu" on \
2 "flatpak update -y" on \
3 "install_firefox -y" on \
4 "$install_corekeyboard -y" on \
5 "$install_barrier -y" on \
6 "$install_heroic_games -y" on \
7 "$install_ProtonUp_QT -y" on \
8 "$install_BoilR -y" on \
9 "$install_Flatseal -y" on \
10 "install_deckyloader" on \
11 "install_cryoutilities" on \
12 "install_emudeck" on \
13 "install_refind_all" on \
14 "install_refind_GUI" off \
15 "install_refind_bootloader" off \
16 "apply_refind_config" off \
17 "install_refind" off \
18 "uninstall_deckyloader" off \
19 "fix_barrier" off`

string="${string//\"}"

echo $string

echo "string is not 0" # if default tasks isn't chosen
IFS=' ' read -r -a chosen_tasks <<< "$string" # split the input to an array
for i in "${chosen_tasks[@]}"
do
    echo "${tasks[$i]}" #echo the task for each
#        "${tasks[$i]}" # run the tasks 
done