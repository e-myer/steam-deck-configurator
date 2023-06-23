#! /usr/bin/bash


#column_names=(--column=TargetDir --column=TargetPage_ID --column=TargetTitle)
#row=("Target Dir 1" 1 "TargetTitle 1")


#zenity --list --checklist --title="list" 

#exit 0


menu='FALSE "load_config" "Load Config" \
FALSE "create_config" "Create Config" \
FALSE "add_flathub" "Add Flathub if it does not exist" \
FALSE "update_flatpaks" "Update Flatpaks" \
FALSE "import_flatpaks" "Import Flatpaks" \
FALSE "export_flatpaks" "Export Flatpaks" \
FALSE "install_flatpaks" "Install Flatpaks" \
FALSE "save_flatpaks_install" "Save Flatpaks List" \
FALSE "install_proton_ge_in_steam" "Install Proton GE in Steam" \
FALSE "install_bauh" "Install Bauh" \
FALSE "install_deckyloader" "Install DeckyLoader" \
FALSE "check_for_updates_proton_ge" "Check for Proton GE Updates" \
FALSE "install_cryoutilities" "Install CryoUtilities" \
FALSE "run_cryo_utilities_recommended" "Run CryoUtilities with recommended settings" \
FALSE "install_emudeck" "Install Emudeck" \
FALSE "update_submodules" "Update Submodules" \
FALSE "install_refind_GUI" "Install rEFInd GUI" \
FALSE "install_refind_bootloader" "Install rEFInd bootloader" \
FALSE "fix_barrier" "Fix Barrier" \
FALSE "uninstall_deckyloader" "Uninstall DeckyLoader" \
FALSE "uninstall_refind_gui" "Uninstall rEFInd GUI"'

echo $menu | xargs zenity --list --checklist --column="command" --column="task" --column="description" --hide-column=2 --print-column=2 --separator=$'\n'

