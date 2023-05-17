#! /usr/bin/bash

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$configurator_dir/functions.sh"

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"

if [ $? == 1 ];
then
exit 0
fi

config=$(kdialog --menu configs dualboot dualboot triple_boot triple_boot) ##make this a checklist, so that you can select multiple configs, and will preselect all relevant ones

case $config in
dualboot)
    config=( "Update Submodules" )
    ;;
triple_boot)
    config=( "Export Flatpaks" )
    ;;
esac

echo config is $config

for key in "${!tasks_array[@]}"; do
    if [[ " ${config[*]} " =~ " ${key} " ]]; then
    menu+="\"\${tasks_array[$key]}\" \"$key\" on "
    else
    menu+="\"\${tasks_array[$key]}\" \"$key\" off "
    fi
done

echo $menu | xargs kdialog --separate-output --geometry 1280x800 --checklist "Select tasks, click and drag to multiselect"


echo ${chosen_tasks[@]}
if [ ${#chosen_tasks[@]} -eq 0 ]
then
echo No tasks chosen, exiting...
exit 0
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
