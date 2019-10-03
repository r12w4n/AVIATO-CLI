#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

#echo "${red}red text ${green}green text${reset}"
sudo apt-get install ccze -y
read -p "${red}Enter the Project Name : " name
read -p "${red}Enter IP Address/ IP Range : " iprange
mkdir /var/www/html/$name
mkdir $name-nmap-reports && cd $name-nmap-reports
echo "${reset}"
wget -p /usr/share/nmap/scripts https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
git clone https://github.com/vulnersCom/nmap-vulners.git /usr/share/nmap/scripts
wget https://raw.githubusercontent.com/r12w4n/AVIATO-CLI/master/nmap-bootstrap.xsl
wget https://github.com/r12w4n/AVIATO-CLI/raw/master/DisplayDirectoryContents.zip
unzip DisplayDirectoryContents.zip -d /var/www/html/$name

git clone https://github.com/ralphbean/ansi2html.git && cd ansi2html && chmod +x setup.py && ./setup.py install && cd ..
read -p "Start Scanning ? y/n " ss
	while true; do echo -n .; sleep 1; done &
	trap 'kill $!' SIGTERM SIGKILL

	if [[ $ss = "y" ]]; then
	
	echo "${green}Logging Live Host ${reset}"
	nmap -oG  $name-grepable.txt $iprange
	cat $name-grepable.txt | grep Up | cut -d ' ' -f 2 | sort -u > $name-livehost.txt
	cat $name-livehost.txt
	echo "${green}Logging Live Host Done ${reset}"

	echo "${green}Scanning Started ${reset}"
	nmap -A -oA $name --stylesheet nmap-bootstrap.xsl $iprange | ccze -A | ansi2html > $name.html
	echo "${green}Main Scan Done ${reset}"

	echo "${green}Scanning for vulnerabilities CVE in live host ${reset}"
	nmap -oA $name-vulners --stylesheet nmap-bootstrap.xsl -sV $iprange --script vulners.nse | ccze -A | ansi2html > $name-vulners.html
	echo "${green}Vulnerability Scanning Done ${reset}"

	read -p "Do you want perform Advance Vulnerabilty Scan? y/n" avs
	if [[ $avs = "y" ]]; then
		echo "${green}Advance Vulnerabilty Scan Started ${reset}"
		nmap -oA $name-advance-vuln --stylesheet nmap-bootstrap.xsl -sV $iprange --script=vulscan/vulscan.nse -script-args vulscanoutput=details | ccze -A | ansi2html > $name-advance-vuln.html
		echo "${green}Advance Vulnerabilty Scan Completed ${reset}"
		rm -rf ansi2html nmap-bootstrap.xsl
                mkdir /var/www/html/$name
                cp `find . -type f \( -iname \*.xml -o -iname \*.html \)` /var/www/html/$name/
                kill $!
                exit 0
	fi
		rm -rf ansi2html nmap-bootstrap.xsl
                cp `find . -type f \( -iname \*.xml -o -iname \*.html \)` /var/www/html/$name/
                kill $!
                exit 0

fi
	kill $!
	exit 0
