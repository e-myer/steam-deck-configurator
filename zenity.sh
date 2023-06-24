#! /usr/bin/bash


#column_names=(--column=TargetDir --column=TargetPage_ID --column=TargetTitle)
#row=("Target Dir 1" 1 "TargetTitle 1")


#zenity --list --checklist --title="list" 

#exit 0


test() {
    echo hi
    number=10
    echo "$number"
    echo "# text"
}

test_two() {
    echo ho
    number=20
    echo "$number"
    echo "# toast"
}

tests=(test test_two)

run_tasks(){
for i in ${tests[@]}; do
$i
sleep 3
done
}

run_tasks | zenity --progress