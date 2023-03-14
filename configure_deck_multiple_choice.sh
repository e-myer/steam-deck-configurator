#! /usr/bin/bash
source ./functions.sh

echo ""

read -p "Please make sure a sudo password is already set before continuing. If you have not set the user\
 or sudo password, please exit this installer with 'Ctrl+c' and then create a password either using 'passwd'\
 from a command line or by using the KDE Plasma User settings GUI. Otherwise, press Enter/Return to continue with the install."
 

read continue

if [[ "$continue" == "n" || ! "$continue" == "y" ]];
then
    echo "exiting..."
    exit 0
fi

echo -e "0. Default (starred) \n \
* 1. Update apps \n \
* 2. Update Flatpaks \n \
* 3. Install firefox \n \
* 4. Install_corekeyboard \n \
* 5. Install_barrier \n \
* 6. Install_heroic_games \n \
* 7. Install_ProtonUp_QT \n \
* 8. Install_BoilR \n \
* 9. Install_Flatseal \n \
* 10. Install_deckyloader \n \
* 11. Install_cryoutilities \n \
* 12. Install_emudeck \n \
* 13. Install_refind_all \n \
14. Install_refind_GUI \n \
15. Install_refind_bootloader \n \
16. Apply_refind_config \n \
17. Install_refind \n \
18. Uninstall_deckyloader \n \
19. Fix_barrier \n \n \
Which tasks to run? (0 for all the default tasks)"

tasks=("sudo pacman -Syu" \
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

default_tasks=("sudo pacman -Syu" \
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
"install_refind" )

#read input
read string
echo $string
if [ "$string" == 0 ]; #if default is chosen
then
#    echo "string is 0"
    for i in "${!default_tasks[@]}";
    do
        echo "${default_tasks[$i]}"
        ${default_tasks[$i]} #run each task in default tasks array
    done
else
    echo "string is not 0" # if default tasks isn't chosen
    IFS=' ' read -r -a chosen_tasks <<< "$string" # split the input to an array
    for i in "${chosen_tasks[@]}"
    do
        echo "${tasks[$i]}" #echo the task for each
        "${tasks[$i]}" # run the tasks 
    done
fi