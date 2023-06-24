#! /usr/bin/bash

# Configures various functions in a Steam Deck

configurator_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echoes_hi() {
    echo hi
}

echoes_ho() {
    echo ho
}

echoes_he() {
    echo he
}

set_menu() {
menu='FALSE "echoes_hi" "echo hi" \
FALSE "echoes_ho" "echo ho" \
FALSE "echoes_he" "echo he"'
}

create_dialog() {
    while true; do
        readarray -t chosen_tasks < <(echo "$menu" | xargs zenity --list --checklist --separator=$'\n' --column=status --column=task --column=label --print-column=2 --hide-column=2)
        #echo "${chosen_tasks[@]}"
        run_tasks
    done
}

run_tasks() {
    #echo "${chosen_tasks[@]}"
    #echo "${#chosen_tasks[@]}"

    for chosen_task in "${chosen_tasks[@]}"; do
        $chosen_task
    done
}


set_menu
create_dialog

