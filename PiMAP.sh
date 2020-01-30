#!/bin/bash
#title:         PiMap.sh
#description:   Automated Script to Scan Vulnerability in Network
#author:        R12W4N
#==============================================================================

RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
BLUE=`tput setaf 4`
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
//\utomated  \\/ulnerability  []ntegrated  //\ssessment   L| ool ${RESET}"                                                               

}
trap "trap_ctrlc" 2 


#Menu options
options[0]="${GREEN}Localhost Discovery + Basic Recon${RESET}"
options[1]="${GREEN}Vulnerability Scan${RESET}"
options[2]="${GREEN}Advance Vulnerability Scan${RESET}"
options[3]="${GREEN}EternalBlue Doublepulsar${RESET}"
options[4]="${GREEN}Anonymous FTP Scan${RESET}"
options[5]="${GREEN}Router / Wireless Web Login${RESET}"
options[6]="${GREEN}SMTP and SAMBA Enumeration${RESET}"
options[7]="${GREEN}HTTP Enumeration${RESET}"
options[8]="${GREEN}VNC Vuln + SNMP Brute${RESET}"

reportdir(){
    echo -e "${RED}[+] Creating results directory.${RESET}"
    mkdir -p $name-aviato-reports && cd $name-aviato-reports

}

lhd_scan(){
	echo "${GREEN}[+]Logging Live Host ${BLUE}"
        nmap -oG grepable-$name $iprange
        cat grepable-$name | grep Up | cut -d ' ' -f 2 | sort -u > $name-livehost.txt
        cat $name-livehost.txt
        echo "${GREEN}[+]Logging Live Host Done ${RESET}"
}

basic_scan(){
	echo "${GREEN}Scanning Started ${BLUE}"
        nmap -A -oA basic_scan_$name $iprange | ccze -A | ansi2html > raw_basic_scan_$name.html
        echo "${GREEN}Main Scan Done ${RESET}"
	sleep 10
	xsltproc -o basic_scan_$name.html ../nmap-bootstrap.xsl basic_scan_$name.xml

}

vulners_cve(){
	echo "${GREEN}Scanning for vulnerabilities CVE in live host ${BLUE}"
        nmap -oA vulners_scan_$name -sV $iprange --script vulners.nse | ccze -A | ansi2html > raw_vulners_$name.html
        echo "${green}Vulnerability Scanning Done ${reset}"
	sleep 20
	xsltproc -o vulners_scan_$name.html ../nmap-bootstrap.xsl vulners_scan_$name.xml
}

adv_scan(){
	echo "${GREEN}Advance Vulnerabilty Scan Started ${BLUE}"
        nmap -oA advance_vuln_$name -sV $iprange --script=vulscan/vulscan.nse --script-args vulscandb=exploitdb.csv | ccze -A | ansi2html > raw_advance-vuln.html
	sleep 10
	xsltproc -o advance_vuln_$name.html ../nmap-bootstrap.xsl advance_vuln_$name.xml
	echo "${GREEN}Advance Vulnerabilty Scan Completed ${BLUE}"

}

MS17_010(){
	echo "${GREEN}Eternalblue Doublepulsar Scan Initiated ${BLUE}"
  	nmap -oA Eternal_MS17_010_$name -Pn -p445 --open --max-hostgroup 3 --script smb-vuln-ms17-010 $iprange | ccze -A | ansi2html > raw_ms17_010.html
        sleep 10
        xsltproc -o Eternal_MS17_010_$name.html ../nmap-bootstrap.xsl Eternal_MS17_010_$name.xml
        echo "${GREEN}Advance Vulnerabilty Scan Completed ${RESET}"

}

anonftp(){
	# Anonymous FTP
	echo "${GREEN}Scanning for Anonymous FTP ${BLUE}"
	nmap -oA AnonymousFTP_$name -v -p 21 --script=ftp-anon.nse $iprange | ccze -A | ansi2html > raw_anonftp.html
	sleep 10
	xsltproc -o AnonymousFTP_$name.html ../nmap-bootstrap.xsl AnonymousFTP_$name.xml
	echo "${GREEN}Anonymous FTP Scan Completed ${RESET}"
}

routerweblogin(){
	echo "${GREEN}Scanning for any Router Web Portal${BLUE}"
	# Router / Wireless Web Login
	nmap -oA RouterWebLogin_$name -sS -sV -vv -n -Pn -T5 $iprange -p80 -oG - | grep 'open' | grep -v 'tcpwrapped' | ccze -A | ansi2html > raw_RouterWebLogin.html
	xsltproc -o RouterWebLogin_$name.html ../nmap-bootstrap.xsl RouterWebLogin_$name.xml
	echo "${GREEN}Scan Completed${RESET}"
}

smtpnsmb(){
# SMTP and Samba Vulnerabilities
	nmap --script smtp-vuln-* -p 25  $iprange > smtp.txt
	nmap --script smb-vuln-* -p 445 $iprange > smb-vuln.txt
	nmap --script ftp-vuln-* -p 21 $iprange > ftpvuln.txt
	nmap --script smb-enum-shares.nse -p445 $iprange > smbshare.txt 
	nmap --script smb-os-discovery.nse -p445 $iprange > smbosdiscovery.txt
}

http_enum(){
	# HTTP Enum
	nmap --script http-enum $iprange > httpenum.txt
	# HTTP Title
	nmap --script http-title -sV -p 80 $iprange > httptitle.txt
	# HTTP Vulnreability CVE2010-2861
 	nmap -v -p 80 --script http-vuln-cve2010-2861 $iprange> httpvuln.txt

}

vnc_scan(){
	# VNC Title
	nmap -sV --script=vnc-title $iprange > vnctitle.txt
	# VNC Brute
	nmap --script vnc-brute -p 5900 $iprange > vncbrute.txt
	# Auth RealVNC Bypass
	nmap -sV --script=realvnc-auth-bypass $iprange > vncbypass.txt
}

snmp(){
	# SNMP Brute Force
	nmap -sU --sript snmp-brute $iprange --sript-args snmp-brute.communitiesdb=snmp-community.txt > snmpbrute.txt
}


#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
        echo "Option 1 selected"
	lhd_scan
	basic_scan
    fi
    if [[ ${choices[1]} ]]; then
        #Option 2 selected
        echo "Option 2 selected"
	vulners_cve
    fi
    if [[ ${choices[2]} ]]; then
        #Option 3 selected
        echo "Option 3 selected"
	adv_scan
    fi
    if [[ ${choices[3]} ]]; then
        #Option 4 selected
        echo "Option 4 selected"
	MS17_010
    fi
    if [[ ${choices[4]} ]]; then
        #Option 5 selected
        echo "Option 5 selected"
	anonftp
    fi
    if [[ ${choices[5]} ]]; then
        #Option 6 selected
        echo "Option 6 selected"
	routerweblogin
    fi
    if [[ ${choices[6]} ]]; then
        #Option 7 selected
        echo "Option 7 selected"
	smtpnsmb
    fi
    if [[ ${choices[7]} ]]; then
        #Option 8 selected
        echo "Option 8 selected"
	http_enum
    fi
    if [[ ${choices[8]} ]]; then
        #Option 9 selected
        echo "Option 9 selected"
    fi
    if [[ ${choices[9]} ]]; then
        #Option 10 selected
        echo "Option 10 selected"
	vnc_scan
	snmp
    fi
    if [[ ${choices[10]} ]]; then
        #Option 11 selected
        echo "Option 11 selected"
    fi

}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "Menu Options"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
}

#Menu loop
while MENU && read -e -p "Select the desired options using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

#Starts from here

banner
echo "${BLUE}[+] Don't forget to run it under screen ... ${RESET}"
read -p "${RED}Enter the Project Name : ${RESET}" name
read -p "${RED}Enter IP Address/ IP Range :${RESET} " iprange

#read -p "Start Scanning ? y/n " ss
reportdir
ACTIONS

