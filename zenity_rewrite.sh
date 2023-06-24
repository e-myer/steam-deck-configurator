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

menu='FALSE "echoes_hi" "echo hi" \
FALSE "echoes_ho" "echo ho" \
FALSE "echoes_he" "echo he"'

echo "$menu" | xargs zenity --list --checklist --separator=$'\n' --column=status --column=task --column=label