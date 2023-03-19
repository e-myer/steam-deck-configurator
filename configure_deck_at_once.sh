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

no_interactive
