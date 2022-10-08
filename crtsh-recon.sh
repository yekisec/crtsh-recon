#!/bin/bash

################################################################################
## Name: crtsh-recon
## Author: Kyle Walters (yekisec) 
## License: GNU - General Public License 3 (GPL)
##
## Functionality: 
##
## - This script takes a wildcard domain as input and outputs unique subdomains
## identified via https://crt.sh.
## 	
## - One or more wildcard domains can be provided through STD-IN or 
## command line arguments (separated by a single space.
################################################################################


# 1. verify dependencies
# 2. Collect and store list of wildcard domains passed to the script 
#    via STD-IN or command-line arguments.
# 3. enter while loop
#    1) Query crt.sh, parse the json, and remove duplicate results
#    2) Add unique domains to array
#    3) repeat until all wildcard domains have been utilized and then exit the loop.
# 4. print array of scraped subdomains to STD-OUT


MISSING_DEPENDENCY=5 # exit code 5 indicates a missing dependency
DEPENDENCIES="curl jq sed"

prog_exists () {
	if ! command -v $1 &> /dev/null; then
		echo "0"
	else
		echo "1"
	fi
}

for DEPENDENCY in $DEPENDENCIES; do
	if [[ $(prog_exists $DEPENDENCY) -eq 0 ]]; then # prog_exists returns 0 if command not found.
		printf "ERROR: the command \"$DEPENDENCY\" could not be located in the \$PATH\n"
		exit $MISSING_DEPENDENCY
	fi
done

IFS=$'\n'
WILDCARD_DOMAINS=""
if [ $(ls /proc/self/fd/0 -al | awk -F' ' '{ print $11 }' | cut -d ':' -f 1) == "pipe" ] && [[ $# -ge 1 ]]; then
	WILDCARD_DOMAIN1=$(</dev/stdin)
	WILDCARD_DOMAIN2="$*"
	WILDCARD_DOMAINS="$WILDCARD_DOMAIN1 $WILDCARD_DOMAIN2"
elif [[ $# -ge 1 ]] && [ ! $(ls /proc/self/fd/0 -al | awk -F' ' '{ print $11 }' | cut -d ':' -f 1) == "pipe" ]; then
	WILDCARD_DOMAINS="$*"
elif [[ ! $# -ge 1 ]] && [ $(ls /proc/self/fd/0 -al | awk -F' ' '{ print $11 }' | cut -d ':' -f 1) == "pipe" ]; then
	WILDCARD_DOMAINS=$(</dev/stdin)
else
	printf "ERROR: This script requires at least one wildcard domain to be\nprovided via STD-IN or command-line argument."
fi

RESULTS=""
for WILDCARD_DOMAIN in $(echo $WILDCARD_DOMAINS | tr ' ' '\n'); do
	RESULTS+=$(curl -s "https://crt.sh/?q=%25.$WILDCARD_DOMAIN&output=json" | jq .[].common_name | sed "s/\"//g" | grep "\.$WILDCARD_DOMAIN$" | sed "s/^\*\.//g" | sort -u)

done

echo $RESULTS | tr " " "\n"
