#! /usr/bin/bash

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$configurator_dir/functions.sh"

kdialog --title "password" --yesno "Please make sure a sudo password is set before continuing. If you have not set the sudo password, set it first. Continue?"

if [ $? == 1 ];
then
exit 0
fi

set_interactive_tasks
set_menu
create_dialog