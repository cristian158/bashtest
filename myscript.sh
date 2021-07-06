#!/bin/bash

clear
echo 'Hi'
read -p 'Please tell me your name: ' name
echo "$name" >> names.txt
clear
echo -e "Hello $name\nYour name has been added to my list."
echo '-------------'
cat names.txt

echo '$$$$$$$$$$$$$'
echo "Goodbye $name"
sleep 4
