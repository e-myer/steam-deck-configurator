#! /usr/bin/bash
source ./functions.sh

echo ""

read -p "Please make sure a sudo password is already set before continuing. If you have not set the user\
 or sudo password, please exit this installer with 'Ctrl+c' and then create a password either using 'passwd'\
 from a command line or by using the KDE Plasma User settings GUI. Otherwise, press Enter/Return to continue with the install."

echo -e "$cli_tasks_display"

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
