#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`

function trap_ctrlc ()
{
    echo "Ctrl-C caught...performing clean up"
 
    echo "Doing cleanup"
    trap "kill 0" EXIT
    exit 2
}

trap "trap_ctrlc" 2

setupTools(){
echo -e "${GREEN}[+] Setting things up.${RESET}"
#   sudo apt update -y
#   sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt clean
    sudo apt install -y gcc g++ make libpcap-dev xsltproc
    sudo apt install python3-pip -y 
    sudo pip install ansi2html
    sudo apt install ccze -y
    sudo apt-get install nmap -y
    sudo pip install python-libnmap
    sudo pip install XlsxWriter
    wget https://raw.githubusercontent.com/mrschyte/nmap-converter/master/nmap-converter.py
    chmod +x nmap-converter.py
    #wget -P /usr/share/nmap/scripts/ https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
    #cd /usr/share/nmap/scripts/ && git clone https://github.com/scipag/vulscan.git
    vulners="/usr/share/nmap/scripts/vulners.nse"
	if [ ! -f "$vulners" ]
	then
		echo "${GREEN}Downloading vulners${RESET}"
		wget -P /usr/share/nmap/scripts/ https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
	fi

    	vulscan="/usr/share/nmap/scripts/vulscan"

	if [ ! -d "$vulscan" ]
	then
		echo "${GREEN}Downloading vulscan${RESET}"
		cd /usr/share/nmap/scripts/ && git clone https://github.com/scipag/vulscan.git
	fi
}

setupTools
nmap --script-updatedb
