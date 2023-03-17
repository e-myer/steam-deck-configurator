#! /usr/bin/bash

dbusRef=$(kdialog --progressbar "Initializing" 4)
qdbus $dbusRef Set "" value 1
for i in {1..5}; do
echo $i | tee terminal_output
qdbus $dbusRef setLabelText "$(tail --lines 1 ./terminal_output)"
sleep 1
done
qdbus $dbusRef close