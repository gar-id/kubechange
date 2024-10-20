#!/usr/bin/env bash

# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

show_help () {
echo -e "\n\
Usage   : kubechange [OPTIONS] FILENAME \n\
\n\
Options : \n\
help            Show kubechange usage \n\
edit            Edit your current kube context \n\
context         Choose your kube context \n\
info		Your current kube context name \n\
new             Create new kubecontext to default directory \n\
ns              Set your default kube namespace \n\
rm		Delete your kube context (use with caution!) \n\
\n\
Example :\n\
kubechange new k3s-prod         -> Create kube context file with name k3s-prod\n\
Kubechange context k3s-dev      -> Choose k3s-dev kube context\n\
Kubechange context              -> Show all kube context\n\
kubechange ns prod              -> Set your default kube namespace to prod\n\
kubechange rm current		-> Delete current file (not source file)\n\
kubechange rm k3s-dev		-> Delete k3s-dev source file context\n\
kubechange info			-> Check current config name\n\
"
}

scan_config () {
	countresult=$(ls -lp $location | grep -v / | awk '{print $9}' | awk NF)
	result=($(ls -lp $location | grep -v / | awk '{print $9}' | awk NF))
	totalfile=$(ls -p $location | grep -v / | wc -l)
	((totalfile=totalfile-1))
}

input_config () {
        numbercheck='^[0-9]+$'
        echo "Choose kube context : "
        select_option "${result[@]}"
        choice=$?

        if [[ $choice -gt $totalfile ]]; then {
                echo "Invalid number. Input range is 0-$totalfile"
        } elif [[ $choice =~ $numbercheck ]]; then {
                filename=$(echo ${result[$choice]})
                cp -R $location/$filename $fileconfig
		write_name $filename
                echo "Kube context changed to ${result[$choice]}"
        } else
                echo "Invalid input. Only type available order number" >&2; exit 1
        fi
}

change_config () {
        cp -R $location/$1 $fileconfig
        echo "Kube context changed to $1"
}

delete_config () {
        rm $1
        echo "Kube context $1 deleted."
}

scan_namespace () {
	countnamespace=$(kubectl get namespace | awk '(NR>1) {print $1}')
	listnamespace=($(kubectl get namespace | awk '(NR>1) {print $1}'))
	totalnamespace=$(kubectl get namespace | awk '(NR>1) {print $1}' | wc -l)
	((totalnamespace=totalnamespace-1))
}

change_ns () {
	kubectl config set-context --current --namespace=$1
	echo "Kube default namespace changed to $1"
}

input_ns () {
	numbercheck='^[0-9]+$'
	echo "Choose default namespace : "
	select_option "${listnamespace[@]}"
	choice=$?

	if [[ $choice -gt $totalnamespace ]]; then {
		echo "Invalid number. Input rage is 0-$totalnamespace"
	} elif [[ $choice =~ $numbercheck ]]; then {
		nsname=$(echo ${listnamespace[$choice]})
		change_ns $nsname
	} else
		echo "Invalid input. Only type available order number" >&2; exit 1
        fi
}

write_name () {
        echo $1 > $statusfile
}

statusfile="$HOME/.kube/contextname"
fileconfig="$HOME/.kube/config"
location="$HOME/.kube/credentials"
if [[ ${#1} -gt 0 ]]; then {
        checkfile=$(ls $location/ | grep $2 2> /dev/null)
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
        } elif [[ $1 == "rm" ]]; then { 
                if [[ $2 == "current" ]]; then {
			delete_config ~/.kube/config
		} elif [[ ${#checkfile} -gt 0 ]]; then {
			delete_config $location/$2
		} elif [[ -z $2 ]]; then {
			echo -e "Kubechange requires exactly 1 argument.\nSee 'kubechange help'."
		} else {
                        echo "File not found"
                } fi	
	} elif [[ $1 == "context" ]]; then {
		if [[ ${#checkfile} -gt 0 ]]; then {
			change_config $2
			write_name $2
		} elif [[ -z $2 ]]; then {
			scan_config
			input_config
		} else {
			echo "File not found"
		} fi
	} elif [[ $1 == "ns" ]]; then {
		#checkns=$(kubectl get namespace | awk '(NR>1) {print $1}' | grep $2 2> /dev/null)
		if [[ ${#2} -gt 0 ]]; then {
			change_ns $2
			echo "Kube namespace change to $2"
		} elif [[ -z $2 ]]; then {
			scan_namespace
			input_ns
		} else {
			echo "Namespace not found"
		} fi
	} elif [[ $1 == "info" ]]; then {
		currentContext=$(cat $statusfile)
		echo "Current context name is $currentContext"
	} else {
		echo -e "Kubechange requires exactly 1 argument.\nSee 'kubechange help'."
	} fi
} else {
	echo -e "Kubechange requires exactly 1 argument.\nSee 'kubechange help'."
} fi
