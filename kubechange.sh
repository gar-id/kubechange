#!/bin/bash

scan_config () {
	countresult=$(ls -l $location | awk '{print $9}' | awk NF)
	result=($(ls -l $location | awk '{print $9}' | awk NF))
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
	echo "Pilih config dengan nomor (mulai dari 0) : "
	read choice
        echo ${result[$choice]}
        filename=$(echo ${result[$choice]})
        cp -R $location/$filename $fileconfig
}

change_config () {
        echo $1
        filename=$1
        cp -R $location/$filename $fileconfig
}

fileconfig="$HOME/.kube/config"
location="$HOME/.kube/credentials"
if [[ ${#1} -gt 1 ]]; then {
	checkfile=$(ls $location/ | grep $1)
	if [[ ${#checkfile} -gt 1 ]]; then {
		change_config $1
	} else {
		echo "File not found"
	} fi
} else {
	show_config
	input_config
} fi
