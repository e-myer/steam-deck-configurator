#! /usr/bin/bash

source ./functions.sh

#kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"
#exit code of yes is 0 and no is 1

#if [ $? == 1 ];
#then
#exit 0
#fi



#declare -A colors
#colors["red"]="#ff0000"
#colors["green"]="#00ff00"
#colors["blue"]="#0000ff"

#echo "${colors[red]}"
#echo "${!colors[@]}"

#for color in "${!colors[@]}"; do
#    echo "${color} => ${colors[${color}]}"
#done
echo running...
declare -A tasks_array
tasks_array["Update from pacman"]="sudo pacman -Syu"
tasks_array["Add Flathub if it doesn't exist"]="$add_flathub"
tasks_array["Update Flatpaks"]="flatpak update -y"
tasks_array["Set up import Flatpaks"]="set_up_import_flatpaks"
tasks_array["Import Firefox"]="$import_firefox"
tasks_array["Import Corekeyboard"]="$import_corekeyboard"
tasks_array["Import Barrier"]="$import_barrier"
tasks_array["Import Heroic_games"]="$import_heroic_games"
tasks_array["Import ProtonUp_QT"]="$import_ProtonUp_QT"
tasks_array["Install Proton GE in Steam"]="install_proton_ge_in_steam"
tasks_array["Import BoilR"]="$import_BoilR"
tasks_array["Import Flatseal"]="$import_Flatseal"
tasks_array["Import Steam ROM Manager"]="$import_steam_rom_manager"
tasks_array["Install Firefox"]="$install_firefox -y"
tasks_array["Install Corekeyboard"]="$install_corekeyboard -y"
tasks_array["Install Barrier"]="$install_barrier -y"
tasks_array["Install Heroic Games"]="$install_heroic_games -y"
tasks_array["Install ProtonUp_QT"]="$install_ProtonUp_QT -y"
tasks_array["Install BoilR"]="$install_BoilR -y"
tasks_array["Install Flatseal"]="$install_Flatseal -y"
tasks_array["Install Steam Rom Manager"]="$install_steam_rom_manager -y"
tasks_array["Install DeckyLoader"]="install_deckyloader"
tasks_array["Install Cryoutilities"]="install_cryoutilities"
tasks_array["Run CryoUtilities with reccommended settings"]="$run_cryo_utilities_reccommended"
tasks_array["Install Emudeck"]="install_emudeck"
tasks_array["Install RetroDeck"]="$install_retrodeck"
tasks_array["Install rEFInd GUI"]="install_refind_GUI"
tasks_array["Install rEFInd bootloader"]="install_refind_bootloader"
tasks_array["Apply rEFInd config"]="apply_refind_config"
tasks_array["Save rEFInd config"]="save_refind_config"
tasks_array["Uninstall Deckyloader"]="uninstall_deckyloader"
tasks_array["Fix Barrier"]="fix_barrier"

echo ${tasks_array[Install Flatseal]}
echo "${colors[red]}"

exit 0

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
    ${tasks[$i]} # run the tasks 
    else
    echo "Task \"${tasks[$i]}\" not executed, exiting..."
    exit 0
    fi
done
qdbus $dbusRef close
echo $dbusRef closed