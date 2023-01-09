#!/bin/bash

scan_config () {
	countresult=$(ls -lp $location | grep -v / | awk '{print $9}' | awk NF)
	result=($(ls -lp $location | grep -v / | awk '{print $9}' | awk NF))
	totalfile=$(ls $location | wc -l)
	((totalfile=totalfile-1))
}

show_config () {
	scan_config
	number=0
	for i in $countresult; do
		echo "[$number] ${result[$number]}"
		((number=number+1))
	done
}

input_config () {
	numbercheck='^[0-9]+$'
	echo "Choose with order number (0-$totalfile) : "
	read choice
	if [[ $choice -gt $totalfile ]]; then
		echo "Invalid number. Input range is 0-$totalfile"
	elif [[ $choice =~ $numbercheck ]]; then
	        filename=$(echo ${result[$choice]})
        	cp -R $location/$filename $fileconfig
                echo "Kube context changed to ${result[$choice]}"
	else
                echo "Invalid input. Only type available order number" >&2; exit 1
	fi
}

change_config () {
        cp -R $location/$1 $fileconfig
        echo "Kube context changed to $1"
}

fileconfig="$HOME/.kube/config"
location="$HOME/.kube/credentials"
if [[ ${#1} -gt 0 ]]; then {
	checkfile=$(ls $location/ | grep $1)
	if [[ ${#checkfile} -gt 0 ]]; then {
		change_config $1
	} else {
		echo "File not found"
	} fi
} elif [[ -z $1 ]]; then {
	show_config
	input_config
} else {
	echo "File not found"
} fi
