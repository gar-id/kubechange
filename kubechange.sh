#!/bin/bash

scan_config () {
	countresult=$(ls -lp $location | grep -v / | awk '{print $9}' | awk NF)
	result=($(ls -lp $location | grep -v / | awk '{print $9}' | awk NF))
	totalfile=$(ls -p $location | grep -v / | wc -l)
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

scan_namespace () {
	countnamespace=$(kubectl get namespace | awk '(NR>1) {print $1}')
	listnamespace=($(kubectl get namespace | awk '(NR>1) {print $1}'))
	totalnamespace=$(kubectl get namespace | awk '(NR>1) {print $1}' | wc -l)
	((totalnamespace=totalnamespace-1))
}

show_namespace () {
	scan_namespace
	number=0
	for i in $countnamespace; do
		echo "[$number] ${listnamespace[$number]}"
		((number=number+1))
	done
}

show_help () {
echo -e "\n\
Usage	: kubechange [OPTIONS] FILENAME \n\
\n\
Options : \n\
help		Show kubechange usage \n\
new		Create new kubecontext to default directory \n\
edit		Edit your current kube context \n\
context		Choose your kube context \n\
ns		Set your default kube namespace \n\
\n\
Example	:\n\
kubechange new k3s-prod		-> Create kube context file with name k3s-prod\n\
Kubechange context k3s-dev	-> Choose k3s-dev kube context\n\
Kubechange context		-> Show all kube context\n\
kubechange ns prod		-> Set your default kube namespace to prod\n\
"
}

change_ns () {
	kubectl config set-context --current --namespace=$1
	echo "Kube default namespace changed to $1"
}

input_ns () {
	numbercheck='^[0-9]+$'
	echo "Choose with order number (0-$totalnamespace) : "
	read choice
	if [[ $choice -gt $totalnamespace ]]; then {
		echo "Invalid number. Input rage is 0-$totalnamespace"
	} elif [[ $choice =~ $numbercheck ]]; then {
		nsname=$(echo ${listnamespace[$choice]})
		change_ns $nsname
	} else
		echo "Invalid input. Only type available order number" >&2; exit 1
        fi
}

input_config () {
	numbercheck='^[0-9]+$'
	echo "Choose with order number (0-$totalfile) : "
	read choice
	if [[ $choice -gt $totalfile ]]; then {
		echo "Invalid number. Input range is 0-$totalfile" 
	} elif [[ $choice =~ $numbercheck ]]; then {
	        filename=$(echo ${result[$choice]})
        	cp -R $location/$filename $fileconfig
                echo "Kube context changed to ${result[$choice]}" 
	} else
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
        checkfile=$(ls $location/ | grep $2 2> /dev/null)
	checkns=$(kubectl get namespace | awk '(NR>1) {print $1}' | grep $2 2> /dev/null)
	if [[ $1 == "edit" ]]; then {
		echo -e "Editing current kube context"
		sleep 0.2
		vi $fileconfig
	} elif [[ $1 == "new" ]]; then {
		if [[ $2 == "" ]]; then {
			echo -e "Kubechange requires exactly 1 argument.\nSee 'kubechange help'."
		} else {
			vi $location/$2
		} fi
	} elif [[ $1 == "help" ]]; then {
		show_help
	} elif [[ $1 == "context" ]]; then {
		if [[ ${#checkfile} -gt 0 ]]; then {
			change_config $2
		} elif [[ -z $2 ]]; then {
			show_config
			input_config
		} else {
			echo "File not found"
		} fi
	} elif [[ $1 == "ns" ]]; then {
		if [[ ${#checkns} -gt 0 ]]; then {
			change_ns $checkns
			echo "Kube namespace change to $checkns"
		} elif [[ -z $2 ]]; then {
			show_namespace
			input_ns
		} else {
			echo "Namespace not found"
		} fi
	} else {
		echo -e "Kubechange requires exactly 1 argument.\nSee 'kubechange help'."
	} fi
} else {
	echo -e "Kubechange requires exactly 1 argument.\nSee 'kubechange help'."
} fi
