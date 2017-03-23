#!/bin/bash
normal='\e[0m'
blue='\e[1;34m'
red='\e[1;31m'
yellow='\e[1;33m'
ul='\e[1;4m'
purp='\e[1;35m'
green='\e[1;32m'
echo -e "${red}	|"
if [[ -d .workspace ]] ; then rm -rf .workspace ; fi
mkdir .workspace
cd .workspace
nmap -sn $1 > nmap.txt
cat nmap.txt | grep -e "Nmap scan" | awk {' print $5 '} > ips.txt
cat nmap.txt | grep -e "MAC Address" | awk {' print $3 '} > macs.txt

for i in $( cat ips.txt ) ; do
	echo $i >> nmp.txt
	nmap $i | grep "open" >> nmp.txt
done
x=1
cat nmp.txt | while read i ; do
	if [[ $i == $( cat ips.txt | awk NR==$x ) ]] ; then
	        echo -e "${red}	|__ $blue`cat ips.txt | awk NR==$x` \t $yellow`cat macs.txt | awk NR==$x`"
		let x=$x+1
	else
 	       echo -e "${green}		|__ $purp $i"
	fi
done
