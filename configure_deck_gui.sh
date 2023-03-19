#! /usr/bin/bash

source ./functions.sh

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"
#exit code of yes is 0 and no is 1

if [ $? == 1 ];
then
exit 0
fi

options_function

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