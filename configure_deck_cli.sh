#! /usr/bin/bash
source ./functions.sh

echo ""

read -p "Please make sure a sudo password is already set before continuing. If you have not set the user\
 or sudo password, please exit this installer with 'Ctrl+c' and then create a password either using 'passwd'\
 from a command line or by using the KDE Plasma User settings GUI. Otherwise, press Enter/Return to continue with the install."

echo -e "\n \
D. Default (starred) \n \
* 0. Update apps \n \
* 1. Update Flatpaks \n \
* 2. Install firefox \n \
* 3. Install_corekeyboard \n \
* 4. Install_barrier \n \
* 5. Install_heroic_games \n \
* 6. Install_ProtonUp_QT \n \
* 7. Install_BoilR \n \
* 8. Install_Flatseal \n \
  9. Install Steam ROM Manager \n \
* 10. Add Flathub \n \
* 12. Install_deckyloader \n \
* 13. Install_cryoutilities \n \
* 14. Install_emudeck \n \
* 15. Install_refind_all \n \
  16. Install_refind_GUI \n \
  17. Install_refind_bootloader \n \
  18. Apply_refind_config \n \
  19. Save rEFInd config \n \
  20. Install_refind \n \
  21. Uninstall_deckyloader \n \
  22. Fix_barrier \n \n \
Which tasks to run? (0 for all the default tasks)"

default_tasks=( 0 1 2 3 4 5 6 7 8 10 11 12 13 14 15 ) # edit these numbers to edit the default tasks

read string
echo $string
if [ "$string" == "D" ];
then
    echo "string is D"
    for i in "${default_tasks[@]}";
    do
        echo "${tasks[$i]}"
#        ${tasks[$i]} #run each task in default tasks array
    done
else
    echo "string is not 0" # if default tasks isn't chosen
    IFS=' ' read -r -a chosen_tasks <<< "$string" # split the input to an array
    for i in "${chosen_tasks[@]}"
    do
        echo "${tasks[$i]}" #echo the task for each
#        ${tasks[$i]} # run the tasks 
    done
fi
