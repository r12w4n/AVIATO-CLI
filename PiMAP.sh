#!/bin/bash

VERSION="1.0"


RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
BOLD='tput bold'
function trap_ctrlc ()
{
    echo "Ctrl-C caught...performing clean up"
 
    echo "Doing cleanup"
    trap "kill 0" EXIT
    exit 2
}

banner(){
echo -e "${GREEN}

 █████╗ ██╗   ██╗██╗ █████╗ ████████╗ ██████╗ 
██╔══██╗██║   ██║██║██╔══██╗╚══██╔══╝██╔═══██╗
███████║██║   ██║██║███████║   ██║   ██║   ██║
██╔══██║╚██╗ ██╔╝██║██╔══██║   ██║   ██║   ██║
██║  ██║ ╚████╔╝ ██║██║  ██║   ██║   ╚██████╔╝
╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝                                           	    
 _           _ _              ()            _            ____  
//\utomated  \\/ulnerability  []ntegrated  //\ssessment   L| ool ${RESET} ${RED}v$VERSION${RESET}  
                                           ${GREEN}|__|${RESET}    by ${}@R12W4N{RESET}\n
"                                                               

}
trap "trap_ctrlc" 2 

reportdir(){
    echo -e "${GREEN}[+] Creating results directory.${RESET}"
    mkdir -p $name-aviato-reports && cd $name-aviato-reports

}

lhd_scan(){
	echo "${GREEN}[+]Logging Live Host ${RESET}"
        nmap -oG grepable-$name $iprange
        cat grepable-$name | grep Up | cut -d ' ' -f 2 | sort -u > $name-livehost.txt
        cat $name-livehost.txt
        echo "${GREEN}[+]Logging Live Host Done ${RESET}"
}

basic_scan(){
	echo "${GREEN}Scanning Started ${RESET}"
        nmap -A -oA basic_scan_$name $iprange | ccze -A | ansi2html > raw_basic_scan_$name.html
        echo "${GREEN}Main Scan Done ${RESET}"
	sleep 10
	xsltproc -o basic_scan_$name.html ../nmap-bootstrap.xsl basic_scan_$name.xml

}

vulners_cve(){
	echo "${GREEN}Scanning for vulnerabilities CVE in live host ${RESET}"
        nmap -oA vulners_scan_$name -sV $iprange --script vulners.nse | ccze -A | ansi2html > raw_vulners_$name.html
        echo "${green}Vulnerability Scanning Done ${reset}"
	sleep 20
	xsltproc -o vulners_scan_$name.html ../nmap-bootstrap.xsl vulners_scan_$name.xml
}

adv_scan(){
	echo "${GREEN}Advance Vulnerabilty Scan Started ${RESET}"
        nmap -oA advance_vuln_$name -sV $iprange --script=vulscan/vulscan.nse | ccze -A | ansi2html > raw_advance-vuln.html
	sleep 10
	xsltproc -o advance_vuln_$name.html ../nmap-bootstrap.xsl advance_vuln_$name.xml
	echo "${GREEN}Advance Vulnerabilty Scan Completed ${RESET}"

}

csv_convert(){
cd ..
./nmap-converter.py -o $name-aviato-reports/basic_scan_$name.xlsx $name-aviato-reports/basic_scan_$name.xml
./nmap-converter.py -o $name-aviato-reports/vulners_scan_$name.xlsx $name-aviato-reports/vulners_scan_$name.xml
}
echo "${BOLD} Don't forget to run it under screen ... ${RESET}"
read -p "${RED}Enter the Project Name : ${RESET}" name
read -p "${RED}Enter IP Address/ IP Range :${RESET} " iprange

#read -p "Start Scanning ? y/n " ss
reportdir
lhd_scan
basic_scan
vulners_cve
csv_convert

read -p "Do you want to run advance Vulnerability scan ? y/n " ss
if [[ $ss = 'y' ]]
then
	adv_scan

else
	exit 0 
fi
