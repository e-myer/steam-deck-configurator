#! /bin/bash

test_one(){
    echo "10.00"
    echo "# title one"
}

test_two(){
    echo "20.00"
    echo "# title two"
}

test_three(){
    echo "30.00"
    echo "# title three"
}

tests=(test_one test_two test_three)

run_tests(){
    for i in ${tests[@]}; do
        $i
        sleep 1
    done
}

run_tests | zenity --progress