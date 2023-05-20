#! /usr/bin/bash

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$configurator_dir/functions.sh"

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"

if [ $? == 1 ];
then
exit 0
fi

#preselected=( "update_flatpaks" )

create_menu

#readarray -t chosen_tasks < <(echo $menu | xargs kdialog --separate-output --geometry 1280x800 --checklist "Select tasks, click and drag to multiselect")

echo ${chosen_tasks[@]}
if [ ${#chosen_tasks[@]} -eq 0 ]
then
echo No tasks chosen, exiting...
exit 0
fi

if [[ " ${chosen_tasks[*]} " =~ " create_config " ]]; then
create_config
elif [[ " ${chosen_tasks[*]} " =~ " load_config " ]]; then
load_config
fi


dbusRef=$(kdialog --progressbar "Initializing" ${#chosen_tasks[@]})
qdbus $dbusRef setLabelText "Initializing..."

for task in "${chosen_tasks[@]}"
do
    ((task_number ++))
    if [ "$(qdbus $dbusRef org.kde.kdialog.ProgressDialog.wasCancelled)" == "false" ];
    then
    echo $task
    $task #run task
    qdbus $dbusRef Set "" value $task_number
    else
    echo "Task $task not executed, exiting..."
    exit 0
    fi
done
qdbus $dbusRef setLabelText "$task_number/${#chosen_tasks[@]}: Tasks completed"
